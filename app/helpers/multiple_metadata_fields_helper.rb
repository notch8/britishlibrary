# TODO ~alignment: Bring over remaining methods from BL
module MultipleMetadataFieldsHelper
  def get_model(presenter_record, model_class, field, multipart_sort_field_name = nil)
    #model ||= model_class.constantize.new

    #If the value of the first is record is nil return the model
    #@value =   get_json_data || model
    @value =  presenter_record.first

    if valid_json?(@value)
      array_of_hash ||= JSON.parse(presenter_record.first)
      return  [model.attributes] if (array_of_hash.first.class == String  || array_of_hash.first.nil? )

      #return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name
      return sort_hash(array_of_hash, multipart_sort_field_name) if multipart_sort_field_name

      array_of_hash
    end
  end

  #leave it as a public method because it used in other files
  # return false if json == String
  def valid_json?(data)
    !!JSON.parse(data)  if data.class == String
    rescue JSON::ParserError
      false
  end
end
