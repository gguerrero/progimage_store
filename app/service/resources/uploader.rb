module Resources
  class Uploader
    class << self
      def upload(params)
        raise Errors::NoImageSourceError if params[:source].blank?

        mode = params.delete(:mode)
        source = params.delete(:source)

        resource = Resource.new(params)
        attach_image(resource, mode, source)
        resource.save

        resource
      end

      private

      def attach_image(resource, mode, source)
        case mode
        when 'data'
          resource.attach_image_from_data(source)
        when 'url'
          resource.attach_image_from_url(source)
        else
          raise Errors::InvalidUploadModeError
        end
      end
    end
  end
end
