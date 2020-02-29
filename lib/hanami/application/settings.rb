# frozen_string_literal: true

require "dry/configurable"
require "dry/core/constants"
# require_relative "settings/definition"
# require_relative "settings/struct"
require_relative "settings/object"

module Hanami
  class Application
    # Application settings
    #
    # @since 2.0.0
    module Settings
      Undefined = Dry::Core::Constants::Undefined

      def self.build(loader, loader_options, &definition_block)
        # definition = Definition.new(&definition_block)
        # settings = loader.new(**loader_options).call(definition.settings)
        # Struct[settings.keys].new(settings)

        # definition = Class.new do
        #   extend Dry::Configurable
        # end.instance_eval(&definition_block)

        klass = Class.new(Settings::Object)
        klass.instance_eval(&definition_block)
        obj = klass.new

        begin
          require "dotenv"
          Dotenv.load if defined?(Dotenv)
        rescue LoadError # rubocop:disable Lint/HandleExceptions
        end

        # byebug

        obj.class.settings.each do |setting_name|
          value = ENV.fetch(setting_name.to_s.upcase) { Undefined }

          p setting_name
          p value

          # byebug
          obj.config.send(:"#{setting_name}=", value)
        end

        # byebug

        obj.freeze
      end
    end
  end
end
