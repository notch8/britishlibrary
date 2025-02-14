# OVERRIDE Hyrax 2.9.6 for IRUS Analytics

require 'aws-sdk-s3'

module Hyrax
  class DownloadsController < ApplicationController
    include Hydra::Controller::DownloadBehavior
    include Hyrax::LocalFileDownloadsControllerBehavior
    include IrusAnalytics::Controller::AnalyticsBehaviour

    helper Hyrax::IrusHelper

    def self.default_content_path
      :original_file
    end

    # Render the 404 page if the file doesn't exist.
    # Otherwise renders the file.
    def show
      case file
      when ActiveFedora::File
        # For original files that are stored in fedora
        send_irus_analytics_request
        super
      when String
        # For derivatives stored on the local file system
        send_local_content
      else
        raise ActiveFedora::ObjectNotFoundError
      end
    end

    # OVERRIDE Hyrax 2.9.6 for IRUS Analytics
    def item_identifier_for_irus_analytics
      # return the OAI identifier
      helpers.oai_identifier(self, params[:id])
    end

    private

      # OVERRIDE Hyrax 2.9.6 allow downloading directly from S3
      def send_file_contents
        if ENV['S3_DOWNLOADS']
          #s3_object = Aws::S3::Object.new(ENV['AWS_BUCKET'], file.digest.first.to_s.gsub('urn:sha1:', ''))
          s3_object = if asset.respond_to?(:s3_only) && asset.s3_only
                        Aws::S3::Object.new(ENV['AWS_BUCKET'], asset.s3_only)
                      else
                        Aws::S3::Object.new(ENV['AWS_BUCKET'], file.digest.first.to_s.gsub('urn:sha1:', ''))
                      end
    #      if s3_object.exists?
            STDERR.puts "##################################"
            STDERR.puts "Redirecting to S3 using the filename #{file.original_name}"
            STDERR.puts "File object: #{file}"
            redirect_to s3_object.presigned_url(
              :get,
              expires_in: 3600,
              response_content_disposition: "attachment\; filename=#{file.original_name}"
            )
            return
 #         end
        end
        # from here on this is effectively `super` if this was a decorator
        # will fall back to streaming object via fedora
        self.status = 200
        prepare_file_headers
        stream_body file.stream
      end

      # Override the Hydra::Controller::DownloadBehavior#content_options so that
      # we have an attachement rather than 'inline'
      def content_options
        super.merge(disposition: 'attachment')
      end

      # Override this method if you want to change the options sent when downloading
      # a derivative file
      def derivative_download_options
        { type: mime_type_for(file), disposition: 'inline' }
      end

      # Customize the :read ability in your Ability class, or override this method.
      # Hydra::Ability#download_permissions can't be used in this case because it assumes
      # that files are in a LDP basic container, and thus, included in the asset's uri.
      def authorize_download!
        authorize! :download, params[asset_param_key]
      rescue CanCan::AccessDenied
        unauthorized_image = Rails.root.join("app", "assets", "images", "unauthorized.png")
        if File.exist? unauthorized_image
          send_file unauthorized_image, status: :unauthorized
        else
          Deprecation.warn(self, "redirect_to default_image is deprecated and will be removed from Hyrax 3.0 (copy unauthorized.png image to directory assets/images instead)")
          redirect_to default_image
        end
      end

      def default_image
        ActionController::Base.helpers.image_path 'default.png'
      end

      # Overrides Hydra::Controller::DownloadBehavior#load_file, which is hard-coded to assume files are in BasicContainer.
      # Override this method to change which file is shown.
      # Loads the file specified by the HTTP parameter `:file`.
      # If this object does not have a file by that name, return the default file
      # as returned by {#default_file}
      # @return [ActiveFedora::File, File, NilClass] Returns the file from the repository or a path to a file on the local file system, if it exists.
      def load_file
        file_reference = params[:file]
        return default_file unless file_reference

        file_path = Hyrax::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
        File.exist?(file_path) ? file_path : nil
      end

      def default_file
        default_file_reference = if asset.class.respond_to?(:default_file_path)
                                   asset.class.default_file_path
                                 else
                                   DownloadsController.default_content_path
                                 end
        association = dereference_file(default_file_reference)
        association&.reader
      end

      def mime_type_for(file)
        MIME::Types.type_for(File.extname(file)).first.content_type
      end

      def dereference_file(file_reference)
        return false if file_reference.nil?
        association = asset.association(file_reference.to_sym)
        association if association && association.is_a?(ActiveFedora::Associations::SingularAssociation)
      end
  end
end
