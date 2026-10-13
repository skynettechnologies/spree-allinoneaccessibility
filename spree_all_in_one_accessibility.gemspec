lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_all_in_one_accessibility/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_all_in_one_accessibility'
  s.version     = SpreeAllInOneAccessibility::VERSION
  s.summary     = 'All in One Accessibility® widget for Spree Commerce'
  s.description = 'All in One Accessibility widget improves website ADA compliance and browser experience for ADA, ' \
                  'WCAG 2.0, 2.1 & 2.2, Section 508, Australian DDA, European EAA EN 301 549, UK Equality Act (EA), ' \
                  'Israeli Standard 5568, California Unruh, Ontario AODA, Canada ACA, German BITV, France RGAA, ' \
                  'Brazilian Inclusion Law (LBI 13.146/2015), Spain UNE 139803:2012, JIS X 8341 (Japan), Italian Stanca Act ' \
                  'and Switzerland DDA Standards. Adds the widget to the Spree storefront and a settings page to the Spree admin.'
  s.required_ruby_version = '>= 3.0'

  s.author   = 'Skynet Technologies USA LLC'
  s.email    = 'hello@skynettechnologies.com'
  s.homepage = 'https://www.skynettechnologies.com/all-in-one-accessibility'
  s.license  = 'MIT'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/skynettechnologies/spree-allinoneaccessibility/issues',
    'changelog_uri' => 'https://github.com/skynettechnologies/spree-allinoneaccessibility/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/skynettechnologies/spree-allinoneaccessibility#readme',
    'source_code_uri' => "https://github.com/skynettechnologies/spree-allinoneaccessibility/tree/v#{s.version}",
    'rubygems_mfa_required' => 'true'
  }

  s.files        = Dir['{app,config,lib}/**/*', 'CHANGELOG.md', 'LICENSE.md', 'README.md']
  s.require_path = 'lib'

  spree_version = ['>= 5.2.0', '< 6.0.0.a']
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_admin', spree_version

  s.add_development_dependency 'spree_dev_tools'
  s.add_development_dependency 'webmock'
end
