require 'assert'

class NsOptions::Option

  class BaseTest < Assert::Context
    desc "NsOptions::Option"
    setup do
      @rules = { :default => "development", :require => true }
      @args = [:stage, String, @rules]
      @option = NsOptions::Option.new(*@args)
    end
    subject{ @option }

    should have_class_method :rules, :args
    should have_accessors :name, :value, :type_class, :rules

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
  end

  class ParseRulesTests < BaseTest
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

  class ParseArgsTests < BaseTest
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

  class IsSetTest < BaseTest
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

  class EqualityOperatorTest < BaseTest
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

  class WithNativeTypeClassTest < BaseTest
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

  class WithSymbolTypeClasstest < BaseTest
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
      assert_raises(NoMethodError) do
        subject.value = true
      end
    end
  end

  class WithHashTypeClassTest < BaseTest
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

  class WithArrayTypeClassTest < BaseTest
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

  class WithoutTypeClassTest < BaseTest
    desc "without a type class provided"
    setup do
      @option = NsOptions::Option.new(:something, nil)
    end
    subject{ @option }

    should "have default it to Object" do
      assert_equal Object, subject.type_class
    end
  end

  class WithAValueOfTheSameClassTest < BaseTest
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

  class WithAValueKindOfTest < BaseTest
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

  class ProcHandlingTests < BaseTest
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

  class WithArgsTest < BaseTest
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

    class AsArrayTest < WithArgsTest
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

    class AsSingleValueTest < WithArgsTest
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

    class AsNilValueTest < WithArgsTest
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
