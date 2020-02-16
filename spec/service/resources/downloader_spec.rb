require 'rails_helper'

RSpec.describe Resources::Downloader do
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

  describe '#download' do
    it 'returns an error if the resource image is not attached' do
      resource.image.purge

      expect do
        Resources::Downloader.download(resource)
      end.to raise_error(Resources::Errors::ImageNotFoundError)
    end

    it 'returns the filename, data and content_type for a specific resource' do
      download = Resources::Downloader.download(resource)

      expect(download).to eq(
        filename: resource.image.filename.to_s,
        data: resource.image.download,
        content_type: resource.image.content_type
      )
    end
  end
end
