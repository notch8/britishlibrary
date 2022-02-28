# frozen_string_literal: true

# TODO ~alignment: Bring over remaining methods from BL
module ApplicationHelper
  include ::HyraxHelper
  include Hyrax::OverrideHelperBehavior
  include GroupNavigationHelper
  include Ubiquity::SolrSearchDisplayHelpers
  include SharedSearchHelper

  def check_has_editor_fields?(presenter)
    ["Book", "BookContribution", "ConferenceItem", "Report", "GenericWork"].include? presenter
  end

  def ubiquity_url_parser(original_url)
    full_url = URI.parse(original_url)
    if full_url.host.present? && full_url.host.class == String
      full_url.host.split('.').first
    end
  end
end
