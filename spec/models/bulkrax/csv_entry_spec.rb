# frozen_string_literal: true

require "spec_helper"

module Bulkrax
  module SpecHelper
    ##
    # @api private
    #
    # A spec helper method for building Bulrax::Entry instances in downstream bulkrax applications.
    #
    # @params identifier [#to_s] The identifier of this object
    # @params data [String] The "data" value for the #raw_metadata of the {Bulkrax::Entry}.
    # @params parser_class_name [String] One of the the named parsers of {Bulkrax.parsers}
    # @params entry_class [Class<Bulkrax::Entry>]
    #
    # @return [Bulkrax::Entry]
    #
    # @todo Extract this method back into a Bulkrax::SpecHelper module.
    # @todo This could replace some of the factories in Bulkrax's spec suite.
    # @note This presently assumes as CSV oriented format; or "We haven't checked this against CSV".
    #       And the signature of this method should be considered volatile.
    def self.build_csv_entry_for(identifier:, data:, parser_class_name:, entry_class:, **kwargs)
      import_file_path = kwargs.fetch(:import_file_path)
      importer = Bulkrax::Importer.new(
        name: "Test importer for identifier #{identifier}",
        admin_set_id: "admin_set/default",
        user_id: 1,
        limit: 1,
        parser_klass: parser_class_name,
        field_mapping: Bulkrax.field_mappings.fetch(parser_class_name),
        parser_fields: { 'import_file_path' => import_file_path }
      )

      entry_class.new(
        importerexporter: importer,
        identifier: identifier,
        raw_metadata: data
      )
    end
  end
end

RSpec.describe Bulkrax::CsvEntry do
  describe "#build_metadata" do
    subject(:entry) do
      Bulkrax::SpecHelper.build_csv_entry_for(
        data: data,
        identifier: identifier,
        parser_class_name: 'Bulkrax::CsvParser',
        entry_class: described_class,
        import_file_path: import_file_path
      )
    end

    context 'basic parser test' do
      let(:import_file_path) { Rails.root.join("spec", "fixtures", "csv", "british-library.csv") }
      let(:identifier) { 'bl-26-0' }
      let(:data) do
        {
          work_type: "ThesisOrDissertation",
          title: "Thesis",
          bulkrax_identifier: identifier,
          access_rights: "true"
        }
      end

      it "assigns factory_class and parsed_metadata" do
        entry.build_metadata
        expect(entry.factory_class).to eq(ThesisOrDissertation)
        expect(entry.parsed_metadata.fetch("ethos_access_rights")).to eq(["true"])
      end
    end

    context 'with production metadata (see https://github.com/notch8/britishlibrary/issues/275)' do
      let(:import_file_path) { Rails.root.join("spec", "fixtures", "csv", "BlackpoolGazetteHerald.csv") }
      let(:identifier) { '123' }
      let(:data) do
        # We're using the fixture CSV for data.
        Bulkrax::CsvEntry.read_data(import_file_path).first.to_h
      end

      it "builds the metadata without exception" do
        # Note the `current_he_institution` column maps to `current_he_institution_name` which is
        # part of a complex bulkrax object that is represented as the property.
        #
        # My suspicion is that we're first adding `current_he_institution` as `""` to the parsed
        # metadata then attempting to handle the complex object.
        entry.build_metadata
        expect(entry.factory_class).to eq(Dataset)
        expect(entry.parsed_metadata.fetch("current_he_institution")).to eq ["[{\"current_he_institution_name\":\"Hello World\"}]"]
      end
    end
  end
end
