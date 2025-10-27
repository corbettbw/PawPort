# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :shelters
  root "home#index"
end
