require 'rails_helper'

RSpec.describe Api::V1::ResourceSerializer do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }
  let(:resource) do
    resource = Resource.new(name: 'Ruby', description: 'Is ruby logo!')
    resource.attach_image_from_data(base64_data_uri)
    resource.save!

    resource
  end

  context 'serializing it as JSON' do
    it 'returns a hash with the expected attributes' do
      serializer = Api::V1::ResourceSerializer.new(resource)
      data = serializer.serializable_hash[:data]

      expect(data[:id]).to eq resource.id
      expect(data[:type]).to eq :resource
      expect(data[:attributes][:name]).to eq resource.name
      expect(data[:attributes][:description]).to eq resource.description
      expect(data[:attributes][:contentType]).to eq resource.image.content_type
      expect(data[:attributes][:imageFilename]).to eq resource.image.filename.to_s
      expect(data[:attributes][:imageData]).to eq(
        Base64.encode64(resource.image.download)
      )
      expect(data[:links][:imageUrl]).to eq(
        Rails.application.routes.url_helpers.rails_blob_url(resource.image)
      )
    end
  end
end
