class ExhibitionItem < ActiveFedora::Base
  include Hyrax::WorkBehavior
  include Ubiquity::UniversalMetadata
  include Ubiquity::SharedMetadata
  include Ubiquity::AllModelsVirtualFields
  include Ubiquity::WorksVirtualFields
  include Ubiquity::VersionMetadataModelConcern
  # include Ubiquity::UpdateSharedIndex
  include Ubiquity::FileAvailabilityFaceting
  # include ::Ubiquity::CachingSingle
  # Adds behaviors for hyrax-doi plugin.
  include Hyrax::DOI::DOIBehavior
  # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
  include Hyrax::DOI::DataCiteDOIBehavior
  include IiifPrint.model_configuration(
    pdf_split_child_model: self
  )

  self.indexer = ExhibitionItemIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
