module Resources
  module Errors
    class InvalidUploadModeError < StandardError
      def initialize(msg = "Invalid upload mode error, use 'data' or 'url'")
        super
      end
    end
  end
end
