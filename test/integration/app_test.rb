require 'assert'

module App

  class BaseTest < Assert::Context
    desc "the App module"
    setup do
      @module = App
    end
    subject{ @module }

    should have_instance_methods :options, :settings

  end

  class DefineTest < BaseTest
    desc "defined"
    setup do
      stage = @stage = "test"
      root_path = @root_path = File.expand_path("../../..", __FILE__)
      logger = @logger = Logger.new(File.join(@root_path, "log", "test.log"))
      run = @run = true
      @module.settings.define do |namespace|
        namespace.stage stage
        namespace.root = root_path
        namespace.logger = logger

        namespace.sub do
          run_commands run
        end
      end
    end
    subject{ @module.settings }

    should have_instance_methods :namespace, :option, :define, :options, :metaclass
    should have_accessors :stage, :root, :logger
    should have_instance_methods :sub

    should "have set the stage to 'test'" do
      assert_equal @stage, subject.stage
    end
    should "have set the root to this gem's dir" do
      assert_equal Pathname.new(@root_path), subject.root
    end
    should "have set the logger to the passed logger" do
      assert_equal @logger, subject.logger
      assert_same @logger, subject.logger
    end
  end
  
  class SubNamespaceTest < DefineTest
    desc "the sub namespace"
    subject{ @module.settings.sub }
    
    should "have set the run_commands option" do
      assert_equal @run, subject.run_commands
    end
    should "have access to it's parent's options" do
      assert_equal @stage, subject.stage
    end
  end

end
