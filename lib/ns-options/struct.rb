require 'ns-options/proxy'

module NsOptions::Struct

  def self.new(opts=nil, &block)
    Class.new.tap do |klass|
      klass.class_eval { include NsOptions::Proxy }
      klass.define(&block)
      klass.apply(opts)
    end
  end

end
