Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  # add the glob route (captures filenames with dots)
  get "/files/*filename/download", to: "files#download", as: :download_file

  # keep the resources for index/create
  resources :files, only: [:index, :create], param: :filename

  root to: "files#index"
end
