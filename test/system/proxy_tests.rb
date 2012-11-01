require 'assert'

require 'ns-options/assert_macros'
require 'test/support/proxy'

class SomeProxyIntTests < Assert::Context
  include NsOptions::AssertMacros

  desc "the integration test proxy module"
  setup do
    @proxy = SomeProxy
  end
  subject { @proxy }

  should have_option :some, SomeProxy::SomeThing, {
    :default => {:value1 => 1}
  }

  should have_option :some_prime, SomeProxy::SomeThing, {
    :default => {:value1 => 'one'}
  }

  should have_option :stuff, :default => []

end

class SomeProxySomeThingTests < SomeProxyIntTests
  desc ":some option"
  setup do
    @proxy_some = @proxy.some
  end
  subject { @proxy_some }

  should have_namespace :more
  should have_options :value1, :value2

  should "have its :value1 defaulted" do
    assert_equal 1, subject.value1
  end

end

class SomeProxySomeOtherThingTests < SomeProxyIntTests
  desc "that has a class inherited from another proxy object"
  setup do
    @proxy = SomeProxy::SomeOtherThing.new
  end

  # should "have the same definition as its superclass"
  should have_namespace :more
  should have_options :value1, :value2

end
