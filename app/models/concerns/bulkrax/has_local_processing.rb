# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    set_collections if parsed_metadata&.[]('collection').present?
    parsed_metadata['creator_search'] = parsed_metadata&.[]('creator_search')&.map { |c| c.values.join(', ') }
    set_institutional_relationships

    ['funder', 'creator', 'contributor', 'editor', 'alternate_identifier', 'related_identifier', 'current_he_institution'].each do |key|
      parsed_metadata[key] = [parsed_metadata[key].to_json] if parsed_metadata[key].present?
    end
  end

  def set_collections
    collection_ids = parsed_metadata.delete('collection')
    parsed_metadata['member_of_collections_attributes'] ||= {}
    top_key = parsed_metadata['member_of_collections_attributes'].keys.map {|k| k.to_i}.sort.last || -1

    collection_ids.each do |collection_id|
      next if collection_id.blank?
      top_key += 1
      parsed_metadata['member_of_collections_attributes']["#{top_key}"] = { id: collection_id }
    end
  end

  def set_institutional_relationships
    acceptable_values = {
      'researchassociate': 'Research associate',
      'staffmember': 'Staff member'
    }

    # remove the invalid keys in the array below and use the `<object>_institional_relationship` key only
    ['contributor_researchassociate', 'contributor_staffmember', 'creator_researchassociate', 'creator_staffmember', 'editor_researchassociate', 'editor_staffmember'].each do |field|
      object, relationship = field.split('_')
      key = "#{object}_institutional_relationship"
      if parsed_metadata[object].present?
        parsed_metadata[object].each_with_index do |obj, index|
          next unless parsed_metadata&.[](object)&.[](index)
          # skip if no object or no object at index
          # if object and index are preset, but key is either nil or empty AND obj[field] is present, set the key
          if parsed_metadata[object][index][key]&.first&.blank? && obj[field].present?
            parsed_metadata[object][index][key] = acceptable_values[relationship.to_sym]
          end

          parsed_metadata&.[](object)&.[](index)&.delete(field)
        end
      end
    end
  end
end
