require 'assert'

module NsOptions::Helper

  class BaseTest < Assert::Context
    desc "NsOptions::Helper"
    setup do
      @module = NsOptions::Helper
    end
    subject{ @module }

    should have_instance_methods :new_namespace, :new_child_namespace, :fetch_and_define_option

  end

  class NewNamespaceTest < BaseTest
    desc "new_namespace method"
    setup do
      @parent = @module.new_namespace("parent")
      @child = @module.new_namespace("child", @parent) do
        option :something
      end
    end

    should "have created a parent namespace" do
      assert_equal "parent", @parent.options.key
    end
    should "have created a child namespace" do
      assert_equal "child", @child.options.key
      assert_equal @parent, @child.options.parent
      assert @child.options[:something]
    end
  end
  
  class NewChildNamespaceTest < BaseTest
    desc "new_child_namespace method"
    setup do
      @parent = @module.new_namespace("parent")
      @mock_class = mock()
      @mock_class.stubs(:super_settings).returns(@parent)
      @first_owner = mock()
      @first_owner.stubs({ :class => @mock_class })
      @first = @module.new_child_namespace(@first_owner, "super_settings") do
        option :something
      end
      @second_owner = User.new
      @second = @module.new_child_namespace(@second_owner, "preferences")
    end
    
    should "have created a child namespace" do
      class_name = @mock_class.to_s.split('::').last.downcase
      key = "#{@parent.options.key}:#{class_name}_#{@first_owner.object_id}"
      assert_equal key, @first.options.key
      assert_equal @parent, @first.options.parent
      assert @first.options[:something]
    end    
    should "have created a second child namespace" do
      key = "#{@second.options.parent.options.key}:#{@second_owner.preferences_key}"
      assert_equal key, @second.options.key
    end
  end

end
