require 'assert'
require 'ns-options/option'
require 'ns-options/boolean'

class NsOptions::Option

  class BaseTests < Assert::Context
    desc "NsOptions::Option"
    setup do
      @rules = { :default => "development", :require => true }
      @args = [:stage, String, @rules]
      @option = NsOptions::Option.new(*@args)
    end
    subject{ @option }

    should have_class_methods :rules, :args
    should have_accessors :name, :value, :type_class, :rules
    should have_imeths :is_set?, :required?, :reset

    should "have set the name" do
      assert_equal "stage", subject.name
    end

    should "have set the type class" do
      assert_equal String, subject.type_class
    end

    should "have set the rules" do
      assert_equal(@rules, subject.rules)
    end

    should "have defaulted value based on the rules" do
      assert_equal subject.rules[:default], subject.value
    end

    should "return true with a call to #required?" do
      assert_equal true, subject.required?
    end

    should "allow setting the value to nil" do
      subject.value = nil
      assert_nil subject.value
    end

    should "allow resetting the value to its default" do
      assert_equal "development", subject.value
      subject.value = "overwritten"
      assert_equal "overwritten", subject.value

      subject.reset

      assert_equal "development", subject.value
    end
  end

  class ParseRulesTests < BaseTests
    desc "parsing rules"
    setup do
      @cases = [nil, {}, {:args => 'is'}].map do |c|
        subject.class.rules(c)
      end
    end

    should "always return them as a Hash" do
      @cases.each { |c| assert_kind_of Hash, c }
    end

    should "always return with an array args rule" do
      @cases.each do |c|
        assert c.has_key? :args
        assert_kind_of Array, c[:args]
      end
    end

  end

  class ParseArgsTests < BaseTests
    desc "when parsing args"
    setup do
      @prules, @ptype_class, @pname = subject.class.args(*@args)
    end

    should "parse option rules arguments, defaulting to {:args => []}" do
      assert_equal @rules, @prules

      @prules, @ptype_class, @pname = subject.class.args('test')
      assert_equal({:args => []}, @prules)
    end

    should "parse the name arg and convert to a string" do
      assert_equal "stage", @pname

      @prules, @ptype_class, @pname = subject.class.args('test')
      assert_equal 'test', @pname
    end

    should "parse the type_class arg and default it to Object" do
      assert_equal String, @ptype_class

      @prules, @ptype_class, @pname = subject.class.args('test')
      assert_equal Object, @ptype_class
    end

  end

  class IsSetTests < BaseTests
    desc "is_set method"
    setup do
      @type_class = Class.new(String) do

        def is_set?
          self.gsub(/\s+/, '').size != 0
        end

      end
      @special = NsOptions::Option.new(:no_blank, @type_class)

      @boolean = NsOptions::Option.new(:boolean, NsOptions::Boolean)
    end

    should "return appropriately" do
      @option.value = "abc"
      assert_equal true, @option.is_set?
      @option.value = nil
      assert_equal false, @option.is_set?
      @boolean.value = true
      assert_equal true, @boolean.is_set?
      @boolean.value = false
      assert_equal true, @boolean.is_set?
    end

    should "use the type class's is_set method if available" do
      @special.value = "not blank"
      assert_equal true, @special.is_set?
      @special.value = " "
      assert_equal false, @special.is_set?
    end

  end

  class EqualityOperatorTests < BaseTests
    desc "== operator"
    setup do
      @first = NsOptions::Option.new(:stage, String)
      @first.value = "test"
      @second = NsOptions::Option.new(:stage, String)
      @second.value = "test"
    end

    should "return true if their attributes are equal" do
      [ :name, :type_class, :value, :rules ].each do |attribute|
        assert_equal @first.send(attribute), @second.send(attribute)
      end
      assert_equal @first, @second
      @first.value = "staging"
      assert_not_equal @first, @second
    end

  end

  class WithNativeTypeClassTests < BaseTests
    desc "with a native type class (Float)"
    setup do
      @option = NsOptions::Option.new(:something, Float)
    end
    subject{ @option }

    should "allow setting it's value with a float" do
      new_value = 12.5
      subject.value = new_value
      assert_equal new_value, subject.value
    end

    should "allow setting it's value with a string and convert it" do
      new_value = "13.4"
      subject.value = new_value
      assert_equal new_value.to_f, subject.value
    end

    should "allow setting it's value with an integer and convert it" do
      new_value = 1
      subject.value = new_value
      assert_equal new_value.to_f, subject.value
    end

  end

  class WithSymbolTypeClasstests < BaseTests
    desc "with a Symbol as a type class"
    setup do
      @option = NsOptions::Option.new(:something, Symbol)
    end

    should "allow setting it with any object that responds to #to_sym" do
      value = "amazing"
      subject.value = value
      assert_equal value.to_sym, subject.value
      value = :another
      subject.value = value
      assert_equal value, subject.value
      object_class = Class.new do
        def to_sym; :object_sym; end
      end
      value = object_class.new
      subject.value = value
      assert_equal object_class.new.to_sym, subject.value
    end

    should "error on anything that doesn't define #to_sym" do
      assert_raises(NsOptions::Option::CoerceError) do
        subject.value = true
      end
    end

  end

  class WithHashTypeClassTests < BaseTests
    desc "with a Hash as a type class"
    setup do
      @option = NsOptions::Option.new(:something, Hash)
    end
    subject{ @option }

    should "allow setting it with a hash" do
      new_value = { :another => true }
      subject.value = new_value
      assert_equal new_value, subject.value
    end

  end

  class WithArrayTypeClassTests < BaseTests
    desc "with an Array as a type class"
    setup do
      @option = NsOptions::Option.new(:something, Array)
    end
    subject{ @option }

    should "allow setting it with a array" do
      new_value = [ :something, :else, :another ]
      subject.value = new_value
      assert_equal new_value, subject.value
    end

  end

  class WithoutTypeClassTests < BaseTests
    desc "without a type class provided"
    setup do
      @option = NsOptions::Option.new(:something, nil)
    end
    subject{ @option }

    should "have default it to Object" do
      assert_equal Object, subject.type_class
    end

  end

  class WithTypeClassArgErrorTests < BaseTests
    desc "setting a value with arg error"
    setup do
      @err = begin
        raise ArgumentError, "some test error"
      rescue ArgumentError => err
        err
      end
      class SuperSuperTestTest
        def initialize(*args)
          raise ArgumentError, "some test error"
        end
      end
      @option = NsOptions::Option.new(:something, SuperSuperTestTest)
    end

    should "reraise the arg error, with a custom message and backtrace" do
      err = begin
        @option.value = "arg error should be raised"
      rescue Exception => err
        err
      end

      assert_equal NsOptions::Option::CoerceError,  err.class
      assert_included @option.type_class.to_s,      err.message
      assert_included 'test/unit/option_tests.rb:', err.backtrace.first
    end

  end

  class WithAValueOfTheSameClassTests < BaseTests
    desc "with a value of the same class"
    setup do
      @class = Class.new
      @option = NsOptions::Option.new(:something, @class)
    end

    should "use the object passed to it instead of creating a new one" do
      value = @class.new
      @option.value = value
      assert_same value, @option.value
    end

  end

  class WithAValueKindOfTests < BaseTests
    desc "with a value that is a kind of the class"
    setup do
      @class = Class.new
      @child_class = Class.new(@class)
      @option = NsOptions::Option.new(:something, @class)
    end

    should "use the object passed to it instead of creating a new one" do
      value = @child_class.new
      @option.value = value
      assert_same value, @option.value
    end

  end

  class ProcHandlingTests < BaseTests
    setup do
      class KindOfProc < Proc; end
      @a_string      = "a string"
      @direct_proc   = Proc.new { "I can haz eval: #{@a_string}" }
      @subclass_proc = KindOfProc.new { 12345 }
      @direct_opt    = NsOptions::Option.new(:direct, Proc)
      @subclass_opt  = NsOptions::Option.new(:subclass, KindOfProc)
    end

  end

  class WithProcTypeClassTests < ProcHandlingTests
    desc "with Proc as a type class"
    setup do
      @direct_opt.value = @direct_proc
      @subclass_opt.value = @subclass_proc
    end

    should "allow setting it with a proc" do
      assert_kind_of Proc, @direct_opt.value
      assert_kind_of KindOfProc, @subclass_opt.value
      assert_equal @direct_proc, @direct_opt.value
      assert_equal @subclass_proc, @subclass_opt.value
    end

  end

  class WithLazyProcTests < ProcHandlingTests
    desc "with a Proc value but no Proc-ancestor type class"
    setup do
      @string_opt = NsOptions::Option.new(:string, String)
    end

    should "set the Proc and coerce the Proc return val when read" do
      @string_opt.value = @direct_proc
      assert_kind_of String, @string_opt.value
      assert_equal "I can haz eval: a string", @string_opt.value

      @a_string = "a new string"
      assert_equal "I can haz eval: a new string", @string_opt.value

      @string_opt.value = @subclass_proc
      assert_kind_of String, @string_opt.value
      assert_equal "12345", @string_opt.value
    end
  end

  class WithReturnValueTests < BaseTests
    setup do
      # test control values
      @string    = NsOptions::Option.new(:string, String)
      @symbol    = NsOptions::Option.new(:symbol, Symbol)
      @integer   = NsOptions::Option.new(:integer, Integer)
      @float     = NsOptions::Option.new(:float, Float)
      @hash      = NsOptions::Option.new(:hash, Hash)
      @array     = NsOptions::Option.new(:array, Array)
      @proc      = NsOptions::Option.new(:proc, Proc)
      @lazy_proc = NsOptions::Option.new(:lazy_proc)

      # custom return value
      class HostedAt
        # sanitized :hosted_at config
        #  remove any trailing '/'
        #  ensure single leading '/'

        def initialize(value)
          @hosted_at = value.sub(/\/+$/, '').sub(/^\/*/, '/')
        end

        def returned_value
          @hosted_at
        end
      end

      @hosted_at = NsOptions::Option.new(:hosted_at, HostedAt)
    end

    should "return values normally when no `returned_value` is specified" do
      @string.value = "test"
      assert_equal "test", @string.value

      @symbol.value = :test
      assert_equal :test, @symbol.value

      @integer.value = 1
      assert_equal 1, @integer.value

      @float.value = 1.1
      assert_equal 1.1, @float.value

      @hash.value = {:test => 'test'}
      assert_equal({:test => 'test'}, @hash.value)

      @array.value = ['test']
      assert_equal ['test'], @array.value

      @proc.value = Proc.new { 'test' }
      assert_kind_of Proc, @proc.value

      @lazy_proc.value = Proc.new { 'lazy test' }
      assert_equal 'lazy test', @lazy_proc.value
    end

    should "should honor `returned_value` when returning option values" do
      @hosted_at.value = "path/to/resource/"
      assert_equal '/path/to/resource', @hosted_at.value
    end

  end

  class WithArgsTests < BaseTests
    desc "with args rule"
    setup do
      @class = Class.new do
        attr_accessor :args
        def initialize(*args)
          self.args = args
        end
      end
      @value = "amazing"
    end

    class AsArrayTests < WithArgsTests
      desc "as an array"
      setup do
        @args = [ true, false, { :hash => "yes" } ]
        @option = NsOptions::Option.new(:something, @class, { :args => @args })
        @option.value = @value
      end

      should "pass the args to the type class with the value" do
        expected = @args.dup.insert(0, @value)
        assert_equal expected, subject.value.args
      end

    end

    class AsSingleValueTests < WithArgsTests
      desc "as a single value"
      setup do
        @args = lambda{ "something" }
        @option = NsOptions::Option.new(:something, @class, { :args => @args })
        @option.value = @value
      end

      should "pass the single value to the type class with the value" do
        expected = [*@args].insert(0, @value)
        assert_equal expected, subject.value.args
      end

    end

    class AsNilValueTests < WithArgsTests
      desc "as a nil value"
      setup do
        @args = nil
        @option = NsOptions::Option.new(:something, @class, { :args => @args })
        @option.value = @value
      end

      should "just pass the value to the type class" do
        expected = [@value]
        assert_equal expected, subject.value.args
      end

    end
  end

end
