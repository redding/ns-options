require 'ns-options'

module SomeProxy
  include NsOptions::Proxy

  class SomeThing
    include NsOptions::Proxy

    def initialize(opts=nil)
      super(opts)
    end

    opt :value1, String
    opt :value2, Symbol

    ns :more do
      opt :other1
      opt :other2
    end

  end

  class SomeOtherThing < SomeThing; end

  opt :some, SomeThing, :default => { :value1 => '1' }
  opt :some_prime, SomeThing, :default => { :value1 => 'one' }
  opt :stuff, :default => []

end
