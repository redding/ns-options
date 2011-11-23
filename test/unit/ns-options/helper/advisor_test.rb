require 'assert'

class NsOptions::Helper::Advisor

  module Output
    module_function

    def capture
      out = StringIO.new
      $stdout = out
      yield
      return out
    ensure
      $stdout = STDOUT
    end
  end

  class BaseTest < Assert::Context
    desc "NsOptions::Helper::Advisor"
    setup do
      @namespace = NsOptions::Namespace.new("something")
      @advisor = NsOptions::Helper::Advisor.new(@namespace)
    end
    subject{ @advisor }

    should have_accessors :namespace
    should have_instance_methods :is_this_ok?, :is_this_option_ok?, :is_this_namespace_ok?,
      :is_already_defined?, :bad_methods, :not_recommended_methods, :bad_method_message,
      :duplicate_message, :not_recommended_method_message

    should "return methods that cannot be overwritten with a call to #bad_methods" do
      expected = [ :define, :namespace, :option, :options ].map(&:to_s).sort
      assert_equal(expected, subject.bad_methods.map(&:to_s).sort)
    end
    should "return methods that shouldn't be overwritten with a call to #not_recommended_methods" do
      expected = NsOptions::Namespace.instance_methods(false).map(&:to_sym)
      assert_equal(expected, subject.not_recommended_methods)
    end
    should "return if an option/namespace is defined with a call to #is_already_defined?" do
      assert_equal false, subject.is_already_defined?(:first)
    end
  end

  class BadOptionTest < BaseTest
    desc "with a bad option"
    setup do
      begin
        @advisor.is_this_option_ok?("namespace")
      rescue Exception => @exception
      end
    end

    should "raise an exception when an option matches one of the bad methods" do
      assert_kind_of NsOptions::Errors::InvalidName, @exception
      expected = subject.bad_method_message("option", "namespace")
      assert_equal expected, @exception.message
    end
  end

  class DuplicateOptionTest < BaseTest
    desc "with a duplicate option"
    setup do
      @namespace.option(:duplicate)
      @output = Output.capture do
        @advisor.is_this_option_ok?("duplicate")
      end
    end

    should "output a message warning that they are re-defining an option" do
      expected = subject.duplicate_message("duplicate")
      assert_match expected, @output.string
      assert_match "From: ", @output.string
    end
    should "return true with a call to #is_already_defined?" do
      assert_equal true, subject.is_already_defined?(:duplicate)
    end
  end

  class NotRecommendedOptionTest < BaseTest
    desc "with a not recommended option"
    setup do
      @output = Output.capture do
        @advisor.is_this_option_ok?("apply")
      end
    end

    should "output a message warning using the method name as an option name" do
      expected = subject.not_recommended_method_message("option", "apply")
      assert_match expected, @output.string
      assert_match "From: ", @output.string
    end
  end

  class BadNamespaceTest < BaseTest
    desc "with a bad namespace"
    setup do
      begin
        @advisor.is_this_namespace_ok?("options")
      rescue Exception => @exception
      end
    end

    should "raise an exception when a namespace matches one of the bad methods" do
      assert_kind_of NsOptions::Errors::InvalidName, @exception
      expected = subject.bad_method_message("sub-namespace", "options")
      assert_equal expected, @exception.message
    end
  end

  class DuplicateNamespaceTest < BaseTest
    desc "with a duplicate namespace"
    setup do
      @namespace.namespace(:duplicate)
      @output = Output.capture do
        @advisor.is_this_namespace_ok?("duplicate")
      end
    end

    should "output a message warning that they are re-defining a namespace" do
      expected = subject.duplicate_message("duplicate")
      assert_match expected, @output.string
      assert_match "From: ", @output.string
    end
    should "return true with a call to #is_already_defined?" do
      assert_equal true, subject.is_already_defined?(:duplicate)
    end
  end

  class NotRecommendedNamespaceTest < BaseTest
    desc "with a not recommended namespace"
    setup do
      @output = Output.capture do
        @advisor.is_this_namespace_ok?("apply")
      end
    end

    should "output a message warning using the method name as a namespace name" do
      expected = subject.not_recommended_method_message("sub-namespace", "apply")
      assert_match expected, @output.string
      assert_match "From: ", @output.string
    end
  end

end
