# frozen_string_literal: true

class AppIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      # solr_doc[Solrizer.solr_name('contributor_list', :stored_searchable)] = Ubiquity::ParseJson.new(object.contributor.first).fetch_value_based_on_key('contributor')
      # solr_doc['date_published_si'] = Ubiquity::ParseDate.return_date_part(object.date_published, 'year')
      # solr_doc[Solrizer.solr_name('all_orcid_isni', :stored_searchable)] = Ubiquity::FetchAllOrcidIsni.new(object).fetch_data
      # solr_doc[Solrizer.solr_name('work_tenant_url', :stored_searchable)] = Ubiquity::FetchTenantUrl.new(object).process_url
      # Following values were showing in OAI when the value is blank, Added a new field to display if the valuse is present
      solr_doc[Solrizer.solr_name('abstract_oai', :stored_searchable)] = object.abstract.presence
      solr_doc[Solrizer.solr_name('official_link_oai', :stored_searchable)] = object.official_link.presence
      solr_doc[Solrizer.solr_name('doi_oai', :stored_searchable)] = object.doi.presence
      solr_doc["resource_type_label_ssim"] = object.resource_type.map do |rt|
        Hyrax::ResourceTypesService.label(rt)
      end
      solr_doc[Solrizer.solr_name('bulkrax_identifier', :facetable)] = object.bulkrax_identifier
      solr_doc['year_published_isi'] = object.date_published[0...4].to_i if object.date_published.present?
      solr_doc[Solrizer.solr_name('account_cname')] = Site.instance.account.cname
      solr_doc['account_institution_name_ssim'] = "#{Site.instance.institution_name} Research Repository"
    end
  end

end
