require File.expand_path('../boot', __FILE__)

require "rails"
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Press
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

    config.autoload_paths += %W(#{config.root}/app/models/notebox)

    # http://stackoverflow.com/questions/20361428/rails-i18n-validation-deprecation-warning
    config.i18n.enforce_available_locales = true

    # Use Accel-Redirect for serving files with nginx
    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

    config.action_controller.include_all_helpers = false

    config.assets.paths << "#{Rails.root}/app/assets/fonts"

    config.assets.precompile += [
      "platform.css",
      "composer.css",
      "composer/font-awesome.css",
      "composer.js",
      "mobile-composer.js",
      "jquery.js"
    ]

  end
end
