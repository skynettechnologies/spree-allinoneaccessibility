module SpreeAllInOneAccessibility
  # All in One Accessibility identifies websites by host name, the value the widget
  # reads from `window.location.hostname` (no scheme, port or path).
  module Domain
    PATTERN = /\A[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*\z/
    MAX_LENGTH = 253

    module_function

    # "https://www.Example.com:8443/shop?x=1" => "www.example.com"
    # Returns nil when the value is not a valid domain.
    def normalize(value)
      host = value.to_s.strip.downcase
      host = host.sub(%r{\A[a-z][a-z0-9+.-]*://}, '')
      host = host.split(%r{[/?#]}, 2).first.to_s
      host = host.sub(/:\d{1,5}\z/, '')

      host.length <= MAX_LENGTH && host.match?(PATTERN) ? host : nil
    end
  end
end
