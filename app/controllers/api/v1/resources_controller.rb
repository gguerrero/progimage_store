module Api::V1
  class ResourcesController < ApplicationController
    before_action :resource, only: %i[download]

    def upload
      resource = Resources::Uploader.upload(upload_params)

      if resource.valid?
        render json: Api::V1::ResourceSerializer.new(resource),
               status: :created
      else
        render json: resource.errors, status: :unprocessable_entity
      end
    rescue Resources::NoImageDataError
      render json: { message: 'No image data' }, status: :bad_request
    end

    def download
      respond_to do |format|
        format.json do
          render json: Api::V1::ResourceSerializer.new(resource)
        end

        format.html do
          download = Resources::Downloader.download(
            resource, download_params.to_h
          )

          send_data download[:data],
                    filename: download[:filename],
                    type: download[:content_type]
        end
      end
    end

    private

    def upload_params
      params.permit(:name, :description, :image)
    end

    def download_params
      params.permit(:convert, :resize_to_limit, :rotate)
    end

    def resource
      @resource ||= Resource.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'Not Found' }, status: :not_found
    end
  end
end
