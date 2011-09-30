require 'assert'

class NsOptions::Options

  class BaseTest < Assert::Context
    desc "NsOptions::Options"
    setup do
      @options = NsOptions::Options.new(:something)
    end
    subject{ @options }

    should have_accessors :key, :parent, :children
    should have_instance_method :namespaces, :add, :del, :remove, :get, :set, :fetch, :is_defined?,
      :parent_options

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
      assert_kind_of NsOptions::Namespaces, subject.children
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

    should "have added a string option on itself when adding :my_string" do
      assert(option = subject[:my_string])
      assert_equal String, option.type_class
      assert_equal({}, option.rules)
    end
    should "have added an integer option on itself when adding :my_integer" do
      assert(option = subject[:my_integer])
      assert_equal Integer, option.type_class
      assert_equal({}, option.rules)
    end
    should "have added a float option on itself when adding :my_float" do
      assert(option = subject[:my_float])
      assert_equal Float, option.type_class
      assert_equal({ :default => 1.0 }, option.rules)
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

    class WithParentTest < GetTest
      desc "with a parent"
      setup do
        @parent = NsOptions::Namespace.new(:child)
        @parent.options = @options
        @options = NsOptions::Options.new(:child, @parent)
        @result = @options.get(:my_string)
      end
      subject{ @result }

      should "have returned the parent's option's value" do
        assert_equal @value, subject
      end
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

  class FetchTest < BaseTest
    desc "fetch method"
    setup do
      option = @options.add(:my_string)
      @result = @options.fetch(:my_string)
    end
    subject{ @result }

    should "return the option definition for my_string" do
      assert_kind_of NsOptions::Option, subject
      assert_equal "my_string", subject.name
    end

    class WithAParentTest < FetchTest
      desc "with a parent"
      setup do
        @parent = NsOptions::Namespace.new(:child)
        @parent.options = @options
        @options = NsOptions::Options.new(:child, @parent)
        @result = @options.fetch(:my_string)
      end
      subject{ @result }

      should "return the option definition for my_string from it's parent" do
        assert_kind_of NsOptions::Option, subject
        assert_equal "my_string", subject.name
      end
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

    class WithAParentTest < IsDefinedTest
      desc "with a parent"
      setup do
        @parent = NsOptions::Namespace.new(:child)
        @parent.options = @options
        @options = NsOptions::Options.new(:child, @parent)
      end

      should "return true for an option defined on it's parent" do
        assert_equal true, subject.is_defined?(:my_string)
      end
    end
  end

  class ParentOptionsTest < BaseTest
    desc "parent_options method"
    subject{ @options }

    should "return nil" do
      assert_nil subject.parent_options
    end

    class WithAParentTest < ParentOptionsTest
      desc "with a parent"
      setup do
        @parent = NsOptions::Namespace.new(:child)
        @parent.options = @options
        @options = NsOptions::Options.new(:child, @parent)
      end

      should "return it's parent's options" do
        assert_equal @parent.options, subject.parent_options
      end
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

end