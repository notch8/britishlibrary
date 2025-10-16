# frozen_string_literal: true

module Hyrax
  module DOI
    class RegisterDOIJob < ApplicationJob
      include Rails.application.routes.url_helpers
      # For link_to
      include ActionView::Helpers

      queue_as Hyrax.config.ingest_queue_name

      ##
      # @param model [ActiveFedora::Base]
      # @param registrar [String] Note this is a string and not a symbol because ActiveJob cannot serialize a symbol
      # @param registrar_opts [Hash]
      def perform(model, registrar: Hyrax.config.identifier_registrars.keys.first, registrar_opts: {})
        return if model.doi.blank?

        Hyrax::Identifier::Dispatcher
          .for(registrar.to_sym, **registrar_opts)
          .assign_for!(object: model, attribute: :doi)
      # rubocop:disable Style/RescueStandardError
      rescue => e
        user = ::User.find_by(email: model.depositor) if model.depositor

        if user
          Hyrax::MessengerService.deliver(::User.audit_user,
                                          user,
                                          action(model, e),
                                          "DOI failed to mint or update")
        end
        Raven.capture_exception(e)
        # Requeue if this is a datacite connection issue
        raise if e.is_a? Hyrax::DOI::DataCiteClient::Error
      end
      # rubocop:enable Style/RescueStandardError

      def action(model, e)
        "DOI update filed for <a href='#{polymorphic_url(model)}'>#{model.title.first}</a>. Datacite said '#{e.message}'"
      end

      # OVERRIDE Hyrax-DOI 0.2.0 to stop register jobs being started when option to register is "do not mint"
      # By checking that the doi_status_when_public is one of the valid Hyrax::DOI::DataCiteRegistrar::STATES
      # Also move this method to RegisterDOIJob to be accessible from DOI and Embargo Actors

      def self.conditionally_create_or_update_doi_for(work)
        return true unless work.class.ancestors.include?(Hyrax::DOI::DOIBehavior) && Flipflop.enabled?(:doi_minting) && work.doi_status_when_public.in?(Hyrax::DOI::DataCiteRegistrar::STATES)

        Hyrax::DOI::RegisterDOIJob.perform_later(work, registrar: work.doi_registrar.presence, registrar_opts: work.doi_registrar_opts)
      end
    end
  end
end
