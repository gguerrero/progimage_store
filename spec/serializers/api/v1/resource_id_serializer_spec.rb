require 'rails_helper'

RSpec.describe Api::V1::ResourceIdSerializer do
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
      serializer = Api::V1::ResourceIdSerializer.new(resource)
      data = serializer.serializable_hash[:data]

      expect(data).to eq(id: resource.id, type: :resource_id)
    end
  end
end
