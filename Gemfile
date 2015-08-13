source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails'

gem 'thin'

gem 'rails-api'

gem 'rails_12factor'

gem 'rack-cors', :require => 'rack/cors'

gem 'spring', :group => :development

gem 'omniauth'
gem 'devise'

# Token based authentication for Rails JSON APIs
# Using 0.1.32.beta9 for now until we find a way to fix "no method" bug with using guest account.
gem 'devise_token_auth' , '= 0.1.32.beta9'

gem 'pg'

gem 'figaro'

gem 'bcrypt'


# The pearl engine, including our plugins
gem 'pearl_engine', :git => 'git://github.com/openpearl/PearlEngine.git', :branch => 'master'

# # Local version of Pearl Engine for testing and development
# gem 'pearl_engine', path: "/Users/admin/Desktop/PearlEngine"




group :test, :development do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end
