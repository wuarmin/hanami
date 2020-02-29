# frozen_string_literal: true

require "dry/configurable"
# require_relative "settings/definition"
# require_relative "settings/struct"
require_relative "settings/object"

module Hanami
  class Application
    # Application settings
    #
    # @since 2.0.0
    module Settings
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

        obj.class.settings.each do |setting_name|
          value = ENV.fetch(setting_name.to_s.upcase) { Dry::Configurable::Undefined }
          obj.config.send(:"#{setting_name}=", value)
        end

        obj.freeze
      end
    end
  end
end
