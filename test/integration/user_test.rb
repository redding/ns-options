require 'assert'

class User

  class BaseTest < Assert::Context
    desc "the User class"
    setup do
      @class = User
    end
    subject{ @class }

    should have_instance_methods :options, :preferences

  end

  class ClassPreferencesTest < BaseTest
    desc "preferences"
    subject{ @class.preferences }

    should have_instance_methods :namespace, :option, :define, :options, :metaclass
    should have_accessors :home_url, :show_messages, :font_size

  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @instance = @class.new
      @class_preferences = @class.preferences
      @class_preferences.home_url = "/something"
      @preferences = @instance.preferences
    end
    subject{ @instance }

    should have_instance_methods :preferences

    should "have a new namespace that is a different object than the class namespace" do
      assert_equal @class_preferences.options.key, @preferences.options.key
      assert_equal @class_preferences.options.parent, @preferences.options.parent
      assert_not_same @class_preferences, @preferences
    end
    should "have the same options as the class namespace, but different objects" do
      @class_preferences.options.each do |key, class_option|
        option = @preferences.options[key]
        assert_equal class_option.name, option.name
        assert_equal class_option.type_class, option.type_class
        assert_equal class_option.rules, option.rules
        assert_not_same class_option, option
      end
      assert_not_equal @class_preferences.home_url, @preferences.home_url
    end
    should "have the same namespaces as the class namespace, but different objects" do
      @class_preferences.options.namespaces.each do |name, class_namespace|
        namespace = @preferences.options.namespaces[name]
        assert_equal class_namespace.options.key, namespace.options.key
        assert_equal class_namespace.options.parent, namespace.options.parent
        assert_not_same class_namespace, namespace
      end
    end
  end

  class PreferencesTest < InstanceTest
    desc "preferences"
    setup do
      @preferences = @instance.preferences
      @preferences.home_url = "/home"
      @preferences.show_messages = false
      @preferences.font_size = 15
      @preferences.view.color = "green"
    end
    subject{ @preferences }

    should have_accessors :home_url, :show_messages, :font_size
    should have_instance_methods :namespace, :option, :define, :options, :metaclass
    should have_instance_methods :view

    should "have set the home_url" do
      assert_equal "/home", subject.home_url
    end

    should "have set show_messages" do
      assert_kind_of NsOptions::Boolean, subject.show_messages
      assert_equal false, subject.show_messages.actual
    end

    should "have set the font_size" do
      assert_equal 15, subject.font_size
    end

    should "have set the color option on the view sub namespace" do
      assert_equal "green", subject.view.color
    end
  end

end
