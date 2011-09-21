require 'assert'

module NsOptions::Configurable

  class BaseTest < Assert::Context
    desc "NsOptions::Configurable"
    setup do
      @class = Class.new do
        include NsOptions::Configurable

        def configs_key
          "random_class_#{self.object_id}"
        end
      end
      @instance = @class.new
    end
    subject{ @instance }

    should have_class_methods :configurable
  end

  class ConfigurableTest < BaseTest
    desc "configurable method"

    class WithAKeyTest < ConfigurableTest
      desc "with a key"
      setup do
        @key = "configs-key"
        @class.configurable(:configs, @key) do
          option :something
        end
        @instance = @class.new
      end
      subject{ @instance }

      should have_class_method :configs
      should have_instance_method :configs

      should "have used the provided key when creating the namespace" do
        assert_kind_of NsOptions::Namespace, subject.class.configs
        assert_kind_of NsOptions::Namespace, subject.configs
        assert_equal @key, subject.class.configs.options.key
        assert_match @key, subject.configs.options.key
      end
      should "have used the provided block to configure the namespace" do
        assert_respond_to :something, subject.configs
        assert_respond_to :something=, subject.configs
        assert subject.configs.options.fetch(:something)
      end
    end
    class WithoutAKeyTest < ConfigurableTest
      desc "without a key"
      setup do
        @name = "configs"
        @class.configurable(@name.to_sym)
        @instance = @class.new
      end
      subject{ @instance }
      
      should "have used the name for the key when creating the namespace" do
        assert_equal @name, subject.class.configs.options.key
        assert_match @name, subject.configs.options.key
      end
    end
  end

end
