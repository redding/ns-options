require 'assert'

module NsOptions::HasOptions

  class BaseTest < Assert::Context
    desc "NsOptions::HasOptions"
    setup do
      @class = Class.new do
        include NsOptions::HasOptions

        def configs_key
          "random_class_#{self.object_id}"
        end
      end
      @instance = @class.new
    end
    subject{ @instance }

    should have_class_methods :options
  end

  class OptionsTest < BaseTest
    desc "options method"

    class WithAKeyTest < OptionsTest
      desc "with a key"
      setup do
        @key = "configs-key"
        @class.options(:configs, @key) do
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
      should "have used the provided block to define the namespace" do
        assert_respond_to :something, subject.configs
        assert_respond_to :something=, subject.configs
        assert subject.configs.options.fetch(:something)
      end
    end
    class WithoutAKeyTest < OptionsTest
      desc "without a key"
      setup do
        @name = "configs"
        @class.options(@name.to_sym)
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
