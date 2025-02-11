# OVERRIDE Hydra-works 2.0.0 to deal with fcrepo + s3s inability to upload empty files

module Hydra
  module Works
    module UpdaterDecorator
      def attach_attributes(external_file_url, _filename = nil)
        current_file.content = StringIO.new('-') # anything but blank
        # filename will be the url.... but we will use file_set.label 
        # becuase making the filename the url of an s3 key is problematic for humans
        current_file.original_name = @file_set.label
        current_file.mime_type = "message/external-body; access-type=URL; URL=\"#{external_file_url}\""
      end
    end
  end
end

Hydra::Works::AddExternalFileToFileSet::Updater.prepend(Hydra::Works::UpdaterDecorator)
