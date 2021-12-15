module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include Hyrax::FormTerms
    include ::Ubiquity::AllFormsSharedBehaviour
    include Ubiquity::EditorMetadataFormBehaviour

    self.model_class = ::ConferenceItem
    self.terms += %i[title alt_title resource_type creator contributor abstract date_published institution
                     org_unit project_name funder fndr_project_ref event_title event_location
                     event_date series_name book_title editor volume pagination publisher
                     place_of_publication isbn issn eissn date_accepted date_submitted
                     official_link related_url language license rights_statement rights_holder
                     original_doi draft_doi alternate_identifier related_identifier refereed keyword dewey
                     library_of_congress_classification add_info rendering_ids
                    ]
  end
end
