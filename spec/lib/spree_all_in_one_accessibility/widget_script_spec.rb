require 'unit_helper'

RSpec.describe SpreeAllInOneAccessibility::WidgetScript do
  let(:script_url) { 'https://www.skynettechnologies.com/accessibility/js/all-in-one-accessibility-js-widget-minify.js' }

  describe '.url' do
    it 'builds the free widget URL' do
      expect(described_class.url).to eq("#{script_url}?colorcode=&token=&position=bottom_right")
    end

    it 'adds the license key of a paid plan' do
      expect(described_class.url(token: ' ABC-123 ')).to eq("#{script_url}?colorcode=&token=ABC-123&position=bottom_right")
    end

    it 'encodes the license key' do
      expect(described_class.url(token: 'a&b=c')).to include('token=a%26b%3Dc&')
    end

    it 'uses the configured script URL' do
      expect(described_class.url(script_url: 'https://cdn.example.com/widget.js')).to start_with('https://cdn.example.com/widget.js?')
    end
  end
end
