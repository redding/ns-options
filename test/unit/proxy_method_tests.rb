require 'assert'
require 'ns-options/proxy_method'

class NsOptions::RootMethods

  class BaseTests < Assert::Context
    desc "NsOptions::RootMethods"
    setup do
      @pm = NsOptions::ProxyMethod.new(Module.new, 'whatever', 'a thing')
    end
    subject { @pm }

    should have_imeths :define_on_class?, :define, :validate

  end

  class ValidateTests < BaseTests
    desc "validate meth"
    setup do
      @io = StringIO.new(@out = "")
      @caller = ["a test caller"]
    end

    should "return false for not recommended methods" do
      pm = NsOptions::ProxyMethod.new(Module.new, :option, 'a thing')
      assert_equal false, pm.validate(@io, @caller)

      pm = NsOptions::ProxyMethod.new(Module.new, "anything_else", 'a thing')
      assert_equal true, pm.validate(@io, @caller)
    end

    should "write a warning and any caller info" do
      NsOptions::ProxyMethod.new(Module.new, :ns, 'a thing').validate(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

    should "be called when calling `define'" do
      NsOptions::ProxyMethod.new(Module.new, :ns, 'a thing').define(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

  end

  class ModuleTests < BaseTests
    desc "defined on a module"
    setup do
      @pm = NsOptions::ProxyMethod.new(@the_module = Module.new, 'on_module', 'a thing')
      @pm.define
    end

    should "know its not defining on a class" do
      assert_not subject.define_on_class?
    end

    should "define a singleton method that builds a ns" do
      assert_responds_to 'on_module', @the_module
    end

  end

  class ClassTests < BaseTests
    desc "defined on a class"
    setup do
      @pm = NsOptions::ProxyMethod.new(@the_class = Class.new, 'on_class', 'a thing')
      @pm.define
    end

    should "know its defining on a class" do
      assert subject.define_on_class?
    end

    should "define a singleton method that builds a ns" do
      assert_responds_to 'on_class', @the_class
    end

    should "define an instance method that builds a ns from its singleton" do
      a_class = @the_class.new
      assert_responds_to 'on_class', a_class
    end

  end

end
