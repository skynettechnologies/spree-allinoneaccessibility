require 'unit_helper'

RSpec.describe SpreeAllInOneAccessibility::WidgetSettings do
  subject(:settings) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe 'defaults' do
    it 'matches the free widget defaults' do
      expect(settings).to have_attributes(
        widget_color_code: '#420083',
        widget_position: 'bottom_right',
        widget_icon_type: 'aioa-icon-type-1',
        widget_icon_size: 'aioa-default-icon',
        widget_size: 0,
        is_widget_custom_position: false,
        is_widget_custom_size: false,
        is_free_widget: true
      )
      expect(settings).to be_valid
    end
  end

  describe '#widget_color_code=' do
    { 'ff5733' => '#FF5733', ' #abc ' => '#ABC', '#A1B2C3' => '#A1B2C3' }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        settings.widget_color_code = input
        expect(settings.widget_color_code).to eq(expected)
        expect(settings).to be_valid
      end
    end

    it 'keeps an invalid value so it can be reported' do
      settings.widget_color_code = 'purple'
      expect(settings.widget_color_code).to eq('purple')
      expect(settings).to be_invalid
      expect(settings.errors[:widget_color_code]).to be_present
    end
  end

  describe 'validations' do
    it 'requires a known position' do
      settings.widget_position = 'center'
      expect(settings).to be_invalid
    end

    it 'ignores the predefined position when the custom position is used' do
      settings.assign_attributes(widget_position: 'center', is_widget_custom_position: true, custom_position_x: 20)
      expect(settings).to be_valid
    end

    it 'limits the custom offsets to 0 - 250px' do
      settings.assign_attributes(is_widget_custom_position: true, custom_position_x: 251, custom_position_y: -1)
      expect(settings).to be_invalid
      expect(settings.errors.attribute_names).to include(:custom_position_x, :custom_position_y)
    end

    it 'requires known custom position directions' do
      settings.assign_attributes(is_widget_custom_position: true, custom_position_x_direction: 'up')
      expect(settings).to be_invalid
      expect(settings.errors[:custom_position_x_direction]).to be_present
    end

    it 'requires one of the 29 icon types' do
      settings.widget_icon_type = 'aioa-icon-type-30'
      expect(settings).to be_invalid
    end

    it 'requires a known icon size unless the custom size is used' do
      settings.widget_icon_size = 'huge'
      expect(settings).to be_invalid

      settings.assign_attributes(is_widget_custom_size: true, widget_icon_size_custom: 80)
      expect(settings).to be_valid
    end

    it 'limits the custom icon size to 20 - 150px' do
      settings.assign_attributes(is_widget_custom_size: true, widget_icon_size_custom: 19)
      expect(settings).to be_invalid

      settings.widget_icon_size_custom = 151
      expect(settings).to be_invalid

      settings.widget_icon_size_custom = nil
      expect(settings).to be_invalid
    end

    it 'accepts regular and oversize widgets only' do
      settings.widget_size = 2
      expect(settings).to be_invalid
    end
  end

  describe '.from_api' do
    # Shape returned by api/widget-settings for a registered domain.
    let(:data) do
      {
        'widget_position' => 'top_left',
        'widget_color_code' => '#ff5733',
        'widget_icon_type' => 'aioa-icon-type-7',
        'widget_icon_size' => 'aioa-medium-icon',
        'widget_position_top' => nil,
        'widget_position_right' => nil,
        'widget_position_bottom' => 150,
        'widget_position_left' => 15,
        'widget_icon_size_custom' => 0,
        'is_widget_custom_position' => 1,
        'is_widget_custom_size' => 0,
        'widget_size' => 1,
        'is_free_widget' => 0
      }
    end

    it 'maps the API values' do
      expect(described_class.from_api(data)).to have_attributes(
        widget_position: 'top_left',
        widget_color_code: '#FF5733',
        widget_icon_type: 'aioa-icon-type-7',
        widget_icon_size: 'aioa-medium-icon',
        is_widget_custom_position: true,
        custom_position_x: 15,
        custom_position_x_direction: 'left',
        custom_position_y: 150,
        custom_position_y_direction: 'bottom',
        is_widget_custom_size: false,
        widget_icon_size_custom: nil,
        widget_size: 1,
        is_free_widget: false
      )
    end

    it 'accepts numbers sent as strings and booleans' do
      settings = described_class.from_api(data.merge('widget_icon_size_custom' => '80', 'is_widget_custom_size' => true,
                                                     'widget_position_right' => '30.0'))

      expect(settings).to have_attributes(widget_icon_size_custom: 80, is_widget_custom_size: true,
                                          custom_position_x: 30, custom_position_x_direction: 'right')
    end

    it 'keeps an explicit zero offset on the left / top' do
      settings = described_class.from_api(data.merge('widget_position_left' => 0, 'widget_position_bottom' => nil,
                                                     'widget_position_top' => 0))

      expect(settings).to have_attributes(custom_position_x: 0, custom_position_x_direction: 'left',
                                          custom_position_y: 0, custom_position_y_direction: 'top')
    end

    it 'falls back to the defaults for missing or unknown values' do
      settings = described_class.from_api('widget_color_code' => 'red', 'widget_icon_type' => 'aioa-icon-type-99',
                                          'widget_icon_size' => 'huge', 'widget_position' => 'center')

      expect(settings).to have_attributes(
        widget_color_code: '#420083',
        widget_icon_type: 'aioa-icon-type-1',
        widget_icon_size: 'aioa-default-icon',
        widget_position: 'bottom_right',
        custom_position_x: 0,
        custom_position_x_direction: 'right',
        is_free_widget: true
      )
      expect(settings).to be_valid
    end

    it 'handles an empty response' do
      expect(described_class.from_api(nil)).to be_valid
    end
  end

  describe '#to_update_fields' do
    let(:attributes) do
      {
        widget_color_code: '#FF5733',
        widget_position: 'top_right',
        is_widget_custom_position: true,
        custom_position_x: 40,
        custom_position_x_direction: 'right',
        custom_position_y: 60,
        custom_position_y_direction: 'bottom',
        widget_size: 1,
        widget_icon_type: 'aioa-icon-type-3',
        widget_icon_size: 'aioa-small-icon',
        is_widget_custom_size: true,
        widget_icon_size_custom: 90
      }
    end

    it 'builds the payload of api/widget-setting-update-platform' do
      expect(settings.to_update_fields('shop.example.com')).to eq(
        'u' => 'shop.example.com',
        'widget_position' => 'top_right',
        'is_widget_custom_position' => '1',
        'is_widget_custom_size' => '1',
        'widget_color_code' => '#FF5733',
        'widget_icon_type' => 'aioa-icon-type-3',
        'widget_icon_size' => 'aioa-small-icon',
        'widget_size' => '1',
        'widget_icon_size_custom' => '90',
        'widget_position_right' => '40',
        'widget_position_left' => '',
        'widget_position_bottom' => '60',
        'widget_position_top' => ''
      )
    end

    it 'sends the offsets to the left and top' do
      settings.assign_attributes(custom_position_x_direction: 'left', custom_position_y_direction: 'top')

      expect(settings.to_update_fields('shop.example.com')).to include(
        'widget_position_right' => '', 'widget_position_left' => '40',
        'widget_position_bottom' => '', 'widget_position_top' => '60'
      )
    end

    it 'sends safe values for the options that are not in use' do
      settings.assign_attributes(is_widget_custom_size: false, widget_icon_size_custom: nil,
                                 widget_position: 'center', custom_position_x: 999)

      expect(settings.to_update_fields('shop.example.com')).to include(
        'is_widget_custom_size' => '0', 'widget_icon_size_custom' => '',
        'widget_position' => 'bottom_right', 'widget_position_right' => '250'
      )
    end
  end

  describe '#color_picker_value' do
    { '#ABC' => '#aabbcc', '#FF5733' => '#ff5733', 'purple' => '#420083' }.each do |color, expected|
      it "returns #{expected} for #{color}" do
        settings.widget_color_code = color
        expect(settings.color_picker_value).to eq(expected)
      end
    end
  end

  describe '#preview_size' do
    it 'uses the predefined icon size' do
      settings.widget_icon_size = 'aioa-big-icon'
      expect(settings.preview_size).to eq(75)
    end

    it 'uses the custom icon size when enabled' do
      settings.assign_attributes(is_widget_custom_size: true, widget_icon_size_custom: 120)
      expect(settings.preview_size).to eq(120)
    end
  end

  describe '#icon_url' do
    it 'points to the icon of the selected type' do
      settings.widget_icon_type = 'aioa-icon-type-12'
      expect(settings.icon_url).to eq('https://www.skynettechnologies.com/sites/default/files/aioa-icon-type-12.svg')
    end
  end
end
