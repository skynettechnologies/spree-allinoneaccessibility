# Loads only the plain Ruby classes, so these specs run without a Spree application:
#   bundle exec rspec spec/lib
require 'webmock/rspec'

require 'spree_all_in_one_accessibility/version'
require 'spree_all_in_one_accessibility/configuration'
require 'spree_all_in_one_accessibility/domain'
require 'spree_all_in_one_accessibility/widget_settings'
require 'spree_all_in_one_accessibility/widget_script'
require 'spree_all_in_one_accessibility/api_client'
require 'spree_all_in_one_accessibility/store_settings'
