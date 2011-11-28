module NsOptions
  module Errors

    class InvalidName < StandardError
      attr_accessor :message

      def initialize(message, backtrace)
        self.message = message
        self.set_backtrace(backtrace)
      end

    end

  end
end
