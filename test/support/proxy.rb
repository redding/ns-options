module SomeProxy
  include NsOptions::Proxy

  class SomeThing
    include NsOptions::Proxy

    opt :value1
    opt :value2

    ns :more do
      opt :other1
      opt :other2
    end

  end

  opt :some, SomeThing, :default => { :value1 => 1 }
  opt :some_prime, SomeThing, :default => { :value1 => 'one' }
  opt :stuff, :default => []

end
