# frozen_string_literal: true

require 'csv'

class SherpaApiFunderService
  ##
  # Using the Sherpa and Ror APIs, gather a tentative list of funders.

  FUNDER_GROUP = '1063'
  GROUP_BASE_URL = "https://v2.sherpa.ac.uk/cgi/retrieve_by_id?item-type=funder_group&api-key="
  FUNDER_BASE_URL = "https://v2.sherpa.ac.uk/cgi/retrieve_by_id?item-type=funder&api-key="
  URL_SUFFIX = "&format=Json&identifier="
  DOI_REGEX = %r{^https?://.*doi\.org/(.+)$}
  DOI_PREFIX = "10.13039/"

  # @param export [Boolean] Export data to a csv in tmp/apis/ directory?
  # @param update [Boolean] Use csv in call to MaintainPlanSFunders?
  # Note: any missing data from API calls will trigger PlanSFunder record to become inactive
  #       and all works using that funder to have "Open Access" removed
  def self.process_funders(export: false, update: false)
    funder_array = []
    funders = process_funder_group
    funders.each do |funder|
      response = fetch_record_from_url(api_funder_url(funder_id: funder["id"].to_s))
      response_hash = response.parsed_response
      funder_data = response_hash.dig("items").first if response_hash.dig("items").first.present?
      funder_array << { sherpa_id: funder["id"].to_s,
                        funder_doi: fetch_doi(hash: funder_data),
                        funder_name: fetch_name(hash: funder_data) }
    end
    write_to_csv(from_array: funder_array, update: update) if export
    funder_array
  end

  def self.write_to_csv(from_array:, update: false)
    file_name = "tmp/csv_from_sherpa_#{Time.now.to_i}.csv"
    CSV.open(file_name, 'w') do |csv|
      # Write the headers to the CSV file
      csv << ['sherpa_id', 'funder_doi', 'funder_name', 'funder_status']
      from_array.each do |row|
        csv << [row[:sherpa_id], row[:funder_doi], row[:funder_name], 'active']
      end
    end
    MaintainPlanSFunders.call(csv_path: file_name) if update
  end
  private_class_method :write_to_csv

  def self.api_group_url
    GROUP_BASE_URL + ENV.fetch("SHERPA_API_KEY", nil) + URL_SUFFIX + FUNDER_GROUP
  end
  private_class_method :api_group_url

  def self.api_funder_url(funder_id:)
    FUNDER_BASE_URL + ENV.fetch("SHERPA_API_KEY") + URL_SUFFIX + funder_id
  end
  private_class_method :api_funder_url

  def self.process_funder_group
    group_response = fetch_record_from_url(api_group_url)
    response_hash = group_response.parsed_response
    response_hash.dig("items").first["funders"].presence
  end
  private_class_method :process_funder_group

  def self.fetch_doi(hash:)
    return nil unless hash
    cleaned_doi, doi_from_ror = nil
    identifiers = hash["funder_metadata"]["identifiers"]
    identifiers.each do |id_hash|
      if id_hash["type"] == "fundref"
        cleaned_doi = clean_doi(doi: id_hash["identifier"])
        break
      elsif id_hash["type"] == "ror"
        doi_from_ror = find_doi_from_ror(ror: id_hash["identifier"]) if id_hash["type"] == "ror"
      end
    end
    return cleaned_doi if cleaned_doi.present?
    doi_from_ror
  end
  private_class_method :fetch_doi

  def self.clean_doi(doi:)
    doi.gsub(DOI_REGEX, '\1')
  end
  private_class_method :clean_doi

  def self.find_doi_from_ror(ror:)
    url = "https://api.ror.org/v1/organizations?query=" + ror
    ror_response = fetch_record_from_url(url)
    response_hash = ror_response.parsed_response
    # rubocop:disable Rails/Blank
    funder_id = response_hash.dig("items").first["external_ids"]["FundRef"]["all"].first if response_hash.dig("items").first["external_ids"].present?
    return nil unless funder_id.present?
    # rubocop:enable Rails/Blank
    DOI_PREFIX + funder_id
  end
  private_class_method :find_doi_from_ror

  def self.fetch_name(hash:)
    return nil unless hash
    hash["funder_metadata"]["name"].first["name"]
  end
  private_class_method :fetch_name

  def self.fetch_record_from_url(url)
    handle_client do
      HTTParty.get(url)
    end
  end
  private_class_method :fetch_record_from_url

  def self.handle_client
    yield
  # rubocop:disable Lint/ShadowedException
  rescue URI::InvalidURIError, HTTParty::Error, Net::HTTPNotFound, NoMethodError, Net::OpenTimeout, StandardError => e
    # rubocop:enable Lint/ShadowedException
    "Api server error #{e.inspect}"
  end
  private_class_method :handle_client
end
