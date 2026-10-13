module SpreeAllInOneAccessibility
  # Installation-wide settings. Per-store settings (enabled, domain, license key)
  # are managed in the admin, see SpreeAllInOneAccessibility::StoreSettings.
  #
  #   SpreeAllInOneAccessibility.configure do |config|
  #     config.read_timeout = 15
  #   end
  class Configuration
    # Base URL of the All in One Accessibility API. Change only when instructed by Skynet Technologies support.
    attr_accessor :api_base_url

    # URL of the widget script rendered on the storefront.
    attr_accessor :script_url

    # Seconds to wait when opening a connection to / reading a response from the API.
    attr_accessor :open_timeout, :read_timeout

    def initialize
      @api_base_url = 'https://ada.skynettechnologies.us/'
      @script_url = 'https://www.skynettechnologies.com/accessibility/js/all-in-one-accessibility-js-widget-minify.js'
      @open_timeout = 5
      @read_timeout = 10
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end
end
