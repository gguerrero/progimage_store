require 'rails_helper'

RSpec.describe Api::V1::ResourcesController do
  let(:ruby_png) { File.open('spec/fixtures/ruby.png') }
  let(:base64_data_uri) {
    generate_data64_uri file: ruby_png, content_type: 'image/png'
  }

  describe 'POST /api/v1/resources/upload', type: :request do
    let(:image_url) { 'https://progimage.com/ruby.png' }
    let(:data_params) do
      {
        name: 'Ruby',
        description: 'A description',
        mode: 'data',
        source: base64_data_uri
      }
    end

    let(:url_params) do
      {
        name: 'Ruby',
        description: 'A description',
        mode: 'url',
        source: image_url
      }
    end

    it 'returns 400 bad request when no image source given is provided' do
      data_params.delete(:source)
      post api_v1_resources_upload_path, params: data_params, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eq('message' => 'No image source given')
    end

    it 'returns 400 bad request when invalid mode is provided' do
      data_params[:mode] = 'invalid_mode'
      post api_v1_resources_upload_path, params: data_params, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eq(
        'message' => "Invalid upload mode error, use 'data' or 'url'"
      )
    end

    it 'return 422 unprocessable entity when invalid params are given' do
      data_params.delete(:name)
      post api_v1_resources_upload_path, params: data_params, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response).to eq('name' => ["can't be blank"])
    end

    it 'returns 201 created with valid data params' do
      post api_v1_resources_upload_path, params: data_params, as: :json

      expect(response).to have_http_status(:created)

      resource_id = json_response['data']['id']
      expect(UUID.validate(resource_id)).to be true
      expect(Resource.exists?(resource_id)).to be true
    end

    it 'returns 201 created with valid URL mode params' do
      stubbed_image_request(url: image_url, file: ruby_png)

      post api_v1_resources_upload_path, params: url_params, as: :json

      expect(response).to have_http_status(:created)

      resource_id = json_response['data']['id']
      expect(UUID.validate(resource_id)).to be true
      expect(Resource.exists?(resource_id)).to be true
    end
  end

  describe 'GET /api/v1/resources/download', type: :request do
    let(:resource) do
      resource = Resource.new(name: 'Ruby', description: 'Is ruby logo!')
      resource.attach_image_from_data(base64_data_uri)
      resource.save!

      resource
    end

    it 'returns 404 Not Found when the given ID does not exist' do
      get api_v1_resources_download_path(UUID.generate)

      expect(response).to have_http_status(:not_found)
      expect(json_response).to eq('message' => 'Not Found')
    end

    it 'returns a JSON response with the raw base64 image' do
      get api_v1_resources_download_path(resource.id), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(
        Api::V1::ResourceSerializer.new(resource).serialized_json
      )
    end

    it 'returns 404 not found error when the image is not attached' do
      resource.image.purge

      get api_v1_resources_download_path(resource.id), as: :html

      expect(response).to have_http_status(:not_found)
      expect(json_response).to eq('message' => 'Image not found for resource')
    end

    it 'send data with the raw image stream' do
      get api_v1_resources_download_path(resource.id), as: :html

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Disposition']).to eq(
        "attachment; filename=\"ruby.png\"; filename*=UTF-8''ruby.png"
      )

      ruby_png.rewind
      expect(response.body.size).to eq ruby_png.size
    end
  end

  describe 'POST /api/v1/resources/convert', type: :request do
    let(:resource) do
      resource = Resource.new(name: 'Ruby', description: 'Is ruby logo!')
      resource.attach_image_from_data(base64_data_uri)
      resource.save!

      resource
    end
    let(:convert_params) do
      {
        convert: 'jpg',
        resize_to_limit: [100, 100],
        rotate: -90
      }
    end

    it 'returns 404 not found when the image is not attached' do
      resource.image.purge

      post api_v1_resources_convert_path(resource.id), params: convert_params,
                                                       as: :json

      expect(response).to have_http_status(:not_found)
      expect(json_response).to eq('message' => 'Image not found for resource')
    end

    it 'returns a variant image URL and key pointing to the image inline' do
      post api_v1_resources_convert_path(resource.id), params: convert_params,
                                                       as: :json

      expect(response).to have_http_status(:created)
      expect(json_response['data']['key']).not_to be_blank
      expect(json_response['data']['variantImageUrl']).not_to be_blank

      get json_response['data']['variantImageUrl']
    end
  end
end
