module Resources
  module Errors
    class NoImageSourceError < StandardError
      def initialize(msg = 'No image source given')
        super
      end
    end
  end
end
