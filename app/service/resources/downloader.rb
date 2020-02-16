module Resources
  class Downloader
    class << self
      def download(resource, options = {})
        return {} unless resource.image.attached?

        _variant = transform(resource.image, options)

        {
          filename: resource.image.filename.to_s,
          data: resource.image.download,
          content_type: resource.image.content_type
        }
      end

      private

      def transform(image, opts)
        image.variant(opts)
      end
    end
  end
end
