Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :readings
    resources :thermostats do
      get :stats, on: :member
    end
  end
end
