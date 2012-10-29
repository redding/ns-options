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

    should have_class_methods :options, :opts

  end

  class OptionsTests < BaseTest
    desc "options method"

    class WithAKeyTest < OptionsTests
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

    class WithoutAKeyTest < OptionsTests
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

    class AdvisorTests < OptionsTests
      desc "creating a root namespace with a bad name"
      setup do
        @ns_name = "options"
        @output = NsOptions::TestOutput.capture do
          @ns = @class.options(@ns_name.to_sym)
        end
        @advisor = NsOptions::Helper::Advisor.new(@ns)
      end

      should "output a message warning using the method name as a namespace name" do
        expected = @advisor.not_recommended_method_message("namespace", "options")
        assert_match expected, @output.string
      end

    end

  end

end
