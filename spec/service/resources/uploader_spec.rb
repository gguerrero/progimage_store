require 'rails_helper'

RSpec.describe Resources::Uploader do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }

  describe '#upload' do
    it 'raises an error when no image source given is provided' do
      params = {
        name: 'a name',
        description: 'a description'
      }

      expect {
        Resources::Uploader.upload(params)
      }.to raise_error(Resources::Errors::NoImageSourceError)
    end

    it 'raises and error when invalid upload mode is given' do
      params = {
        name: 'some name',
        description: 'A valid description',
        mode: 'invalid_upload_mode',
        source: base64_data_uri
      }

      expect {
        Resources::Uploader.upload(params)
      }.to raise_error(Resources::Errors::InvalidUploadModeError)
    end

    it 'returns and invalid resource when invalid params are given' do
      params = {
        description: 'A valid description',
        mode: 'data',
        source: base64_data_uri
      }

      resource = Resources::Uploader.upload(params)
      expect(resource).not_to be_valid
      expect(resource.errors).not_to be_empty
    end

    context 'using data mode' do
      it 'creates a valid resource with an image attached' do
        params = {
          name: 'a name',
          description: 'A valid description',
          mode: 'data',
          source: base64_data_uri
        }

        resource = Resources::Uploader.upload(params)
        expect(resource).to be_valid
        expect(resource.name).to eq params[:name]
        expect(resource.description).to eq params[:description]
      end
    end

    context 'using URL mode' do
      let(:image_url) { 'https://progimage.com/ruby.png' }

      it 'creates a valid resource with and image attached' do
        stubbed_image_request(url: image_url, file: ruby_png)
        params = {
          name: 'a name',
          description: 'A valid description',
          mode: 'url',
          source: image_url
        }

        resource = Resources::Uploader.upload(params)
        expect(resource).to be_valid
        expect(resource.name).to eq params[:name]
        expect(resource.description).to eq params[:description]
      end
    end
  end
end
