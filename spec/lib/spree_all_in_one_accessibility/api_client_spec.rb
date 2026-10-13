require 'unit_helper'

RSpec.describe SpreeAllInOneAccessibility::ApiClient do
  subject(:client) { described_class.new(sleeper: ->(seconds) { sleeps << seconds }) }

  let(:sleeps) { [] }
  let(:api) { 'https://ada.skynettechnologies.us/api' }
  let(:domain) { 'shop.example.com' }
  let(:registered) do
    { 'Data' => { 'widget_position' => 'top_left', 'widget_color_code' => '#FF5733', 'is_free_widget' => 1 } }.to_json
  end
  let(:unregistered) { { 'Data' => [], 'data_feature' => {} }.to_json }

  describe '#fetch_settings' do
    it 'returns the settings of a registered domain' do
      request = stub_request(:post, "#{api}/widget-settings")
                .with(body: { 'website_url' => domain },
                      headers: { 'User-Agent' => %r{\Aspree_all_in_one_accessibility/} })
                .to_return(status: 200, body: registered)

      expect(client.fetch_settings(domain)).to have_attributes(widget_position: 'top_left', widget_color_code: '#FF5733')
      expect(request).to have_been_requested
    end

    it 'returns nil for a domain that is not registered' do
      stub_request(:post, "#{api}/widget-settings").to_return(status: 200, body: unregistered)

      expect(client.fetch_settings(domain)).to be_nil
    end

    it 'raises ApiError for HTTP errors' do
      stub_request(:post, "#{api}/widget-settings").to_return(status: 406, body: '<html>Not Acceptable</html>')

      expect { client.fetch_settings(domain) }.to raise_error(SpreeAllInOneAccessibility::ApiError, /HTTP 406/)
    end

    it 'raises ApiError for network errors' do
      stub_request(:post, "#{api}/widget-settings").to_timeout

      expect { client.fetch_settings(domain) }.to raise_error(SpreeAllInOneAccessibility::ApiError)
    end

    it 'raises ApiError for an invalid response' do
      stub_request(:post, "#{api}/widget-settings").to_return(status: 200, body: '<html></html>')

      expect { client.fetch_settings(domain) }.to raise_error(SpreeAllInOneAccessibility::ApiError, /invalid JSON/)
    end

    it 'uses the configured API URL' do
      config = SpreeAllInOneAccessibility::Configuration.new
      config.api_base_url = 'https://api.example.test/v2'
      request = stub_request(:post, 'https://api.example.test/v2/api/widget-settings').to_return(body: unregistered)

      described_class.new(config: config).fetch_settings(domain)

      expect(request).to have_been_requested
    end
  end

  describe '#register_domain' do
    it 'registers the domain for the free widget' do
      request = stub_request(:post, "#{api}/add-user-domain")
                .with(body: hash_including(
                  'name' => 'My Store',
                  'email' => 'no-reply@shop.example.com',
                  'website' => 'c2hvcC5leGFtcGxlLmNvbQ==',
                  'package_type' => 'free-widget',
                  'is_free_widget' => '1',
                  'platform' => 'Spree Commerce',
                  'start_date' => /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+0000\z/
                ))
                .to_return(status: 200, body: '{}')

      expect(client.register_domain(domain, name: 'My Store')).to be(true)
      expect(request).to have_been_requested
    end
  end

  describe '#fetch_or_register' do
    it 'does not register a domain that is already registered' do
      stub_request(:post, "#{api}/widget-settings").to_return(body: registered)

      expect(client.fetch_or_register(domain, name: 'My Store')).to be_a(SpreeAllInOneAccessibility::WidgetSettings)
      expect(a_request(:post, "#{api}/add-user-domain")).not_to have_been_made
    end

    it 'registers a new domain and waits for its settings' do
      stub_request(:post, "#{api}/widget-settings").to_return({ body: unregistered }, { body: unregistered }, { body: registered })
      registration = stub_request(:post, "#{api}/add-user-domain").to_return(body: '{}')

      expect(client.fetch_or_register(domain, name: 'My Store')).to have_attributes(widget_position: 'top_left')
      expect(registration).to have_been_requested.once
      expect(sleeps).to eq([1, 1])
    end

    it 'gives up when the settings are still not available' do
      settings_request = stub_request(:post, "#{api}/widget-settings").to_return(body: unregistered)
      stub_request(:post, "#{api}/add-user-domain").to_return(body: '{}')

      expect(client.fetch_or_register(domain, name: 'My Store')).to be_nil
      expect(settings_request).to have_been_requested.times(4)
    end
  end

  describe '#update_settings' do
    let(:settings) do
      SpreeAllInOneAccessibility::WidgetSettings.new(widget_color_code: '#FF5733', widget_position: 'top_left')
    end

    it 'saves the settings of the domain' do
      request = stub_request(:post, "#{api}/widget-setting-update-platform")
                .with(body: hash_including('u' => domain, 'widget_color_code' => '#FF5733', 'widget_position' => 'top_left'))
                .to_return(status: 200, body: '{"status":true}')

      expect(client.update_settings(domain, settings)).to be(true)
      expect(request).to have_been_requested
    end

    it 'raises ApiError when saving fails' do
      stub_request(:post, "#{api}/widget-setting-update-platform").to_return(status: 500)

      expect { client.update_settings(domain, settings) }.to raise_error(SpreeAllInOneAccessibility::ApiError)
    end
  end
end
