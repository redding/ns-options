require 'assert'

require 'ns-options/assert_macros'
require 'test/support/user'

class User

  class BaseTests < Assert::Context
    include NsOptions::AssertMacros

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

    should have_option :home_url
    should have_option :show_messages,  NsOptions::Boolean, :required => true
    should have_option :font_size,      Integer,            :default  => 12

    should have_namespace :view do
      option :color
    end

  end

  class ClassInheritedPreferencesTests < ClassPreferencesTests
    desc "on a subclass of User"
    setup do
      User.preferences.home_url = "/home"
      User.preferences.show_messages = false
      User.preferences.font_size = 15
      User.preferences.view.color = "green"

      @a_sub_class = Class.new(User)
    end
    subject { @a_sub_class.preferences }

    should have_option :home_url
    should have_option :show_messages,  NsOptions::Boolean, :required => true
    should have_option :font_size,      Integer,            :default  => 12

    should have_namespace :view do
      option :color
    end

    should "not have the same preference values as its superclass" do
      assert_not_equal "/home", subject.home_url
      assert_not_equal false, subject.show_messages
      assert_not_equal 15, subject.font_size
      assert_not_equal "green", subject.view.color
    end

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

  class InstancePreferencesTests < InstanceTests
    desc "preferences"
    setup do
      @instance.preferences.home_url = "/home"
      @instance.preferences.show_messages = false
      @instance.preferences.font_size = 15
      @instance.preferences.view.color = "green"
    end
    subject{ @instance.preferences }

    should have_option :home_url
    should have_option :show_messages,  NsOptions::Boolean, :required => true
    should have_option :font_size,      Integer,            :default  => 12

    should have_namespace :view do
      option :color
    end

    should "have set the preference values" do
      assert_equal "/home", subject.home_url
      assert_equal false, subject.show_messages
      assert_equal 15, subject.font_size
      assert_equal "green", subject.view.color
    end

  end

  class InstanceInheritedPreferencesTests < InstancePreferencesTests
    desc "on an instance of a subclass of User"
    setup do
      @a_sub_class = Class.new(User)
      @the_sub_class = @a_sub_class.new
    end
    subject { @the_sub_class.preferences }

    should have_option :home_url
    should have_option :show_messages,  NsOptions::Boolean, :required => true
    should have_option :font_size,      Integer,            :default  => 12

    should have_namespace :view do
      option :color
    end

  end

end
