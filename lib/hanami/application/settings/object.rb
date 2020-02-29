require "dry/configurable"

module Hanami
  class Application
    module Settings
      class Object
        include Dry::Configurable

        def self.setting(name, type = nil, default: nil, **kwargs, &block)
          kwargs = {reader: true}.merge(kwargs)
          args = [default].compact

          if type
            super(name, *args, **kwargs, &type)
          else
            super(name, *args, **kwargs, &block)
          end
        end
      end
    end
  end
end
