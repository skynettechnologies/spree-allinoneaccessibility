require 'spec_helper'

RSpec.describe Spree::Admin::AllInOneAccessibilityController, type: :controller do
  stub_authorization!
  render_views

  let(:store) { @default_store }
  let(:domain) { SpreeAllInOneAccessibility::StoreSettings.new(store).domain_suggestions('test.host').first }
  let(:api_client) { instance_double(SpreeAllInOneAccessibility::ApiClient) }
  let(:remote_settings) do
    SpreeAllInOneAccessibility::WidgetSettings.new(widget_color_code: '#FF5733', widget_icon_type: 'aioa-icon-type-5')
  end

  before do
    allow(SpreeAllInOneAccessibility::ApiClient).to receive(:new).and_return(api_client)
  end

  def saved_store_settings
    SpreeAllInOneAccessibility::StoreSettings.new(store.reload)
  end

  describe 'authorization' do
    before do
      allow_any_instance_of(described_class).to receive(:current_ability).and_return(Spree::Ability.new(nil))
    end

    it 'denies access without store management permission' do
      get :edit

      expect(response).to redirect_to(spree.admin_forbidden_path)
    end
  end

  describe 'GET #edit' do
    it 'shows the widget settings of the store domain' do
      expect(api_client).to receive(:fetch_or_register).with(domain, name: store.name).and_return(remote_settings)

      get :edit

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('value="#FF5733"')
      expect(response.body).to match(/value="aioa-icon-type-5"[^>]*checked|checked[^>]*value="aioa-icon-type-5"/)
      expect(response.body).to include(Spree.t('admin.all_in_one_accessibility.upgrade.stat'))
    end

    it 'keeps the license key field in the form but hidden' do
      SpreeAllInOneAccessibility::StoreSettings.new(store).update(enabled: true, license_key: 'KEY-1', domain: domain)
      allow(api_client).to receive(:fetch_or_register).and_return(remote_settings)

      get :edit

      expect(response.body).to match(/<div class="form-group" hidden>\s*<label for="aioa-license-key"/)
      expect(response.body).to include('name="all_in_one_accessibility[license_key]"', 'value="KEY-1"')
    end

    it 'hides the upgrade banner for a paid plan' do
      remote_settings.is_free_widget = false
      allow(api_client).to receive(:fetch_or_register).and_return(remote_settings)

      get :edit

      expect(response.body).not_to include(Spree.t('admin.all_in_one_accessibility.upgrade.stat'))
    end

    it 'uses the saved domain' do
      SpreeAllInOneAccessibility::StoreSettings.new(store).update(enabled: true, license_key: '', domain: 'shop.example.com')
      expect(api_client).to receive(:fetch_or_register).with('shop.example.com', name: store.name).and_return(remote_settings)

      get :edit

      expect(response.body).to include('value="shop.example.com"')
    end

    it 'explains that a new domain is still being registered' do
      allow(api_client).to receive(:fetch_or_register).and_return(nil)

      get :edit

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(Spree.t('admin.all_in_one_accessibility.registration_pending', domain: domain)))
    end

    it 'shows the defaults when the API cannot be reached' do
      allow(api_client).to receive(:fetch_or_register).and_raise(SpreeAllInOneAccessibility::ApiError, 'timeout')

      get :edit

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(Spree.t('admin.all_in_one_accessibility.api_unavailable')))
      expect(response.body).to include('value="#420083"')
    end
  end

  describe 'PATCH #update' do
    subject(:update) { patch :update, params: params }

    let(:submitted_domain) { domain }
    let(:license_key) { '' }
    let(:widget_settings_params) do
      {
        widget_color_code: '#00aa00',
        widget_position: 'top_left',
        is_widget_custom_position: '0',
        custom_position_x: '10',
        custom_position_x_direction: 'right',
        custom_position_y: '20',
        custom_position_y_direction: 'bottom',
        widget_size: '1',
        widget_icon_type: 'aioa-icon-type-2',
        widget_icon_size: 'aioa-small-icon',
        is_widget_custom_size: '0',
        widget_icon_size_custom: '',
        is_free_widget: '1'
      }
    end
    let(:params) do
      {
        all_in_one_accessibility: { enabled: '0', license_key: license_key, domain: submitted_domain },
        widget_settings: widget_settings_params
      }
    end

    it 'saves the store settings and the widget settings' do
      expect(api_client).to receive(:update_settings).with(
        domain,
        having_attributes(widget_color_code: '#00AA00', widget_position: 'top_left', widget_size: 1,
                          widget_icon_type: 'aioa-icon-type-2', widget_icon_size: 'aioa-small-icon')
      ).and_return(true)

      update

      expect(response).to redirect_to(spree.edit_admin_all_in_one_accessibility_path)
      expect(flash[:success]).to eq(Spree.t('admin.all_in_one_accessibility.saved'))
      expect(saved_store_settings).not_to be_enabled
      expect(saved_store_settings.domain).to eq(domain)
    end

    context 'with a license key' do
      let(:license_key) { ' KEY-123 ' }

      it 'saves it' do
        allow(api_client).to receive(:update_settings).and_return(true)

        update

        expect(saved_store_settings.license_key).to eq('KEY-123')
      end
    end

    context 'with invalid widget settings' do
      before { widget_settings_params.merge!(widget_color_code: 'purple', is_widget_custom_size: '1', widget_icon_size_custom: '5') }

      it 'shows the errors without saving' do
        expect(api_client).not_to receive(:update_settings)

        update

        expect(response).to have_http_status(422)
        expect(response.body).to include('aioa-error-widget_color_code', 'aioa-error-widget_icon_size_custom')
        expect(saved_store_settings.domain).to be_nil
      end
    end

    context 'with an invalid domain' do
      let(:submitted_domain) { 'not a domain' }

      it 'shows an error without saving' do
        expect(api_client).not_to receive(:update_settings)

        update

        expect(response).to have_http_status(422)
        expect(response.body).to include(Spree.t('admin.all_in_one_accessibility.invalid_domain'))
      end
    end

    context 'with an invalid license key' do
      let(:license_key) { '<script>' }

      it 'shows an error without saving' do
        expect(api_client).not_to receive(:update_settings)

        update

        expect(response).to have_http_status(422)
        expect(saved_store_settings.license_key).to eq('')
      end
    end

    context 'with a new domain' do
      let(:submitted_domain) { 'https://New-Shop.example.com/' }

      it 'saves the domain and loads its settings instead of overwriting them' do
        expect(api_client).not_to receive(:update_settings)
        expect(api_client).to receive(:fetch_or_register).with('new-shop.example.com', name: store.name).and_return(remote_settings)

        update

        expect(response).to redirect_to(spree.edit_admin_all_in_one_accessibility_path)
        expect(flash[:success]).to eq(Spree.t('admin.all_in_one_accessibility.domain_changed', domain: 'new-shop.example.com'))
        expect(saved_store_settings.domain).to eq('new-shop.example.com')
      end
    end

    context 'when the API cannot be reached' do
      it 'keeps the submitted values and shows an error' do
        allow(api_client).to receive(:update_settings).and_raise(SpreeAllInOneAccessibility::ApiError, 'HTTP 500')

        update

        expect(response).to have_http_status(422)
        expect(response.body).to include(Spree.t('admin.all_in_one_accessibility.api_error'))
        expect(response.body).to include('value="#00AA00"')
      end
    end
  end
end
