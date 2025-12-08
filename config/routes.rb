# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :shelters do
    collection { get :browse }   # /shelters/browse?q=...
    member     { post :join; delete :leave }    # /shelters/:id/join
    resources :animals, only: [:index, :new, :create]
  end

  resources :animals, only: [:show, :edit, :update]

  resources :transfers, only: [:create] do
    member do
      patch :accept
      patch :reject
      patch :mark_in_transit
      patch :mark_received
      patch :cancel
    end
  end


  resources :conversations, only: [:show, :create, :destroy] do
    resources :messages, only: [:create]
  end

  root "home#index"
end
