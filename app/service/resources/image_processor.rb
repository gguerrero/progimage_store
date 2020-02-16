module Resources
  class ImageProcessor
    class << self
      def process(resource, options = {})
        raise Errors::ImageNotFoundError unless resource.image.attached?

        create_variant(resource.image, options)
      end

      private

      def create_variant(image, opts)
        image.variant(opts)
      end
    end
  end
end
