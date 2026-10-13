module Spree
  module Admin
    # Settings page of the All in One Accessibility widget.
    # Integration settings are saved on the current store; the widget appearance is saved
    # by All in One Accessibility for the configured domain.
    class AllInOneAccessibilityController < BaseController
      include Spree::Admin::SettingsConcern

      helper do
        def aioa_t(key, **options)
          t(key, scope: 'spree.admin.all_in_one_accessibility', **options)
        end

        def aioa_field_error(settings, attribute)
          messages = settings.errors.full_messages_for(attribute)
          return if messages.empty?

          content_tag(:p, messages.to_sentence, class: 'aioa-field-error', id: "aioa-error-#{attribute}")
        end

        # Field attributes linking the help text and, when present, the error message.
        def aioa_field_aria(settings, attribute, *described_by)
          described_by << "aioa-error-#{attribute}" if settings.errors.include?(attribute)

          { 'aria-invalid': settings.errors.include?(attribute) || nil, 'aria-describedby': described_by.join(' ').presence }
        end
      end

      before_action :load_store_settings
      before_action :add_page_breadcrumb

      # GET /admin/all-in-one-accessibility/edit
      def edit
        @enabled = @store_settings.enabled?
        @license_key = @store_settings.license_key
        @domain = configured_domain
        @widget_settings = load_widget_settings(@domain)
      end

      # PATCH /admin/all-in-one-accessibility
      def update
        @enabled = ActiveModel::Type::Boolean.new.cast(integration_params[:enabled]) || false
        @license_key = integration_params[:license_key].to_s.strip
        @domain = integration_params[:domain].to_s.strip
        @widget_settings = SpreeAllInOneAccessibility::WidgetSettings.new(widget_settings_params)
        domain = SpreeAllInOneAccessibility::Domain.normalize(@domain)

        return render_edit(error: aioa_t(:invalid_domain)) if domain.nil?
        return render_edit(error: aioa_t(:invalid_license_key)) unless @license_key.match?(SpreeAllInOneAccessibility::StoreSettings::LICENSE_KEY_FORMAT)

        # A new domain has its own settings: load them instead of overwriting them with the submitted ones.
        domain_changed = domain != configured_domain
        return render_edit if !domain_changed && @widget_settings.invalid?

        saved = @store_settings.update(enabled: @enabled, license_key: @license_key, domain: domain)
        return render_edit(error: current_store.errors.full_messages.to_sentence) unless saved

        if domain_changed
          api_client.fetch_or_register(domain, name: current_store.name)
          flash[:success] = aioa_t(:domain_changed, domain: domain)
        else
          api_client.update_settings(domain, @widget_settings)
          flash[:success] = aioa_t(:saved)
        end

        redirect_to spree.edit_admin_all_in_one_accessibility_path, status: :see_other
      rescue SpreeAllInOneAccessibility::ApiError => e
        Rails.logger.warn("[All in One Accessibility] #{e.message}")
        render_edit(error: aioa_t(:api_error))
      end

      private

      # Store configuration, the same permission as the other store settings pages.
      def authorize_admin
        authorize! :admin, Spree::Store
        authorize! :update, current_store
      end

      def load_store_settings
        @store_settings = SpreeAllInOneAccessibility::StoreSettings.new(current_store)
        @domain_suggestions = @store_settings.domain_suggestions(request.host)
      end

      def add_page_breadcrumb
        @breadcrumb_icon = 'accessible'
        add_breadcrumb aioa_t(:nav_label), spree.edit_admin_all_in_one_accessibility_path
      end

      def configured_domain
        @store_settings.domain || @domain_suggestions.first
      end

      # Alerts are rendered on the page (not as flash toasts, which disappear after a few seconds).
      def load_widget_settings(domain)
        return SpreeAllInOneAccessibility::WidgetSettings.new if domain.nil?

        settings = api_client.fetch_or_register(domain, name: current_store.name)
        return settings if settings

        @alert = { type: 'warning', message: aioa_t(:registration_pending, domain: domain) }
        SpreeAllInOneAccessibility::WidgetSettings.new
      rescue SpreeAllInOneAccessibility::ApiError => e
        Rails.logger.warn("[All in One Accessibility] #{e.message}")
        @alert = { type: 'danger', message: aioa_t(:api_unavailable) }
        SpreeAllInOneAccessibility::WidgetSettings.new
      end

      def render_edit(error: nil)
        @alert = { type: 'danger', message: error } if error
        render :edit, status: 422
      end

      def api_client
        @api_client ||= SpreeAllInOneAccessibility::ApiClient.new
      end

      def aioa_t(key, **options)
        Spree.t(key, scope: 'admin.all_in_one_accessibility', **options)
      end

      def integration_params
        params.fetch(:all_in_one_accessibility, {}).permit(:enabled, :license_key, :domain)
      end

      def widget_settings_params
        params.fetch(:widget_settings, {}).permit(*SpreeAllInOneAccessibility::WidgetSettings.attribute_names)
      end
    end
  end
end
