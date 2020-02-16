require 'rails_helper'

RSpec.describe Resource do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }

  context 'on missing attributes' do
    let(:resource) { Resource.new }

    it 'return error when name is not present' do
      expect(resource).not_to be_valid
      expect(resource.errors[:name]).to eq ["can't be blank"]
    end

    it 'returns an error when the image is not attached' do
      expect(resource).not_to be_valid
      expect(resource.errors[:image]).to eq [
        I18n.t('activerecord.errors.messages.attached')
      ]
    end
  end

  context 'with the right attributes' do
    let(:resource) { Resource.new name: 'Ruby', description: 'Is ruby logo!' }

    it 'creates a resource and autogenerate the UUID' do
      resource.attach_image_from_data(base64_data_uri)

      expect(resource).to be_valid
      expect(resource.save).to be true
      expect(UUID.validate(resource.id)).to be true
      expect(resource.image.download.size).to eq File.size(ruby_png)

      new_resource = Resource.find(resource.id)

      expect(new_resource.name).to eq 'Ruby'
      expect(new_resource.description).to eq 'Is ruby logo!'
    end
  end

  context 'attaching image from data' do
    let(:resource) { Resource.new name: 'Ruby', description: 'Is ruby logo!' }

    it 'returns false and add errors when the input data does not match the format' do
      invalid_date64_uri = 'invalid_data:image/png;base32,NotAValidData'

      expect(resource.attach_image_from_data(invalid_date64_uri)).to be_nil
      expect(resource.errors[:image]).to eq [
        I18n.t('activerecord.errors.messages.invalid_data_base64_uri')
      ]
    end

    it 'attached the image with a composed filename from name + content_type' do
      resource.attach_image_from_data(base64_data_uri)

      expect(resource.image).to be_attached
      expect(resource.image.filename.to_s).to eq 'ruby.png'
    end
  end

  context 'attaching with from remote URL' do
    let(:image_url) { 'https://progimage.com/ruby.png' }
    let(:resource) { Resource.new name: 'Ruby', description: 'Is ruby logo!' }

    it 'attached the image with a composed filename from name' do
      stubbed_image_request(url: image_url, file: ruby_png)

      resource.attach_image_from_url(image_url)

      expect(resource.image).to be_attached
      expect(resource.image.filename.to_s).to eq 'ruby'
    end
  end
end
