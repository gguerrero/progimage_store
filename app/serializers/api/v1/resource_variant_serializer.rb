module Api::V1
  class ResourceVariantSerializer
    attr_reader :object

    def initialize(variant)
      @object = variant
    end

    def as_json(_opts = {})
      {
        data: {
          key: object.key,
          variantImageUrl: Rails.application
                                .routes
                                .url_helpers
                                .rails_representation_url(object)
        }
      }
    end
  end
end
