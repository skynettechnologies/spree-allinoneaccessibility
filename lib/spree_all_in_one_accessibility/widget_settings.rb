require 'active_model'
# `numericality: { in: }` relies on Object#in?, which ActiveModel does not load itself.
require 'active_support/core_ext/object/inclusion'

module SpreeAllInOneAccessibility
  # Widget appearance stored by All in One Accessibility for a website domain.
  # Maps between the admin form, the `api/widget-settings` response and the
  # `api/widget-setting-update-platform` payload.
  class WidgetSettings
    include ActiveModel::Model
    include ActiveModel::Attributes

    # "middel" is the spelling used by the All in One Accessibility API.
    POSITIONS = %w[
      top_left top_center top_right
      middel_left middel_right
      bottom_left bottom_center bottom_right
    ].freeze
    ICON_TYPES = (1..29).map { |number| "aioa-icon-type-#{number}" }.freeze
    # Preview sizes (in pixels) shown in the admin for each predefined icon size.
    ICON_SIZES = {
      'aioa-big-icon' => 75,
      'aioa-medium-icon' => 65,
      'aioa-default-icon' => 55,
      'aioa-small-icon' => 45,
      'aioa-extra-small-icon' => 35
    }.freeze
    X_DIRECTIONS = %w[right left].freeze
    Y_DIRECTIONS = %w[bottom top].freeze
    WIDGET_SIZES = [0, 1].freeze

    DEFAULT_COLOR = '#420083'.freeze
    DEFAULT_POSITION = 'bottom_right'.freeze
    DEFAULT_ICON_TYPE = 'aioa-icon-type-1'.freeze
    DEFAULT_ICON_SIZE = 'aioa-default-icon'.freeze

    HEX_COLOR = /\A#\h{3}(\h{3})?\z/
    CUSTOM_SIZE_RANGE = 20..150
    CUSTOM_OFFSET_RANGE = 0..250

    attribute :widget_color_code, :string, default: DEFAULT_COLOR
    attribute :widget_position, :string, default: DEFAULT_POSITION
    attribute :is_widget_custom_position, :boolean, default: false
    attribute :custom_position_x, :integer, default: 0
    attribute :custom_position_x_direction, :string, default: 'right'
    attribute :custom_position_y, :integer, default: 0
    attribute :custom_position_y_direction, :string, default: 'bottom'
    attribute :widget_size, :integer, default: 0
    attribute :widget_icon_type, :string, default: DEFAULT_ICON_TYPE
    attribute :widget_icon_size, :string, default: DEFAULT_ICON_SIZE
    attribute :is_widget_custom_size, :boolean, default: false
    attribute :widget_icon_size_custom, :integer
    attribute :is_free_widget, :boolean, default: true

    validates :widget_color_code, format: { with: HEX_COLOR }
    validates :widget_position, inclusion: { in: POSITIONS }, unless: :is_widget_custom_position
    validates :custom_position_x, :custom_position_y,
              numericality: { only_integer: true, in: CUSTOM_OFFSET_RANGE }, if: :is_widget_custom_position
    validates :custom_position_x_direction, inclusion: { in: X_DIRECTIONS }, if: :is_widget_custom_position
    validates :custom_position_y_direction, inclusion: { in: Y_DIRECTIONS }, if: :is_widget_custom_position
    validates :widget_size, inclusion: { in: WIDGET_SIZES }
    validates :widget_icon_type, inclusion: { in: ICON_TYPES }
    validates :widget_icon_size, inclusion: { in: ICON_SIZES.keys }, unless: :is_widget_custom_size
    validates :widget_icon_size_custom,
              numericality: { only_integer: true, in: CUSTOM_SIZE_RANGE }, if: :is_widget_custom_size

    # Builds settings from the `Data` object of the `api/widget-settings` response.
    # Unknown or missing values fall back to the defaults.
    def self.from_api(data)
      data = (data || {}).to_h.transform_keys(&:to_s)

      x, x_direction = offset(data['widget_position_right'], data['widget_position_left'], 'right', 'left')
      y, y_direction = offset(data['widget_position_bottom'], data['widget_position_top'], 'bottom', 'top')
      custom_size = to_int(data['widget_icon_size_custom'])
      color = normalize_color(data['widget_color_code'])

      new(
        widget_color_code: color.match?(HEX_COLOR) ? color : DEFAULT_COLOR,
        widget_position: allowed(data['widget_position'], POSITIONS, DEFAULT_POSITION),
        is_widget_custom_position: to_int(data['is_widget_custom_position']) == 1,
        custom_position_x: x,
        custom_position_x_direction: x_direction,
        custom_position_y: y,
        custom_position_y_direction: y_direction,
        widget_size: to_int(data['widget_size']) == 1 ? 1 : 0,
        widget_icon_type: allowed(data['widget_icon_type'], ICON_TYPES, DEFAULT_ICON_TYPE),
        widget_icon_size: allowed(data['widget_icon_size'], ICON_SIZES.keys, DEFAULT_ICON_SIZE),
        is_widget_custom_size: to_int(data['is_widget_custom_size']) == 1,
        widget_icon_size_custom: custom_size.to_i.positive? ? custom_size : nil,
        is_free_widget: (to_int(data['is_free_widget']) || 1) == 1
      )
    end

    # "ff5733", " #FF5733 " => "#FF5733". Invalid values are returned unchanged so validation can report them.
    def self.normalize_color(value)
      color = value.to_s.strip
      hex = color.delete_prefix('#')
      hex.match?(/\A\h{3}(\h{3})?\z/) ? "##{hex.upcase}" : color
    end

    # Accepts integers, floats, numeric strings and booleans as returned by the API.
    def self.to_int(value)
      case value
      when Integer then value
      when Float then value.round
      when true then 1
      when false then 0
      when String then Float(value, exception: false)&.round
      end
    end

    # The API stores one offset per axis (e.g. right OR left); the unused one is null.
    def self.offset(primary, secondary, primary_name, secondary_name)
      primary = to_int(primary)
      secondary = to_int(secondary)

      if primary.to_i.positive? then [primary, primary_name]
      elsif secondary.to_i.positive? then [secondary, secondary_name]
      elsif primary.nil? && !secondary.nil? then [secondary, secondary_name]
      else [primary.to_i, primary_name]
      end
    end

    def self.allowed(value, allowed_values, default)
      allowed_values.include?(value) ? value : default
    end

    private_class_method :offset

    def widget_color_code=(value)
      super(self.class.normalize_color(value))
    end

    # Form fields for the `api/widget-setting-update-platform` endpoint.
    def to_update_fields(domain)
      x = custom_position_x.to_i.clamp(CUSTOM_OFFSET_RANGE).to_s
      y = custom_position_y.to_i.clamp(CUSTOM_OFFSET_RANGE).to_s
      right = custom_position_x_direction != 'left'
      bottom = custom_position_y_direction != 'top'

      {
        'u' => domain.to_s,
        'widget_position' => self.class.allowed(widget_position, POSITIONS, DEFAULT_POSITION),
        'is_widget_custom_position' => is_widget_custom_position ? '1' : '0',
        'is_widget_custom_size' => is_widget_custom_size ? '1' : '0',
        'widget_color_code' => widget_color_code.to_s,
        'widget_icon_type' => widget_icon_type.to_s,
        'widget_icon_size' => self.class.allowed(widget_icon_size, ICON_SIZES.keys, DEFAULT_ICON_SIZE),
        'widget_size' => widget_size.to_i == 1 ? '1' : '0',
        'widget_icon_size_custom' => widget_icon_size_custom.to_i.positive? ? widget_icon_size_custom.to_s : '',
        'widget_position_right' => right ? x : '',
        'widget_position_left' => right ? '' : x,
        'widget_position_bottom' => bottom ? y : '',
        'widget_position_top' => bottom ? '' : y
      }
    end

    def icon_url(icon_type = widget_icon_type)
      "https://www.skynettechnologies.com/sites/default/files/#{icon_type}.svg"
    end

    # `<input type="color">` accepts only lowercase #rrggbb.
    def color_picker_value
      hex = widget_color_code.to_s.delete_prefix('#').downcase
      hex = hex.chars.map { |char| char * 2 }.join if hex.match?(/\A\h{3}\z/)
      hex.match?(/\A\h{6}\z/) ? "##{hex}" : DEFAULT_COLOR.downcase
    end

    # Pixel size shown in the custom size preview.
    def preview_size
      if is_widget_custom_size && CUSTOM_SIZE_RANGE.cover?(widget_icon_size_custom.to_i)
        widget_icon_size_custom
      else
        ICON_SIZES.fetch(widget_icon_size, ICON_SIZES[DEFAULT_ICON_SIZE])
      end
    end
  end
end
