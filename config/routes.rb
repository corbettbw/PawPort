# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  resources :shelters do
    collection { get :browse }   # /shelters/browse?q=...
    member     { post :join; delete :leave }    # /shelters/:id/join
  end

  root "home#index"
end
