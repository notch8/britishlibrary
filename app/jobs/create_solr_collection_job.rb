# frozen_string_literal: true

# Create a new account-specific Solr collection using the base templates
class CreateSolrCollectionJob < ApplicationJob
  non_tenant_job

  ##
  # @param [Account]
  def perform(account)
    name = account.tenant.parameterize

    perform_for_cross_search_tenant(account, name) if account.is_shared_search_enabled? && account.tenant_list.present?
    perform_for_normal_tenant(account, name) unless account.is_shared_search_enabled? && account.tenant_list.present?

    account.add_parent_id_to_child
  end

  def without_account(name, tenant_list = '')
    return if collection_exists?(name)
    if tenant_list.present?
      client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                             name: name, collections: tenant_list)
    else
      client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATE',
                                                                             name: name)
    end
  end

  # Transform settings from nested, snaked-cased options to flattened, camel-cased options
  class CollectionOptions
    attr_reader :settings

    def initialize(settings = {})
      @settings = settings
    end

    ##
    # @example Camel-casing
    #   { replication_factor: 5 } # => { "replicationFactor" => 5 }
    # @example Blank-rejecting
    #   { emptyValue: '' } #=> { }
    # @example Nested value-flattening
    #   { collection: { config_name: 'x' } } # => { 'collection.configName' => 'x' }
    def to_h
      Hash[*settings.map { |k, v| transform_entry(k, v) }.flatten].reject { |_k, v| v.blank? }.symbolize_keys
    end

    private

      def transform_entry(k, v)
        case v
        when Hash
          v.map do |k1, v1|
            ["#{transform_key(k)}.#{transform_key(k1)}", v1]
          end
        else
          [transform_key(k), v]
        end
      end

      def transform_key(k)
        k.to_s.camelize(:lower)
      end
  end

  private

    def client
      Blacklight.default_index.connection
    end

    def collection_options
      CollectionOptions.new(Settings.solr.collection_options.to_hash).to_h
    end

    def collection_exists?(name)
      response = client.get '/solr/admin/collections', params: { action: 'LIST' }
      collections = response['collections']

      collections.include? name
    end

    def collection_url(name)
      normalized_uri = if Settings.solr.url.ends_with?('/')
                         Settings.solr.url
                       else
                         "#{Settings.solr.url}/"
                       end

      uri = URI(normalized_uri) + name

      uri.to_s
    end

    def add_solr_endpoint_to_account(account, name)
      account.create_solr_endpoint(url: collection_url(name), collection: name)
    end

    def perform_for_normal_tenant(account, name)
      unless collection_exists? name
        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATE',
                                                                               name: name)
      end
       add_solr_endpoint_to_account(account, name)
    end

    def perform_for_cross_search_tenant(account, name)
      account_children = account.children.map(&:tenant)
      tenants_from_edit = account.tenant_list - account_children
      tenant_list = account.tenant_list.join(',')

      if tenants_from_edit.present?
        solr_options = account.solr_endpoint.connection_options.dup
        RemoveSolrCollectionJob.perform_now(name, solr_options, 'cross_search_tenant')
        create_shared_search_collection(tenant_list, name)
        account.solr_endpoint.update(url: collection_url(name), collection: name)
      else
        create_shared_search_collection(tenant_list, name)
        account.create_solr_endpoint(url: collection_url(name), collection: name)
      end
    end

    def create_shared_search_collection(tenant_list, name)
      unless collection_exists? name
        client.get '/solr/admin/collections', params: collection_options.merge(action: 'CREATEALIAS',
                                                                               name: name, collections: tenant_list)
      end
    end
end
