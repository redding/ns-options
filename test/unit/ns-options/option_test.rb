require 'assert'

class NsOptions::Option

  class BaseTest < Assert::Context
    desc "NsOptions::Option"
    setup do
      @option = NsOptions::Option.new(:stage, String, { :default => "development" })
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
      assert_equal({ :default => "development" }, subject.rules)
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

end
