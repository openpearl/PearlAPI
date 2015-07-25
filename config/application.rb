require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PearlAPI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    config.middleware.use Rack::MethodOverride

    # TODO: Not sure if the middleware belongs in this location.
    # Ensure Rack::Cors to run before Warden::Manager used by Devise.
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*',
          :headers => :any,
          :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
          :methods => [:get, :post, :put, :patch, :delete, :options]


    # config.middleware.insert_before Warden::Manager, Rack::Cors do
    #   allow do
    #     origins '*'
    #     resource '*',
    #     :headers => :any,
    #     :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
    #     :methods => [:get, :post, :put, :patch, :delete, :options]
      end
    end
    
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    
    # config.middleware.use Session Management

    config.secret_key_base = Figaro.env.secret_key_base
  end
end
