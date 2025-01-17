module Bulkrax
  # Override Bulkrax v5.1.0
  module CsvEntryDecorator
    # Without this hack, when we export a FileSet, it skips exporting the FileSet's creator.  This
    # is because we are overloading the `creator` in the parser.  With this change, the complex
    # `creator` object for works will export correctly (e.g. have the constituent field parts in the
    # CSV).  And the FileSet will have a `creator` column.
    #
    # @note There is almost certainly a round-trip issue remaining in that if we import the once
    #       exported CSV, we need to account for the `creator` attribute discrepencies.  Which, at
    #       this point may be irreconcilable unless we have an override parser for FileSets.
    #
    # @see https://github.com/notch8/britishlibrary/issues/289
    def fetch_field_mapping
      field_mappings = super

      return field_mappings if importer?
      return field_mappings unless hyrax_record.is_a?(FileSet)

      field_mappings.merge("creator" => { from: "creator" })
    end
  end
end
Bulkrax::CsvEntry.prepend(Bulkrax::CsvEntryDecorator)
