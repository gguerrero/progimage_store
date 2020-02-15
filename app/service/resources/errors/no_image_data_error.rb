module Resources
  module Errors
    class NoImageDataError < StandardError
      def initialize(msg = 'No image data')
        super
      end
    end
  end
end
