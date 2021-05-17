# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  # Generated controller for Image
  class ImagesController < SharedBehaviorsController
    # Adds Hyrax behaviors to the controller.
    self.curation_concern_type = ::Image

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ImagePresenter
  end
end
