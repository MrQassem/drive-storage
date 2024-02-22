Rails.application.routes.draw do
  get 'health/live', to: 'health_check#live'

  # Namespaced routes for v1
  namespace :v1 do
    resources :blobs, only: [:create, :show]
  end
end
