module Api::V1
  class ResourceSerializer
    include FastJsonapi::ObjectSerializer
    # include Rails.application.routes.url_helpers

    set_key_transform :camel_lower

    attributes :name, :description

    attribute :content_type do |object|
      return unless object.image.attached?

      object.image.content_type
    end

    attribute :image_filename do |object|
      return unless object.image.attached?

      object.image.filename.to_s
    end

    attribute :image_data do |object|
      return unless object.image.attached?

      Base64.encode64(object.image.download)
    end

    link :image_url do |object|
      return unless object.image.attached?

      Rails.application.routes.url_helpers.rails_blob_url(object.image)
    end
  end
end
