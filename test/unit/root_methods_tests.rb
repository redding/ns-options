require 'assert'
require 'ns-options/root_methods'
require 'ns-options/namespace'

class NsOptions::RootMethods

  class BaseTests < Assert::Context
    desc "NsOptions::RootMethods"
    setup do
      @rm = NsOptions::RootMethods.new(Module.new, 'whatever')
    end
    subject { @rm }

    should have_imeths :define_on_class?, :define

  end

  class ModuleTests < BaseTests
    desc "defined on a module"
    setup do
      @rm = NsOptions::RootMethods.new(@the_module = Module.new, 'on_module')
      @rm.define
    end

    should "know its not defining on a class" do
      assert_not subject.define_on_class?
    end

    should "define a singleton method that builds a ns" do
      assert_responds_to 'on_module', @the_module
      assert_kind_of NsOptions::Namespace, @the_module.on_module
    end

  end

  class ClassTests < BaseTests
    desc "defined on a class"
    setup do
      @rm = NsOptions::RootMethods.new(@the_class = Class.new, 'on_class')
      @rm.define
    end

    should "know its defining on a class" do
      assert subject.define_on_class?
    end

    should "define a singleton method that builds a ns" do
      assert_responds_to 'on_class', @the_class
      ns = @the_class.on_class { option :opt1 }

      assert_kind_of NsOptions::Namespace, ns
      assert ns.__data__.has_option?(:opt1)
    end

    should "define an instance method that builds a ns from its singleton" do
      @the_class.on_class { option :opt1 }
      a_class = @the_class.new
      assert_responds_to 'on_class', a_class
      ns = a_class.on_class

      assert_kind_of NsOptions::Namespace, ns
      assert ns.__data__.has_option?(:opt1)
    end

  end

end
