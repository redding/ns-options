require 'assert'

class User

  class BaseTest < Assert::Context
    desc "the User class"
    setup do
      @class = User
    end
    subject{ @class }

    should have_instance_methods :configurable, :preferences
  end

  class ClassPreferencesTest < BaseTest
    desc "preferences"
    subject{ @class.preferences }

    should have_instance_methods :namespace, :option, :configure, :options, :metaclass
    should have_accessors :home_url, :show_messages, :font_size
  end

  class InstanceTest < BaseTest
    desc "instance"
    setup do
      @instance = @class.new
    end
    subject{ @instance }

    should have_instance_methods :preferences
  end

  class PreferencesTest < InstanceTest
    desc "preferences"
    setup do
      @preferences = @instance.preferences
      puts @instance.preferences.class.public_instance_methods(false).inspect
      #@preferences.home_url = "/home"
      #@preferences.show_messages = false
      #@preferences.font_size = 15
    end
    subject{ @preferences }

    should have_instance_methods :namespace, :option, :configure, :options, :metaclass
    should have_accessors :home_url, :show_messages, :font_size
=begin
    should "have set the home_url" do
      assert_equal "/home", subject.home_url
    end
    should "have set show_messages" do
      assert_equal false, subject.show_messages
    end
    should "have set the font_size" do
      assert_equal 15, subject.font_size
    end
=end
  end

end
