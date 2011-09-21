require 'assert'

class NsOptions::Namespace

  class BaseTest < Assert::Context
    desc "NsOptions::Namespace"
    setup do
      @key = "options"
      @namespace = NsOptions::Namespace.new(@key)
    end
    subject{ @namespace }

    should have_accessors :metaclass, :options
    should have_instance_methods :option, :namespace

    should "have set it's metaclass accessor" do
      assert subject.metaclass
    end
    should "have created a new options collection and set it's options accessor" do
      assert subject.options
      assert_kind_of NsOptions::Options, subject.options
      assert_equal @key, subject.options.key
      assert_nil subject.options.parent
    end
  end

  class OptionTest < BaseTest
    desc "option method"
    setup do
      @name = :something
      @type = NsOptions::Option::Boolean
      @extras = { :default => true }
      @namespace.option(@name, @type, @extras)
    end
    subject{ @namespace }

    should "have added the option to the namespace's options collection" do
      assert (option = subject.options[@name])
      assert_equal @name.to_s, option.name
      assert_equal @type, option.type_class
      assert_equal @extras, option.extras
    end
  end

  class OptionWithNoTypeTest < BaseTest
    desc "option method with no type specified"
    setup do
      @name = :something
      @namespace.option(@name)
    end
    subject{ @namespace }

    should "default the type to String" do
      assert (option = subject.options[@name])
      assert_equal String, option.type_class
    end
  end

  class OptionMethodsTest < OptionTest
    desc "defined methods"

    should have_instance_methods :something, :something=

    should "be writable through the defined writer" do
      assert_nothing_raised{ subject.something = false }
      assert_equal false, subject.something
    end
    should "be writable through the reader with args" do
      assert_nothing_raised{ subject.something true }
      assert_equal true, subject.something
    end
  end

  class NamespaceTest < BaseTest
    desc "namespace method"
    setup do
      @namespace.namespace(:something) do
        option :something_else
      end
    end
    subject{ @namespace }

    should "have added a namespace to the namespace's options collection" do
      assert (namespace = subject.options.namespaces[:something])
      assert_equal "#{subject.options.key}:something", namespace.options.key
      assert_equal subject, namespace.options.parent
      assert namespace.options[:something_else]
    end
  end

  class NamespaceMethodsTest < NamespaceTest
    desc "defined methods"

    should have_instance_methods :something

    should "be return the namespace using the reader" do
      assert_equal subject.options.namespaces[:something], subject.something
    end
    should "configure the namespace with the reader and a block" do
      subject.something do
        option :another
      end
      assert subject.something.options[:another]
    end
  end

  class ConfigureTest < BaseTest
    desc "configure method"

    class BlockWithoutArityTest < BaseTest
      desc "with a block with no arity"

      should "instance eval the block in the scope of the namespace" do
        scope = nil
        subject.configure do
          scope = self
        end
        assert_equal subject, scope
      end
    end
    class BlockWithArityTest < BaseTest
      desc "with a block with arity"

      should "yield the namespace to the block" do
        yielded = nil
        subject.configure do |config|
          yielded = config
        end
        assert_equal subject, yielded
      end
    end
    class NoBlockTest < BaseTest
      desc "with no block"

      should "return the namespace" do
        assert_equal subject, subject.configure
      end
    end
  end

  class MethodMissingTest < BaseTest
    desc "method missing"
    setup do
      @parent = @namespace
      @parent.options.add(:something)
      @parent.options.set(:something, "amazing")
      @namespace = NsOptions::Namespace.new("child", @parent)
    end

    class ReaderForAKnownOptionTest < MethodMissingTest
      desc "as a reader for a known option"
      setup do
        @result = @namespace.something
      end

      should "have defined the option on the namespace" do
        defined_methods = subject.metaclass.public_instance_methods(false).map(&:to_sym)
        assert_includes :something, defined_methods
        assert_includes :something=, defined_methods
        assert_equal "amazing", @result
      end
    end
    class WriterForAKnownOptionTest < MethodMissingTest
      desc "as a reader for a known option"
      setup do
        @namespace.something = "even more amazing"
      end

      should "have defined the option on the namespace" do
        defined_methods = subject.metaclass.public_instance_methods(false).map(&:to_sym)
        assert_includes :something, defined_methods
        assert_includes :something=, defined_methods
        assert_equal "even more amazing", subject.something
      end
    end
    class DynamicWriterTest < MethodMissingTest
      desc "with a writer for an unknown option"
      setup do
        @namespace.something_not_defined = "you know it"
        @namespace.another_not_defined = true
        @namespace.even_more_not_defined = 12
      end
      
      should "have defined the accessors and added the option" do
        defined_methods = subject.metaclass.public_instance_methods(false).map(&:to_sym)
        assert subject.options[:something_not_defined]
        assert_includes :something_not_defined, defined_methods
        assert_includes :something_not_defined=, defined_methods
        assert_equal "you know it", subject.something_not_defined
      end
      should "use the class of the value for the option's type class" do
        assert_equal String, subject.options[:something_not_defined].type_class
        assert_equal Integer, subject.options[:even_more_not_defined].type_class
        assert_equal NsOptions::Option::Boolean, subject.options[:another_not_defined].type_class
      end
    end
  end

  class RespondToTest < BaseTest
    desc "respond to"
    setup do
      @namespace.options.add(:something)
    end

    should "return true when the reader of an option is requested without the reader defined" do
      assert_not_includes :something, subject.class.public_instance_methods(false).map(&:to_sym)
      assert_not_includes :something, subject.metaclass.public_instance_methods(false).map(&:to_sym)
      assert_equal true, subject.respond_to?(:something)
    end
  end

  class WithAParentTest < BaseTest
    desc "with a parent"
    setup do
      @key = "options"
      @parent = @namespace
      @namespace = NsOptions::Namespace.new(@key, @parent)
    end
    subject{ @namespace }

    should "have set it's options accessor and stored it's parent on it" do
      assert subject.options
      assert_equal @parent, subject.options.parent
    end
  end

end
