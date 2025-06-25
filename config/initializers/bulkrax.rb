# frozen_string_literal: true

if ENV.fetch('HYKU_BULKRAX_ENABLED', false)
  Bulkrax.object_factory = Bulkrax::ObjectFactory

  # rubocop:disable Metrics/BlockLength
  Bulkrax.setup do |config|
    # Add local parsers
    config.parsers += [
      { name: " XML - UKETD DC Parser", class_name: "Bulkrax::XmlEtdDcParser", partial: "xml_fields" }
    ]

    # WorkType to use as the default if none is specified in the import
    # Default is the first returned by Hyrax.config.curation_concerns
    # config.default_work_type = MyWork

    # Path to store pending imports
    # config.import_path = 'tmp/imports'

    # Path to store exports before download
    # config.export_path = 'tmp/exports'

    # Server name for oai request header
    # config.server_name = 'my_server@name.com'

    # Field_mapping for establishing a parent-child relationship (FROM parent TO child)
    # This can be a Collection to Work, or Work to Work relationship
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/contents',
    #     'Bulkrax::CsvEntry'  => 'children'
    #   }
    # By default no parent-child relationships are added
    # config.parent_child_field_mapping = { }

    # Field_mapping for establishing a collection relationship (FROM work TO collection)
    # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # The default value for CSV is collection
    # Add/replace parsers, for example:
    # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

    # Field mappings
    # Create a completely new set of mappings by replacing the whole set as follows
    #   config.field_mappings = {
    #     'Bulkrax::OaiDcParser' => { **individual field mappings go here*** }
    #   }

    config.fill_in_blank_source_identifiers = ->(obj, index) { "#{Site.instance.account.name}-#{obj.importerexporter.id}-#{index}" }
    # although `<field>_researchassociate` and `<field>_staffmember` are invalid properties, we need to account for
    # them or they'll be skipped over in the "add_metadata" bulkrax method. they're converted and removed in has_local_processing.rb
    config.field_mappings['Bulkrax::CsvParser'] = {
      'abstract' => { from: ['abstract'] },
      'access_control_id' => { excluded: true },
      'ethos_access_rights' => { from: ['access_rights'] },
      'add_info' => { from: ['additional_information'] },
      'admin_set_id' => { from: ['admin_set'] },
      'alt_title' => { from: ['alternative_title'] },
      'alternate_identifier' => { from: ['alternate_identifier'], object: 'alternate_identifier' },
      'alternate_identifier_type' => { from: ['alternate_identifier_type'], object: 'alternate_identifier' },
      'alternative_journal_title' => { from: ['alternative_journal_title'] },
      'arkivo_checksum' => { from: ['arkivo_checksum'] },
      'article_num' => { from: ['article_number'] },
      'based_near' => { from: ['based_near'] },
      'bibliographic_citation' => { from: ['bibliograpic_citation'] },
      'book_title' => { from: ['book_title'] },
      'bulkrax_identifier' => { from: ['bulkrax_identifier'], source_identifier: true },
      'collection' => { from: ['collection', 'collection_id'] },
      'contributor_family_name' => { from: ['contributor_family_name'], object: 'contributor' },
      'contributor_given_name' => { from: ['contributor_given_name'], object: 'contributor' },
      'contributor_grid' => { from: ['contributor_grid'], object: 'contributor' },
      'contributor_institutional_relationship' => { from: ['contributor_institutional_relationship'], object: 'contributor', nested_type: 'Array' },
      'contributor_isni' => { from: ['contributor_isni'], object: 'contributor' },
      'contributor_name_type' => { from: ['contributor_name_type'], object: 'contributor' },
      'contributor_orcid' => { from: ['contributor_orcid'], object: 'contributor' },
      'contributor_organization_name' => { from: ['contributor_organization_name', 'contributor_organisation_name'], object: 'contributor' },
      'contributor_researchassociate' => { from: ['contributor_researchassociate'], object: 'contributor' },
      'contributor_ror' => { from: ['contributor_ror'], object: 'contributor' },
      'contributor_staffmember' => { from: ['contributor_staffmember'], object: 'contributor' },
      'contributor_type' => { from: ['contributor_type'], object: 'contributor' },
      'contributor_wikidata' => { from: ['contributor_wikidata'], object: 'contributor' },
      'creator_family_name' => { from: ['creator_family_name'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_given_name' => { from: ['creator_given_name'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_grid' => { from: ['creator_grid'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_institutional_relationship' => { from: ['creator_institutional_relationship'], object: 'creator', skip_object_for_model_names: ['FileSet'], nested_type: 'Array' },
      'creator_isni' => { from: ['creator_isni'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_name_type' => { from: ['creator_name_type'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_orcid' => { from: ['creator_orcid'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_organization_name' => { from: ['creator_organization_name', 'creator_organisation_name'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_researchassociate' => { from: ['creator_researchassociate'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_ror' => { from: ['creator_ror'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_staffmember' => { from: ['creator_staffmember'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_type' => { from: ['creator_type'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_wikidata' => { from: ['creator_wikidata'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'current_he_institution_name' => { from: ['current_he_institution_name'], object: 'current_he_institution' },
      'date_accepted' => { from: ['date_accepted'] },
      'date_published' => { from: ['date_published_1'] },
      'date_submitted' => { from: ['date_submitted'] },
      'depositor' => { from: ['depositor'] },
      'description' => { from: ['description'] },
      'dewey' => { from: ['dewey_classification'] },
      'disable_draft_doi' => { excluded: true },
      'doi' => { from: ['doi'] },
      'doi_options' => { excluded: true },
      'draft_doi' => { excluded: true },
      'duration' => { from: ['duration'] },
      'edition' => { from: ['edition'] },
      'editor_family_name' => { from: ['editor_family_name'], object: 'editor' },
      'editor_given_name' => { from: ['editor_given_name'], object: 'editor' },
      'editor_institutional_relationship' => { from: ['editor_institutional_relationship'], object: 'editor', nested_type: 'Array' },
      'editor_isni' => { from: ['editor_isni'], object: 'editor' },
      'editor_name_type' => { from: ['editor_name_type'], object: 'editor' },
      'editor_orcid' => { from: ['editor_orcid'], object: 'editor' },
      'editor_organization_name' => { from: ['editor_organization_name', 'editor_organisation_name'], object: 'editor' },
      'editor_researchassociate' => { from: ['editor_researchassociate'], object: 'editor' },
      'editor_staffmember' => { from: ['editor_staffmember'], object: 'editor' },
      'eissn' => { from: ['eissn'] },
      'embargo_id' => { excluded: true },
      'event_date' => { from: ['event_date'] },
      'event_location' => { from: ['event_location'] },
      'event_title' => { from: ['event_title'] },
      'file_availability' => { from: ['file_availability'] },
      'fndr_project_ref' => { from: ['fndr_project_ref'] },
      'funder_award' => { from: ['funder_award'], object: "funder", nested_type: 'Array' },
      'funder_doi' => { from: ['funder_doi'], object: "funder" },
      'funder_isni' => { from: ['funder_isni'], object: "funder" },
      'funder_name' => { from: ['funder_name'], object: "funder" },
      'funder_position' => { from: ['funder_position'], object: "funder" },
      'funder_ror' => { from: ['funder_ror'], object: "funder" },
      'identifier' => { from: ['identifier'] },
      'id' => { from: ['id'] },
      'institution' => { from: ['institution'] },
      'isbn' => { from: ['isbn'] },
      'issn' => { from: ['issn'] },
      'issue' => { from: ['issue'] },
      'journal_title' => { from: ['journal_title'] },
      'keyword' => { from: ['keyword'] },
      'label' => { excluded: true },
      'language' => { from: ['language'] },
      'lease_id' => { excluded: true },
      'library_of_congress_classification' => { from: ['library_of_congress_classification'] },
      'license' => { from: ['license', 'licence'] },
      'media' => { from: ['material_media'] },
      'model' => { from: ['model', 'work_type'] },
      'official_link' => { from: ['official_url'] },
      'on_behalf_of' => { excluded: true },
      'org_unit' => { from: ['organizational_unit', 'organisational_unit'] },
      'owner' => { excluded: true },
      'pagination' => { from: ['pagination'] },
      'place_of_publication' => { from: ['place_of_publication'] },
      'project_name' => { from: ['project_name'] },
      'proxy_depositor' => { excluded: true },
      'publisher' => { from: ['publisher'] },
      'qualification_level' => { from: ['qualification_level'] },
      'qualification_name' => { from: ['qualification_name'] },
      'record_level_file_version_declaration' => { from: ['file_declaration'] },
      'refereed' => { from: ['peer_reviewed'] },
      'related_exhibition' => { from: ['related_exhibition'] },
      'related_exhibition_date' => { from: ['related_exhibition_date'] },
      'related_exhibition_venue' => { from: ['related_exhibition_venue'] },
      'related_identifier' => { from: ['related_identifier'], object: 'related_identifier' },
      'related_identifier_type' => { from: ['related_identifier_type'], object: 'related_identifier' },
      'related_url' => { from: ['related_url'] },
      'relation_type' => { from: ['relation_type'], object: 'related_identifier' },
      'relative_path' => { excluded: true },
      'remote_files' => { from: ['file_url'], parsed: true },
      'rendering_ids' => { excluded: true },
      'representative_id' => { from: ['representative_id'] },
      'resource_type' => { from: ['resource_type'] },
      'rights_holder' => { from: ['rights_holder'] },
      'rights_statement' => { from: ['rights_statement'] },
      'series_name' => { from: ['series_name'] },
      'source' => { from: ['source'] },
      'state' => { from: ['state'] },
      'subject' => { from: ['subject'] },
      'tail' => { excluded: true },
      'thumbnail_id' => { excluded: true },
      'title' => { from: ['title'] },
      'version' => { from: ['version'] },
      'version_number' => { excluded: true },
      'volume' => { from: ['volume'] }
    }

    config.field_mappings['Bulkrax::CsvParser'].merge!(
      'parents' => { from: ['parents'], split: /\s*[;|]\s*/, related_parents_field_mapping: true },
      'children' => { from: ['children'], split: /\s*[;|]\s*/, related_children_field_mapping: true }
    )

    config.field_mappings['Bulkrax::XmlEtdDcParser'] = {
      'abstract' => { from: ['abstract'] },
      'ethos_access_rights' => { from: ['accessRights'] },
      'alt_title' => { from: ['alternative'] },
      'contributor_family_name' => { from: ['advisor'], object: 'contributor' },
      'contributor_given_name' => { from: ['advisor'], object: 'contributor' },
      'contributor_name_type' => { from: ['advisor'], object: 'contributor' },
      'contributor_type' => { from: ['advisor'], object: 'contributor' },
      'contributor_position' => { from: ['advisor'], object: 'contributor' },
      'creator_family_name' => { from: ['creator'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_given_name' => { from: ['creator'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_name_type' => { from: ['creator'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_position' => { from: ['creator'], object: 'creator', skip_object_for_model_names: ['FileSet'] },
      'creator_isni' => { from: ['authoridentifier_isni'], object: 'creator', skip_object_for_model_names: ['FileSet'] }, # type="uketdterms:ISNI"
      'creator_orcid' => { from: ['authoridentifier_orcid'], object: 'creator', skip_object_for_model_names: ['FileSet'] }, # type="uketdterms:ORCID"
      'current_he_institution_name' => { from: ['institution'], object: 'current_he_institution' },
      'date_accepted' => { from: ['issued'] },
      'dewey' => { from: ['subject'] }, # type="dcterms:Ddc"
      'doi' => { from: ['identifier'] }, # type="dcterms:DOI"
      'embargo_date' => { from: ['embargodate'] },
      # 'embargo_date' => { from: ['dcterms:accessRights'] },
      'funder_award' => { from: ['ugrantnumber'], object: "funder", split: /\s*;\s*/ },
      'funder_name' => { from: ['sponsor'], object: "funder" },
      'bulkrax_identifier' => { from: ['source'], source_identifier: true },
      'keyword' => { from: ['coverage'], split: /\s*;\s*/ },
      'language' => { from: ['language'] }, # type="dcterms:ISO639-2"
      'org_unit' => { from: ['department'] },
      'official_link' => { from: ['isReferencedBy'] },
      'publisher' => { from: ['publisher'] },
      'qualification_name' => { from: ['type'] },
      'qualification_level' => { from: ['qualificationlevel'] },
      'title' => { from: ['title'] },
      'parents' => { from: ['parents'], split: /\s*[;|]\s*/, related_parents_field_mapping: true },
      'children' => { from: ['children'], split: /\s*[;|]\s*/, related_children_field_mapping: true },
      'alternate_identifier' => { from: %w[provenance source relation], object: 'alternate_identifier' },
      'alternate_identifier_type' => { from: %w[provenance source relation], object: 'alternate_identifier' }
      #OAI identifier' => dcterms:provenance
      #EThOS identifier' => dc:source
      #Aleph system number => dc:relation
    }
    # Add to, or change existing mappings as follows
    #   e.g. to exclude date
    #   config.field_mappings['Bulkrax::OaiDcParser']['date'] = { from: ['date'], excluded: true  }

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings['Bulkrax::OaiOmekaParser'] = {}
    #   config.field_mappings['Bulkrax::OaiDcParser'].each {|key,value| config.field_mappings['Bulkrax::OaiOmekaParser'][key] = value }

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']
  end
  # rubocop:enable Metrics/BlockLength
end
