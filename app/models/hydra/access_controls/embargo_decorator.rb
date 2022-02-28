# OVERRIDE Hydra-access-controls 12.0.1
# Fix releasing embargos on the day they are expired - this solves a 1 second bug around how
# midnights are calculated, which causes day of embargos to incorrectly set the permissions to private
module Hydra
  module AccessControls
    module EmbargoDecorator
      def active?
        (embargo_release_date.present? && Time.zone.today.end_of_day < embargo_release_date)
      end
    end
  end
end

Hydra::AccessControls::Embargo.prepend(Hydra::AccessControls::EmbargoDecorator)
