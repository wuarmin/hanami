require "dry/configurable"

module Hanami
  class Application
    module Settings
      class Object
        include Dry::Configurable

        def self.setting(name, *args, **kwargs, &block)
          kwargs = {reader: true}.merge(kwargs)

          super(name, *args, **kwargs, &block)
        end

        # def self.setting(name, type = nil, default: nil, **kwargs, &block)
        #   kwargs = {reader: true}.merge(kwargs)
        #   args = default ? [default] : []

        #   if type
        #     super(name, *args, **kwargs, &type)
        #   else
        #     super(name, *args, **kwargs, &block)
        #   end
        # end

        # def self.setting(name, *args, **kwargs, &block)
        #   # byebug if name == :feature_flag
        #   # super(name, *args, reader: true, **kwargs, &block)
        #   constructor = kwargs.delete(:constructor)

        #   byebug if constructor

        #   if constructor
        #     super(name, *args, reader: true, **kwargs, &constructor)
        #   else
        #     super(name, *args, reader: true, **kwargs, &block)
        #   end
        # end


        #   # if type
        #   #   super(name, *args, reader: true, &type)
        #   # else
        #   # end

        #   # super(name, reader: true, **args, &block)
        #   super
        # end
      end
    end
  end
end
