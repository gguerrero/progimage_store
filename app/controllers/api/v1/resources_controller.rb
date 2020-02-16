module Api::V1
  class ResourcesController < ApplicationController
    before_action :resource, only: %i[download process]

    def upload
      resource = Resources::Uploader.upload(upload_params)

      if resource.valid?
        render json: Api::V1::ResourceIdSerializer.new(resource),
               status: :created
      else
        render json: resource.errors, status: :unprocessable_entity
      end
    rescue Resources::Errors::NoImageDataError => e
      render json: { message: e.message }, status: :bad_request
    end

    def download
      respond_to do |format|
        format.json do
          render json: Api::V1::ResourceSerializer.new(resource)
        end

        format.html do
          download = Resources::Downloader.download(resource)

          send_data download[:data],
                    filename: download[:filename],
                    type: download[:content_type]
        rescue Resources::Errors::ImageNotFoundError => e
          render json: { message: e.message }, status: :not_found
        end
      end
    end

    def convert
      variant = Resources::ImageProcessor.process(resource, process_params.to_h)

      render json: Api::V1::ResourceVariantSerializer.new(variant),
             status: :created

    rescue Resources::Errors::ImageNotFoundError => e
      render json: { message: e.message }, status: :not_found
    end

    private

    def upload_params
      params.permit(:name, :description, :image)
    end

    def process_params
      params.permit(:convert, :format, :flip, :rotate, resize_to_limit: [])
    end

    def resource
      @resource ||= Resource.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { message: 'Not Found' }, status: :not_found
    end
  end
end
