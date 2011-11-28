require 'assert'

class NsOptions::Options

  class BaseTest < Assert::Context
    desc "NsOptions::Options"
    setup do
      @options = NsOptions::Options.new(:something)
    end
    subject{ @options }

    should have_accessors :key, :parent, :namespaces
    should have_instance_method :add, :del, :remove, :get, :set, :fetch, :is_defined?,
      :add_namespace, :get_namespace, :build_from

    should "be a kind of Hash" do
      assert_kind_of Hash, subject
    end
    should "only use symbols for keys" do
      subject["string_key"] = true
      subject[:symbol_key] = true

      assert_includes :string_key, subject.keys
      assert_includes :symbol_key, subject.keys
      assert_not_includes "string_key", subject.keys
    end
    should "have set the key" do
      assert_equal "something", subject.key
    end
    should "have set the parent to nil" do
      assert_nil subject.parent
    end
    should "return a kind of NsOption::Namespaces with a call to #children" do
      assert_kind_of NsOptions::Namespaces, subject.namespaces
    end
  end

  class AddTest < BaseTest
    desc "add method"
    setup do
      @options.add(:my_string)
      @options.add(:my_integer, Integer)
      @options.add(:my_float, Float, { :default => 1.0 })
    end
    subject{ @options }

    should "have added a object option on itself when adding :my_string" do
      assert(option = subject[:my_string])
      assert_equal Object, option.type_class
      assert_equal({ :args => [] }, option.rules)
    end
    should "have added an integer option on itself when adding :my_integer" do
      assert(option = subject[:my_integer])
      assert_equal Integer, option.type_class
      assert_equal({ :args => [] }, option.rules)
    end
    should "have added a float option on itself when adding :my_float" do
      assert(option = subject[:my_float])
      assert_equal Float, option.type_class
      assert_equal(1.0, option.rules[:default])
    end
  end

  class DelTest < BaseTest
    desc "add method"
    setup do
      @options.add(:my_string)
      @options.del(:my_string)
    end
    subject{ @options }

    should "remove the option definition from the collection" do
      assert_nil subject[:my_string]
    end
  end

  class GetTest < BaseTest
    desc "get method"
    setup do
      option = @options.add(:my_string)
      option.value = @value = "something"
      @result = @options.get(:my_string)
    end
    subject{ @result }

    should "have returned the option's value" do
      assert_equal @value, subject
    end
  end

  class SetTest < BaseTest
    desc "set method"
    setup do
      option = @options.add(:my_string)
      @options.set(:my_string, "something")
    end
    subject{ @options }

    should "have set the option's value" do
      assert_equal "something", subject.get(:my_string)
    end
  end

  class IsDefinedTest < BaseTest
    desc "fetch method"
    setup do
      option = @options.add(:my_string)
    end
    subject{ @options }

    should "return true for a defined option" do
      assert_equal true, subject.is_defined?(:my_string)
    end
    should "return false for an undefined option" do
      assert_equal false, subject.is_defined?(:undefined)
    end
  end

  class RequiredSetTest < BaseTest
    desc "required_set? method"
    setup do
      @options.add(:first, String, { :require => true })
      @options.add(:second, String, { :required => true })
      @options.add(:third, String)
    end

    should "return true when all required options are set" do
      @options.set(:first, "first")
      @options.set(:second, "second")
      assert_equal true, subject.required_set?
    end
    should "return false if one required option is not set" do
      @options.set(:first, "first")
      @options.set(:third, "third")
      assert_equal false, subject.required_set?
    end
    should "not change because of options that aren't required" do
      @options.set(:first, "first")
      @options.set(:second, "second")
      @options.set(:third, "third")
      assert_equal true, subject.required_set?
      @options.set(:third, nil)
      assert_equal true, subject.required_set?
    end
  end
  
  class WithNamespaceTest < BaseTest
    setup do
      @namespace = @options.add_namespace(:something, :something)
    end
  end

  class AddNamespaceTest < WithNamespaceTest
    desc "add_namespace method"
    subject{ @options }

    should "create a new namespace and add it to the options namespaces collection" do
      assert_instance_of NsOptions::Namespace, @namespace
      assert_equal @namespace, subject.namespaces[:something]
    end
  end

  class GetNamespaceTest < WithNamespaceTest
    desc "get_namespace method"
    setup do
      @got_namespace = @options.get_namespace(:something)
    end
    subject{ @got_namespace }

    should "allow retrieving a namespace without having to access the namespaces directly" do
      assert_equal @namespace, subject
    end
  end
  
  class IsNamespaceDefinedTest < WithNamespaceTest
    desc "is_namespace_defined? method"
    setup do
      @has_something = @options.is_namespace_defined?(:something)
      @has_nothing = @options.is_namespace_defined?(:nothing)
    end

    should "return a boolean of whether or not the namespace is defined" do
      assert_equal true, @has_something
      assert_equal false, @has_nothing
    end
  end

  class BuildFromTest < BaseTest
    desc "build_from method"
    setup do
      @namespace = NsOptions::Namespace.new("something")
      @from = NsOptions::Options.new(:something)
      @from.add(:root)
      @from.add_namespace(:else) do
        option :stage
      end
      @options = @namespace.options
      @options.build_from(@from, @namespace)
    end
    subject{ @options }

    should "have copied the options" do
      @from.each do |key, from_option|
        option = subject[key]
        assert_equal from_option.name, option.name
        assert_equal from_option.type_class, option.type_class
        assert_equal from_option.rules, option.rules
        assert_not_same from_option, option
      end
    end
    should "have copied the namespaces" do
      @from.namespaces.each do |name, from_namespace|
        namespace = subject.get_namespace(name)
        assert_equal from_namespace.options.key, namespace.options.key
        assert_equal from_namespace.options.parent, namespace.options.parent
        assert_not_same from_namespace, namespace
      end
    end
  end

end