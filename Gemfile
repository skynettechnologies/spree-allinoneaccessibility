source 'https://rubygems.org'

spree_version = ENV.fetch('SPREE_VERSION', '~> 5.6.1')
gem 'spree', spree_version
gem 'spree_admin', spree_version

gem 'rails-controller-testing'
gem 'spree_dev_tools', '>= 0.6.3'

case ENV['DB']
when 'mysql' then gem 'mysql2'
when 'postgres' then gem 'pg'
else gem 'sqlite3'
end

gem 'propshaft'
gem 'tzinfo-data', platforms: %i[windows jruby]

gemspec
