require 'rails_helper'

RSpec.describe Resources::ImageProcessor do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }
  let(:resource) do
    resource = Resource.new(name: 'Ruby', description: 'Is ruby logo!')
    resource.attach_image(base64_data_uri)
    resource.save!

    resource
  end
  let(:process_params) do
    {
      convert: 'jpg',
      resize_to_limit: [100, 100],
      rotate: -90
    }
  end

  describe '#process' do
    it 'returns an error if the resource image is not attached' do
      resource.image.purge

      expect do
        Resources::ImageProcessor.process(resource, process_params)
      end.to raise_error(Resources::Errors::ImageNotFoundError)
    end

    it 'creates a variant with the transformations according to the params' do
      variant = Resources::ImageProcessor.process(resource, process_params)

      expect(variant.variation.transformations).to eq process_params
    end
  end
end
