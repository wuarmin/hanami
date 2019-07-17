# frozen_string_literal: true

require "dry/system/container"
require "hanami/loaders/action"
require "hanami/loaders/view"
require "hanami/utils/file_list"
require "pathname"

module Hanami
  # Hanami private IoC
  #
  # @since 2.0.0
  #
  # rubocop:disable Metrics/ClassLength
  class Container < Dry::System::Container
    configure do |config|
      config.root = Pathname.new(Dir.pwd)
    end

    # This makes it possible to properly require files from within sub-app dirs,
    # e.g. `require "web/view"`.
    #
    # This is a temporary measure; we need to have a real discussion about
    # container/sub-app setup and file loading in general.
    load_paths! "apps"

    boot(:env) do |c|
      init do
        begin
          require "dotenv"
        rescue LoadError # rubocop:disable Lint/HandleExceptions
        end

        Dotenv.load(c.root.join(".env")) if defined?(Dotenv)
      end
    end

    boot(:lib) do |c|
      init do
        $LOAD_PATH.unshift c.root.join("lib")
        Hanami::Utils.require!(c.root.join("lib", "**", "*.rb"))
      end
    end

    boot(:configuration) do |c|
      init do
        require c.root.join("config", "application").to_s
      end

      start do
        register(:configuration, Hanami.application_class.configuration.finalize)
      end
    end

    boot(:logger) do |c|
      init do
        require "hanami/logger"
      end

      start do
        use :configuration
        register(:logger, Hanami::Logger.new(c[:configuration].logger))
      end
    end

    boot(:routes) do |c|
      init do
        require c.root.join("config", "routes").to_s
      end

      start do
        register(:routes, Hanami.application_class.routes)
      end
    end

    boot(:apps) do |c|
      start do
        use :routes

        register(:apps, c[:routes].apps)
      end
    end

    boot(:actions) do |c|
      init do
        use :configuration
        use :apps

        loader = Loaders::Action.new(c[:configuration].inflections)

        c[:apps].each do |app|
          require c.root.join("apps", app.to_s, "action").to_s

          configuration = Controller::Configuration.new do |config|
            config.cookies                 = c[:configuration].cookies.options
            config.default_headers         = c[:configuration].security.to_hash
            config.default_request_format  = c[:configuration].default_request_format
            config.default_response_format = c[:configuration].default_response_format
          end

          Hanami::Utils::FileList[c.root, "apps", app.to_s, "actions", "**", "*.rb"].each do |path|
            action = loader.call(app, path, configuration)
            register(:"apps.#{action.name}", action) unless action.nil?
          end

          namespace = Utils::String.classify("#{app}::Actions")
          namespace = Utils::Class.load!(namespace)

          register(:"apps.#{app}.actions.namespace", namespace)
        end
      end
    end

    boot(:views) do |c| # rubocop:disable Metrics/BlockLength
      init do
        use :apps
        use :configuration

        loader = Loaders::View.new(c[:configuration].inflections)

        c[:apps].each do |app|
          Hanami::Utils::FileList[c.root, "apps", app.to_s, "views", "**", "*.rb"].each do |path|
            view = loader.call(app, path)
            register(:"apps.#{view.name}", view) if view
          end
        end
      end
    end

    boot(:code) do |c|
      init do
        use :configuration
        use :apps
        use :actions
        use :views

        apps = c[:apps].join(",")
        Hanami::Utils.require!(c.root.join("apps", "{#{apps}}", "**", "*.rb"))
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
