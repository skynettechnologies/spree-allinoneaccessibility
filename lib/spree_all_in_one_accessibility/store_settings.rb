require 'active_model'
require 'active_support/core_ext/object/try'

module SpreeAllInOneAccessibility
  # Per-store integration settings, kept in the store's private metadata so no migration is needed.
  # The widget appearance itself is stored by All in One Accessibility, see WidgetSettings.
  class StoreSettings
    METADATA_KEY = 'all_in_one_accessibility'.freeze
    LICENSE_KEY_FORMAT = /\A[A-Za-z0-9._-]{0,255}\z/

    attr_reader :store

    def initialize(store)
      @store = store
    end

    def enabled?
      value = data['enabled']
      value.nil? || ActiveModel::Type::Boolean.new.cast(value)
    end

    def license_key
      data['license_key'].to_s
    end

    def domain
      Domain.normalize(data['domain'])
    end

    # Domains the widget is most likely served on, best match first: the headless storefront URL
    # (Spree 5.6+), custom domains, the store URL and finally the host of the current request.
    def domain_suggestions(request_host = nil)
      candidates = [store.try(:preferred_storefront_url), store.try(:default_custom_domain).try(:url)]
      candidates.concat(store.custom_domains.map(&:url)) if store.respond_to?(:custom_domains)
      candidates << store.try(:url) << request_host

      candidates.filter_map { |candidate| Domain.normalize(candidate) }.uniq
    end

    def update(enabled:, license_key:, domain:)
      metadata = (store.private_metadata || {}).to_h
      store.private_metadata = metadata.merge(
        METADATA_KEY => { 'enabled' => enabled, 'license_key' => license_key, 'domain' => domain }
      )
      store.save
    end

    private

    def data
      (store.private_metadata || {}).to_h.fetch(METADATA_KEY, nil).to_h.transform_keys(&:to_s)
    end
  end
end
