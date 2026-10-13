require 'uri'

module SpreeAllInOneAccessibility
  module WidgetScript
    # The `id` attribute expected by the widget script.
    ELEMENT_ID = 'aioa-adawidget'.freeze

    module_function

    # The widget applies the color, icon, size and position saved for the visited domain itself,
    # so only the license key (token) of a paid plan is passed in the URL.
    def url(token: nil, script_url: SpreeAllInOneAccessibility.config.script_url)
      query = URI.encode_www_form(colorcode: '', token: token.to_s.strip, position: 'bottom_right')
      "#{script_url}?#{query}"
    end
  end
end
