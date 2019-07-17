# TODO: we need a way for this file not to load if hanami/view can't be required
# (i.e. for someone using hanami but _not_ using hanami-view)
require "hanami/view"

require "dry/inflector"
require "hanami/utils/string"

module Hanami
  View.class_eval do
    class << self
      def [](app_name)
        # TODO: find a nicer way to reference this
        container = Hanami::Container

        templates = [container.root.join("apps", app_name.to_s, "templates").to_s]

        klass = Class.new(Hanami::View) do
          config.paths = templates
          config.layouts_dir = templates
          config.layout = "application"
        end

        klass.define_singleton_method :inherited do |subclass|
          super(subclass)

          unless subclass.superclass == klass
            subclass.config.template = template_name(subclass, app_name)
          end
        end

        klass
      end

      private

      def template_name(view, app_name)
        # TODO: work out how the application's inflector can be injected/provided
        inflector = Dry::Inflector.new

        app_namespace = inflector.classify("#{app_name}")
        tokens = Utils::String.transform(view.name, [:sub, /#{app_namespace}::Views::/, ""], [:split, /::/]) # ugh, having to append "::Views" here is not nice

        tokens.map { |token| Utils::String.underscore(token) }.join("/")
      end
    end
  end
end
