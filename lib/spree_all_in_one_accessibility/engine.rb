module SpreeAllInOneAccessibility
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_all_in_one_accessibility'

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
