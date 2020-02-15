Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post '/resources/upload', to: 'resources#upload'
      get '/resources/download/:id', to: 'resources#download'
    end
  end
end
