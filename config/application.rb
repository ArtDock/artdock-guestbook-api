require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PoapappApi
  class Application < Rails::Application
    # Permit cross origin
    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins "http://localhost:8080", 'https://poap-app-hosting.web.app'
    #     resource "*",
    #       headers: :any,
    #       expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
    #       methods: [:get, :post, :options, :head, :delete]
    #       # credentials: true
    #   end
    # end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    # ここを1つコメントアウトした
    # config.middleware.use ActionDispatch::Flash
    # Cookies
    # ここを4つコメントアウトした
    # config.middleware.use ActionDispatch::Cookies
    # config.middleware.use ActionDispatch::Session::CookieStore
    # config.action_controller.default_protect_from_forgery = false
    # config.session_store :cookie_store, secure: Rails.env.production?
    # ここを一つ足した
    config.paths.add 'lib', eager_load: true

    # 環境変数の設定
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end
end
