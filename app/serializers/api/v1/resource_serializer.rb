module Api::V1
  class ResourceSerializer
    include FastJsonapi::ObjectSerializer

    set_key_transform :camel_lower

    attributes :name, :description

    attribute :content_type do |object|
      object.image.content_type if object.image.attached?
    end

    attribute :image_filename do |object|
      object.image.filename.to_s if object.image.attached?
    end

    attribute :image_data do |object|
      Base64.encode64(object.image.download) if object.image.attached?
    end

    link :image_url do |object|
      if object.image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(object.image)
      end
    end
  end
end
