# OVERRIDE blacklight 6 to allow full url for show links
Blacklight::CatalogHelperBehavior.module_eval do
  def render_thumbnail_tag(document, image_options = {}, url_options = {})
    value = if blacklight_config.view_config(document_index_view_type).thumbnail_method
              send(blacklight_config.view_config(document_index_view_type).thumbnail_method, document, image_options)
            elsif blacklight_config.view_config(document_index_view_type).thumbnail_field
              url = thumbnail_url(document)

              image_tag url, image_options if url.present?
            end

    if value
      if url_options == false
        Deprecation.warn(self, "passing false as the second argument to render_thumbnail_tag is deprecated. Use suppress_link: true instead. This behavior will be removed in Blacklight 7")
        url_options = { suppress_link: true }
      end
      if url_options[:suppress_link]
        value
      elsif url_options[:full_url]
        link_to generate_work_url(document, request) do
          value
        end
      else
        link_to_document document, value, url_options
      end
    end
  end
end
