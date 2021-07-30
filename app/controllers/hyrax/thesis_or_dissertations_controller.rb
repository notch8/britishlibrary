# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ThesisOrDissertation`

module Hyrax
  class ThesisOrDissertationsController < SharedBehaviorsController
    self.curation_concern_type = ::ThesisOrDissertation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ThesisOrDissertationPresenter
  end
end
