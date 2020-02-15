module Resources
  class Uploader
    class << self
      def upload(params)
        raise Errors::NoImageDataError if params[:image].nil?

        image_data = params.delete(:image)
        resource = Resource.new(params)
        resource.attach_image(image_data)
        resource.save

        resource
      end
    end
  end
end
