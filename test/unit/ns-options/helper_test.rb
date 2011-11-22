require 'assert'

module NsOptions::Helper

  class BaseTest < Assert::Context
    desc "NsOptions::Helper"
    setup do
      @module = NsOptions::Helper
    end
    subject{ @module }

    should have_instance_methods :find_and_define_namespace, :find_and_define_option,
      :define_namespace_methods, :define_option_methods
  end
  
  class FindAndDefineOptionTest < BaseTest
    desc "find_and_define_option method"
    setup do
      @namespace = NsOptions::Namespace.new("something")
      @option = @namespace.options.add(:anything)
      @result = @module.find_and_define_option(@namespace, @option.name)
    end
    subject{ @namespace }
    
    should "have defined reader/writer methods for the option and returned the option" do
      assert_respond_to @option.name, subject
      assert_respond_to "#{@option.name}=", subject
      assert_equal @option, @result
    end
  end 
  
  class FindAndDefineNamespaceTest < BaseTest
    desc "find_and_define_namespace method"
    setup do
      @namespace = NsOptions::Namespace.new("something")
      @namespace.options.add_namespace(:else, "something:else")
      @result = @module.find_and_define_namespace(@namespace, :else)
    end
    subject{ @namespace }
    
    should "have defined reader method for the namespace and returned the namespace" do
      assert_respond_to :else, subject
      assert_equal subject.options.get_namespace(:else), @result
    end
  end

end
