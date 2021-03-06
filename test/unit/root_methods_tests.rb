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

    should have_imeths :define_on_class?, :define, :validate

  end

  class ValidateTests < BaseTests
    desc "validate meth"
    setup do
      @io = StringIO.new(@out = "")
      @caller = ["a test caller"]
    end

    should "return false for :options, :opts, :namespace, :ns names" do
      [:options, :opts, :namespace, :ns].each do |meth|
        rm = NsOptions::RootMethods.new(Module.new, meth)
        assert_equal false, rm.validate(@io, @caller)
      end

      rm = NsOptions::RootMethods.new(Module.new, "anything_else")
      assert_equal true, rm.validate(@io, @caller)
    end

    should "write a warning and any caller info" do
      NsOptions::RootMethods.new(Module.new, :ns).validate(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

    should "be called when calling `define'" do
      NsOptions::RootMethods.new(Module.new, :ns).define(@io, @caller)

      assert_match "WARNING: ", @out
      assert_match @caller.first, @out
    end

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

  class InheritedClassTests < BaseTests
    desc "when inherited"
    setup do
      @rm = NsOptions::RootMethods.new(@a_super_class = Class.new, 'a_ns')
      @rm.define
      @a_super_class.a_ns Fixnum do
        option :test
        namespace(:other) { option :stuff }
      end
    end

    should "define a singleton method that builds a ns with the same def as its superclass" do
      a_sub_class = Class.new(@a_super_class)

      assert a_sub_class.a_ns.has_option? :test
      assert a_sub_class.a_ns.has_namespace? :other
      assert a_sub_class.a_ns.other.has_option? :stuff

      a_sub_ns_data = a_sub_class.a_ns.__data__
      assert_equal Fixnum, a_sub_ns_data.option_type_class
      other_ns_data = a_sub_class.a_ns.other.__data__
      assert_equal Fixnum, other_ns_data.option_type_class
    end

  end

end
