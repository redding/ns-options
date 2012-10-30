require 'ns-options'
require 'ns-options/root_methods'

module NsOptions::Proxy

  # Mix this in to any module or class to make it proxy a namespace
  # this means you can interact with the module/class/class-instance as
  # if it were a namespace object itself.

  NAMESPACE = "__proxy_options__"

  class << self

    def included(receiver)
      NsOptions::RootMethods.new(receiver, NAMESPACE).define
      receiver.class_eval { extend  ProxyMethods }
      receiver.class_eval { include ProxyMethods } if receiver.kind_of?(Class)

      if receiver.kind_of?(Class)
        receiver.class_eval do

          # default initializer method
          def initialize(configs={})
            self.apply(configs || {})
          end

          # equality method override for class-instance proxies
          def ==(other_proxy_instance)
            __proxy_options__ == other_proxy_instance.__proxy_options__
          end

        end
      else # Module
        receiver.class_eval do

          # default initializer method
          def self.new(configs={})
            self.apply(configs || {})
          end

        end
      end
    end

  end

  module ProxyMethods

    # pass thru namespace methods to the proxied NAMESPACE handler

    def option(*args, &block); __proxy_options__.option(*args, &block); end
    alias_method :opt, :option

    def namespace(*args, &block); __proxy_options__.namespace(*args, &block); end
    alias_method :ns, :namespace

    def apply(*args, &block);   __proxy_options__.apply(*args, &block);   end
    def to_hash(*args, &block); __proxy_options__.to_hash(*args, &block); end
    def each(*args, &block);    __proxy_options__.each(*args, &block);    end
    def define(*args, &block);  __proxy_options__.define(*args, &block);  end

    def required_set?(*args, &block); __proxy_options__.required_set?(*args, &block); end
    def valid?(*args, &block);        __proxy_options__.valid?(*args, &block);        end

    def inspect(*args, &block)
      "#<#{self.class}:#{'0x%x' % (self.object_id << 1)}:#{__proxy_options__.__data__.name} #{__proxy_options__.to_hash.inspect}>"
    end

    # for everything else, send to the proxied NAMESPACE handler
    # at this point it really just enables setting dynamic options

    def method_missing(meth, *args, &block)
      if (po = self.__proxy_options__) && po.respond_to?(meth.to_s)
        po.send(meth.to_s, *args, &block)
      else
        super
      end
    end

    def respond_to?(*args)
      if (po = self.__proxy_options__) && po.respond_to?(args.first.to_s)
        true
      else
        super
      end
    end

  end

end
