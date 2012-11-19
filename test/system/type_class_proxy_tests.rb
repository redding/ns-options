require 'assert'

require 'ns-options/assert_macros'
require 'test/support/type_class_proxy'

class TypeClassProxyTests < Assert::Context
  include NsOptions::AssertMacros

  desc "a proxy using option_type_class"
  setup do
    set_proxy_for_tests(TypeClassProxy)
  end

  def set_proxy_for_tests(proxy_class)
    @proxy = proxy_class
    proxy_class.value1          = 10
    proxy_class.more.more1      = 10
    proxy_class.strings.string1 = 10
    proxy_class.objs.obj1       = Object.new
  end

  should "use the option type class for its options" do
    assert_kind_of DefaultTypeClass, @proxy.value1
    assert_equal   10, @proxy.value1.value
  end

  should "use the option type class for its namespaces" do
    assert_equal DefaultTypeClass, @proxy.more.option_type_class
  end

  should "recursively use the option type class" do
    assert_kind_of DefaultTypeClass, @proxy.more.more1
  end

  should "allow the recursive option type class to be overridden" do
    assert_equal   String, @proxy.strings.option_type_class
    assert_kind_of String, @proxy.strings.string1
  end

  should "allow the recursive option type class to be reset" do
    assert_equal   Object, @proxy.objs.option_type_class
    assert_kind_of Object, @proxy.objs.obj1
  end

end

class InheritedTypeClassProxyTests < TypeClassProxyTests
  desc "that inherits from another"
  setup do
    set_proxy_for_tests(InheritedTypeClassProxy)
  end

  should "use the option type class for its options" do
    assert_kind_of DefaultTypeClass, @proxy.value1
    assert_equal   10, @proxy.value1.value
  end

  should "use the option type class for its namespaces" do
    assert_equal DefaultTypeClass, @proxy.more.option_type_class
  end

  should "recursively use the option type class" do
    assert_kind_of DefaultTypeClass, @proxy.more.more1
  end

  should "allow the recursive option type class to be overridden" do
    assert_equal   String, @proxy.strings.option_type_class
    assert_kind_of String, @proxy.strings.string1
  end

  should "allow the recursive option type class to be reset" do
    assert_equal   Object, @proxy.objs.option_type_class
    assert_kind_of Object, @proxy.objs.obj1
  end

end

class DoubleInheritedTypeClassProxyTests < TypeClassProxyTests
  desc "that inherits from another that inherits from another"
  setup do
    set_proxy_for_tests(DoubleInheritedTypeClassProxy)
  end

  should "use the option type class for its options" do
    assert_kind_of DefaultTypeClass, @proxy.value1
    assert_equal   10, @proxy.value1.value
  end

  should "use the option type class for its namespaces" do
    assert_equal DefaultTypeClass, @proxy.more.option_type_class
  end

  should "recursively use the option type class" do
    assert_kind_of DefaultTypeClass, @proxy.more.more1
  end

  should "allow the recursive option type class to be overridden" do
    assert_equal   String, @proxy.strings.option_type_class
    assert_kind_of String, @proxy.strings.string1
  end

  should "allow the recursive option type class to be reset" do
    assert_equal   Object, @proxy.objs.option_type_class
    assert_kind_of Object, @proxy.objs.obj1
  end

end

