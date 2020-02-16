require 'rails_helper'

RSpec.describe Api::V1::ResourceVariantSerializer do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }
  let(:variant) do
    resource = Resource.new(name: 'Ruby', description: 'Is ruby logo!')
    resource.attach_image_from_data(base64_data_uri)
    resource.save!

    resource.image.variant(convert: 'jpg')
  end

  context 'serializing it as JSON' do
    it 'returns a hash with the expected attributes' do
      serializer = Api::V1::ResourceVariantSerializer.new(variant)
      data = serializer.as_json[:data]

      expect(data).to eq(
        key: variant.key,
        variantImageUrl: Rails.application
                              .routes
                              .url_helpers
                              .rails_representation_url(variant)
      )
    end
  end
end
