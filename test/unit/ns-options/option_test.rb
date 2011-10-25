require 'assert'

class NsOptions::Option

  class BaseTest < Assert::Context
    desc "NsOptions::Option"
    setup do
      @rules = { :default => "development", :require => true }
      @option = NsOptions::Option.new(:stage, String, @rules)
    end
    subject{ @option }

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
    end

    should "return true/false appropriately for a boolean option with true or false" do
      @option.value = true
      assert_equal true, @option.is_set?
      @option.value = false
      assert_equal true, @option.is_set?
      @option.value = nil
      assert_equal false, @option.is_set?
    end
    should "return true/false based on type class's is_set method" do
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

  class WithTypeClassFixnumTest < BaseTest
    desc "with the Fixnum as a type class (happens through dynamic writers)"
    setup do
      @option = NsOptions::Option.new(:something, Fixnum)
    end
    subject{ @option }

    should "have used Integer for it's type class" do
      assert_equal Integer, subject.type_class
    end
    should "allow setting it's value with an integer" do
      new_value = 1
      subject.value = new_value
      assert_equal new_value, subject.value
    end
    should "allow setting it's value with a float and convert it" do
      new_value = 12.5
      subject.value = new_value
      assert_equal new_value.to_i, subject.value
    end
    should "allow setting it's value with a string and convert it" do
      new_value = "13"
      subject.value = new_value
      assert_equal new_value.to_i, subject.value
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

  class WithTrueFalseClassTest < BaseTest
    desc "with a TrueClass/FalseClass as a type class (happens with dynamic writers)"
    setup do
      @true_option = NsOptions::Option.new(:something, TrueClass)
      @true_option.value = true
      @false_option = NsOptions::Option.new(:else, FalseClass)
      @false_option.value = false
    end
    subject{ @true_option }

    should "have used NsOptions::Option::Boolean for their type class" do
      assert_equal NsOptions::Option::Boolean, @true_option.type_class
      assert_equal NsOptions::Option::Boolean, @false_option.type_class
    end
    should "return the 'true' or 'false' value instead of the NsOptions::Option::Boolean object" do
      assert_equal true, @true_option.value
      assert_equal false, @false_option.value
    end
  end

  class WithoutTypeClassTest < BaseTest
    desc "without a type class provided"
    setup do
      @option = NsOptions::Option.new(:something, nil)
    end
    subject{ @option }

    should "have default it to String" do
      assert_equal String, subject.type_class
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
    desc "with a value is a kind of the class"
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

end
