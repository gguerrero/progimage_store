module Resources
  class Downloader
    class << self
      def download(resource)
        raise Errors::ImageNotFoundError unless resource.image.attached?

        {
          filename: resource.image.filename.to_s,
          data: resource.image.download,
          content_type: resource.image.content_type
        }
      end
    end
  end
end
