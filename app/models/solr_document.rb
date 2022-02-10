# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior
  # Add attributes for DOIs for hyrax-doi plugin.
  include Hyrax::DOI::SolrDocument::DOIBehavior
  # Add attributes for DataCite DOIs for hyrax-doi plugin.
  include Hyrax::DOI::SolrDocument::DataCiteDOIBehavior
  include MultipleMetadataFieldsHelper
  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.
  use_extension(Hydra::ContentNegotiation)

  attribute :resource_type_label, Solr::Array, 'resource_type_label_ssim'
  attribute :extent, Solr::Array, solr_name('extent')
  attribute :rendering_ids, Solr::Array, solr_name('hasFormat', :symbol)
  attribute :isni, Solr::Array, solr_name('isni')
  attribute :account_cname, Solr::Array, solr_name('account_cname')
  attribute :account_institution_name, Solr::Array, 'account_institution_name_ssim'
  attribute :institution, Solr::Array, solr_name('institution')
  attribute :org_unit, Solr::Array, solr_name('org_unit')
  attribute :refereed, Solr::Array, solr_name('refereed')
  attribute :funder, Solr::Array, solr_name('funder')
  attribute :fndr_project_ref, Solr::Array, solr_name('fndr_project_ref')
  attribute :add_info, Solr::Array, solr_name('add_info')
  attribute :date_published, Solr::Array, solr_name('date_published')
  attribute :date_accepted, Solr::Array, solr_name('date_accepted')
  attribute :date_submitted, Solr::Array, solr_name('date_submitted')
  attribute :journal_title, Solr::Array, solr_name('journal_title')
  attribute :issue, Solr::Array, solr_name('issue')
  attribute :volume, Solr::Array, solr_name('volume')
  attribute :pagination, Solr::Array, solr_name('pagination')
  attribute :article_num, Solr::Array, solr_name('article_num')
  attribute :project_name, Solr::Array, solr_name('project_name')
  attribute :rights_holder, Solr::Array, solr_name('rights_holder')
  attribute :original_doi, Solr::Array, solr_name('original_doi')
  attribute :qualification_name, Solr::Array, solr_name('qualification_name')
  attribute :qualification_level, Solr::Array, solr_name('qualification_level')
  attribute :isbn, Solr::Array, solr_name('isbn')
  attribute :issn, Solr::Array, solr_name('issn')
  attribute :eissn, Solr::Array, solr_name('eissn')
  attribute :current_he_institution, Solr::Array, solr_name('current_he_institution')
  attribute :official_link, Solr::Array, solr_name('official_link')
  attribute :place_of_publication, Solr::Array, solr_name('place_of_publication')
  attribute :series_name, Solr::Array, solr_name('series_name')
  attribute :edition, Solr::Array, solr_name('edition')
  attribute :abstract, Solr::Array, solr_name('abstract')
  attribute :event_title, Solr::Array, solr_name('event_title')
  attribute :event_date, Solr::Array, solr_name('event_date')
  attribute :event_location, Solr::Array, solr_name('event_location')
  attribute :book_title, Solr::Array, solr_name('book_title')
  attribute :alternate_identifier, Solr::Array, solr_name('alternate_identifier')
  attribute :related_identifier, Solr::Array, solr_name('related_identifier')
  attribute :version, Solr::Array, solr_name('version')
  attribute :media, Solr::Array, solr_name('media')
  attribute :duration, Solr::Array, solr_name('duration')
  attribute :related_exhibition, Solr::Array, solr_name('related_exhibition')
  attribute :related_exhibition_venue, Solr::Array, solr_name('related_exhibition_venue')
  attribute :related_exhibition_date, Solr::Array, solr_name('related_exhibition_date')
  attribute :editor, Solr::Array, solr_name('editor')
  attribute :creator_search, Solr::Array, solr_name('creator_search')
  attribute :dewey, Solr::Array, solr_name('dewey')
  attribute :library_of_congress_classification, Solr::Array, solr_name('library_of_congress_classification')
  attribute :alt_title, Solr::Array, solr_name('alt_title')
  attribute :alternative_journal_title, Solr::Array, solr_name('alternative_journal_title')
  attribute :collection_names, Solr::Array, solr_name('collection_names')
  attribute :collection_id, Solr::Array, solr_name('collection_id')

  field_semantics.merge!(
    contributor: ['contributor_list_tesim', 'editor_list_tesim', 'funder_tesim'],
    creator: 'creator_search_tesim',
    date: 'date_published_tesim',
    description: 'abstract_oai_tesim',
    identifier: ['official_link_oai_tesim', 'doi_oai_tesim', 'all_orcid_isni_tesim', 'work_tenant_url_tesim', 'collection_tenant_url_tesim'],
    language: 'language_tesim',
    publisher: 'publisher_tesim',
    relation: 'journal_title_tesim',
    rights: 'license_tesim',
    subject: 'keyword_tesim',
    title: 'title_tesim',
    type: 'human_readable_type_tesim'
  )

  def work_creator
    return @work_creator if @work_creator
    return unless creator.first
    @work_creator = ActiveSupport::JSON.decode(creator.first)&.first
  end

  def formatted_creator
    array_of_hash = get_model(self.creator, self['has_model_ssim'].first, 'creator', 'creator_position')
    array_of_hash&.map { |c| [c['creator_family_name'], c['creator_given_name']].join(', ') } || []
  end

  def formatted_editor
    #array_of_hash = get_model(self.editor, self['has_model_ssim'].first, 'editor', 'editor_position')
    #array_of_hash&.map { |c| [c['editor_family_name'], c['editor_given_name']].join(', ') } || []
    # Is editor list something that is hanging around? If so we can just do
    self['editor_list_tesim']
  end
  def formatted_contributor
    array_of_hash = get_model(self.contributor, self['has_model_ssim'].first, 'contributor', 'contributor_position')
    array_of_hash&.map { |c| [c['contributor_family_name'], c['contributor_given_name']].join(', ') } || []
  end

  def formatted_contributor_and_editor
    [formatted_editor, formatted_contributor]
  end

  def year_published
    # Just the year please
    self['date_published_tesim']&.first&.split('-')&.first
  end

  def date_accessed
    # As in date that the citation was accessed, which will always be today
    Date.today.strftime("%Y-%m-%d")
  end

  def endnote_filename
    "#{id}.enw"
  end

  def end_note_format
    {
      '%T' => [:title],
      # '%Q' => [:title, ->(x) { x.drop(1) }], # subtitles
      '%A' => [:formatted_creator],
      '%C' => [:place_of_publication],
      '%D' => [:year_published],
      '%8' => [:date_uploaded],
      '%E' => [:formatted_contributor_and_editor],
      '%I' => [:publisher],
      '%J' => [:series_title],
      '%V' => [:volume],
      '%7' => [:edition],
      '%P' => [:pagination],
      '%@' => [:isbn],
      '%U' => [:related_url],
      '%R' => [:doi],
      '%X' => [:abstract],
      '%G' => [:language],
      '%[' => [:date_accessed],
      '%9' => [:human_readable_type],
      '%~' => I18n.t('hyrax.product_name'),
      '%W' => [:institution]
    }
  end

end
