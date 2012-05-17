module NsOptions::Proxy

  # Mix this in to any module or class to make it proxy a namespace
  # this means you can interact with the module/class/class-instance as
  # if it were a namespace object itself.  For example:

  NAMESPACE = "__proxy_options__"

  class << self

    def included(receiver)
      receiver.class_eval do
        include NsOptions
        options(NAMESPACE)

        extend ProxyMethods
        include ProxyMethods
      end
    end

  end

  module ProxyMethods

    # pass thru namespace methods to the proxied NAMESPACE handler

    def option(*args, &block)
      self.__proxy_options__.option(*args, &block)
    end

    def namespace(*args, &block)
      self.__proxy_options__.namespace(*args, &block)
    end

    def apply(*args, &block)
      self.__proxy_options__.apply(*args, &block)
    end

    def to_hash(*args, &block)
      self.__proxy_options__.to_hash(*args, &block)
    end

    def each(*args, &block)
      self.__proxy_options__.each(*args, &block)
    end

    def define(*args, &block)
      self.__proxy_options__.define(*args, &block)
    end

    def inspect(*args, &block)
      self.__proxy_options__.inspect(*args, &block)
    end

    def required_set?(*args, &block)
      self.__proxy_options__.required_set?(*args, &block)
    end

    def valid?(*args, &block)
      self.__proxy_options__.valid?(*args, &block)
    end

    # for everything else, send to the proxied NAMESPACE handler

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
