require 'rails_helper'

RSpec.describe Resource do
  context 'on missing attributes' do
    let(:resource) { Resource.new }

    it 'return error when name is not present' do
      expect(resource.valid?).to be false
      expect(resource.errors[:name]).to eq ["can't be blank"]
    end

    it 'returns an error when the image is not attached' do
      expect(resource.valid?).to be false
      expect(resource.errors[:image]).to eq ['is not attached']
    end
  end

  context 'with the right attributes' do
    let(:ruby_file) { File.open('spec/fixtures/ruby.png') }
    let(:resource) { Resource.new name: 'Ruby', description: 'Is ruby logo!' }

    it 'creates a resource and autogenerate the UUID' do
      data64_uri = generate_data64_uri file: ruby_file, content_type: 'image/png'
      resource.image.attach(data: data64_uri, filename: 'ruby.png')

      expect(resource.valid?).to be true
      expect(resource.save).to be true
      expect(UUID.validate(resource.id)).to be true
      expect(resource.image.download.size).to eq File.size(ruby_file)

      new_resource = Resource.find(resource.id)

      expect(new_resource.name).to eq 'Ruby'
      expect(new_resource.description).to eq 'Is ruby logo!'
    end
  end
end

def generate_data64_uri(file:, content_type: )
  "data:#{content_type};base64,#{Base64.encode64(file.read)}"
end
