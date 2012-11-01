require 'assert'
require 'test/support/user'

class User

  class BaseTests < Assert::Context
    desc "the User class"
    setup do
      @class = User
    end
    subject{ @class }

    should have_reader :preferences

  end

  class ClassPreferencesTests < BaseTests
    desc "preferences"
    subject{ @class.preferences }

    should have_instance_methods :namespace, :option, :define
    should have_accessors :home_url, :show_messages, :font_size
    should have_readers   :view

  end

  class InstanceTests < BaseTests
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
      assert_not_same @class_preferences, @preferences
    end

    should "have the same options as the class namespace, but different objects" do
      @class_preferences.__data__.child_options.each do |name, class_opt|
        inst_opt = @preferences.__data__.child_options[name]

        assert_equal    class_opt.name,       inst_opt.name
        assert_equal    class_opt.type_class, inst_opt.type_class
        assert_equal    class_opt.rules,      inst_opt.rules
        assert_not_same class_opt,            inst_opt
      end

      assert_not_equal @class_preferences.home_url, @preferences.home_url
    end

    should "have the same named namespaces as the class, but different objects" do
      @class_preferences.__data__.child_namespaces.each do |name, class_ns|
        assert_not_same class_ns, @preferences.__data__.child_namespaces[name]
      end
    end

  end

  class PreferencesTests < InstanceTests
    desc "preferences"
    setup do
      @preferences = @instance.preferences
      @preferences.home_url = "/home"
      @preferences.show_messages = false
      @preferences.font_size = 15
      @preferences.view.color = "green"
    end
    subject{ @preferences }

    should have_instance_methods :namespace, :option, :define
    should have_accessors :home_url, :show_messages, :font_size
    should have_readers   :view

    should "have set the preference values" do
      assert_equal "/home", subject.home_url
      assert_equal false, subject.show_messages
      assert_equal 15, subject.font_size
      assert_equal "green", subject.view.color
    end

  end

end
