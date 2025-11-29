# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :shelters do
    collection { get :browse }   # /shelters/browse?q=...
    member     { post :join; delete :leave }    # /shelters/:id/join
    resources :animals, only: [:index, :new, :create]
  end

  resources :animals, only: [:show, :edit, :update]
  root "home#index"
end
