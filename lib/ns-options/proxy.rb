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

    # just proxy to the NAMESPACE created when Proxy was mixed in

    def method_missing(meth, *args, &block)
      if (po = self.__proxy_options__) && po.respond_to?(meth.to_s)
        po.send(method, *args, &block)
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
