require 'unit_helper'

RSpec.describe SpreeAllInOneAccessibility::StoreSettings do
  subject(:store_settings) { described_class.new(store) }

  let(:store_class) do
    Struct.new(:private_metadata, :url, :preferred_storefront_url, :saved, keyword_init: true) do
      def save
        self.saved = true
      end
    end
  end
  let(:store) { store_class.new(private_metadata: metadata, url: 'store.example.com') }
  let(:metadata) { {} }

  context 'without saved settings' do
    it 'enables the widget for the free plan' do
      expect(store_settings).to be_enabled
      expect(store_settings.license_key).to eq('')
      expect(store_settings.domain).to be_nil
    end
  end

  context 'with saved settings' do
    let(:metadata) do
      { 'other' => 'value',
        'all_in_one_accessibility' => { 'enabled' => false, 'license_key' => 'KEY-1', 'domain' => 'Shop.Example.com' } }
    end

    it 'reads them' do
      expect(store_settings).not_to be_enabled
      expect(store_settings.license_key).to eq('KEY-1')
      expect(store_settings.domain).to eq('shop.example.com')
    end
  end

  describe '#update' do
    let(:metadata) { { 'other' => 'value' } }

    it 'saves the settings in the private metadata without touching other keys' do
      expect(store_settings.update(enabled: false, license_key: 'KEY-2', domain: 'shop.example.com')).to be(true)

      expect(store.private_metadata).to eq(
        'other' => 'value',
        'all_in_one_accessibility' => { 'enabled' => false, 'license_key' => 'KEY-2', 'domain' => 'shop.example.com' }
      )
      expect(store.saved).to be(true)
    end
  end

  describe '#domain_suggestions' do
    it 'lists the storefront URL first, then the store URL and the request host' do
      store.preferred_storefront_url = 'https://www.shop.example.com'

      expect(store_settings.domain_suggestions('admin.example.com')).to eq(
        %w[www.shop.example.com store.example.com admin.example.com]
      )
    end

    it 'skips blank and duplicate values' do
      store.url = 'https://admin.example.com'

      expect(store_settings.domain_suggestions('admin.example.com')).to eq(%w[admin.example.com])
    end
  end

  describe 'LICENSE_KEY_FORMAT' do
    it 'accepts license keys and an empty value' do
      expect(['', 'abc-123_DEF.4']).to all(match(described_class::LICENSE_KEY_FORMAT))
    end

    it 'rejects other characters' do
      expect(['abc 123', '<script>', 'a&b']).to all(satisfy { |key| !key.match?(described_class::LICENSE_KEY_FORMAT) })
    end
  end
end
