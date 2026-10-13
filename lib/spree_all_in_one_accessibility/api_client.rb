require 'json'
require 'net/http'
require 'openssl'
require 'time'
require 'uri'

module SpreeAllInOneAccessibility
  # Raised when the All in One Accessibility API cannot be reached or returns an unexpected response.
  class ApiError < StandardError; end

  # Server-side client for the All in One Accessibility API. Widget settings are stored
  # by All in One Accessibility per website domain, not in the Spree database.
  class ApiClient
    PLATFORM_NAME = 'Spree Commerce'.freeze
    REGISTRATION_ATTEMPTS = 3
    REGISTRATION_DELAY = 1

    NETWORK_ERRORS = [
      IOError, SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError,
      Net::HTTPBadResponse, Net::ProtocolError
    ].freeze

    def initialize(config: SpreeAllInOneAccessibility.config, sleeper: ->(seconds) { sleep(seconds) })
      @config = config
      @sleeper = sleeper
    end

    # Returns nil when the domain is not registered yet.
    def fetch_settings(domain)
      data = parse(post('api/widget-settings', { 'website_url' => domain }))['Data']

      data.is_a?(Hash) && data.any? ? WidgetSettings.from_api(data) : nil
    end

    # Registers the domain for the free widget.
    def register_domain(domain, name:)
      post('api/add-user-domain', registration_fields(domain, name))
      true
    end

    # Returns the settings of the domain, registering it for the free widget first when needed.
    # Returns nil when the settings are still not available after registration.
    def fetch_or_register(domain, name:)
      settings = fetch_settings(domain)
      return settings if settings

      register_domain(domain, name: name)

      # Registration is processed asynchronously by the API.
      REGISTRATION_ATTEMPTS.times do
        @sleeper.call(REGISTRATION_DELAY)
        settings = fetch_settings(domain)
        return settings if settings
      end

      nil
    end

    def update_settings(domain, settings)
      post('api/widget-setting-update-platform', settings.to_update_fields(domain))
      true
    end

    private

    def registration_fields(domain, name)
      {
        'name' => name.to_s,
        'email' => "no-reply@#{domain}",
        'company_name' => '',
        'website' => [domain].pack('m0'),
        'package_type' => 'free-widget',
        'start_date' => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S%z'),
        'end_date' => '',
        'price' => '',
        'discount_price' => '0',
        'platform' => PLATFORM_NAME,
        'api_key' => '',
        'is_trial_period' => '',
        'is_free_widget' => '1',
        'bill_address' => '',
        'country' => '',
        'state' => '',
        'city' => '',
        'post_code' => '',
        'transaction_id' => '',
        'subscr_id' => '',
        'payment_source' => ''
      }
    end

    def post(path, fields)
      uri = URI.join(base_url, path)
      request = Net::HTTP::Post.new(uri)
      request['Accept'] = 'application/json'
      # The API firewall rejects some default client user agents.
      request['User-Agent'] = "spree_all_in_one_accessibility/#{VERSION} (#{PLATFORM_NAME})"
      request.set_form_data(fields)

      response = Net::HTTP.start(uri.host, uri.port,
                                 use_ssl: uri.scheme == 'https',
                                 open_timeout: @config.open_timeout,
                                 read_timeout: @config.read_timeout,
                                 write_timeout: @config.read_timeout) do |http|
        http.request(request)
      end

      raise ApiError, "#{path} responded with HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body.to_s
    rescue *NETWORK_ERRORS => e
      raise ApiError, "#{path} failed: #{e.class}: #{e.message}"
    end

    def parse(body)
      json = JSON.parse(body)
      json.is_a?(Hash) ? json : {}
    rescue JSON::ParserError
      raise ApiError, 'The API returned an invalid JSON response'
    end

    def base_url
      url = @config.api_base_url.to_s
      url.end_with?('/') ? url : "#{url}/"
    end
  end
end
