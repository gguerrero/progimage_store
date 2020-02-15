require 'rails_helper'

RSpec.describe Resources::Uploader do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }

  describe '#upload' do
    it 'raises an error when no image data is provided' do
      params = {
        name: 'a name',
        description: 'a description'
      }

      expect {
        Resources::Uploader.upload(params)
      }.to raise_error(Resources::Errors::NoImageDataError)
    end

    it 'returns and invalid resource when invalid params are given' do
      params = {
        description: 'A valid description',
        image: base64_data_uri
      }

      resource = Resources::Uploader.upload(params)
      expect(resource).not_to be_valid
      expect(resource.errors).not_to be_empty
    end

    it 'creates a valid resource with valid attributes and returns it' do
      params = {
        name: 'a name',
        description: 'A valid description',
        image: base64_data_uri
      }

      resource = Resources::Uploader.upload(params)
      expect(resource).to be_valid
      expect(resource.name).to eq params[:name]
      expect(resource.description).to eq params[:description]
    end
  end
end
