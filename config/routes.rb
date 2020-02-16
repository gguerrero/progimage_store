Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post '/resources/upload', to: 'resources#upload',
                                as: :resources_upload

      get  '/resources/download/:id', to: 'resources#download',
                                      as: :resources_download
    end
  end
end
