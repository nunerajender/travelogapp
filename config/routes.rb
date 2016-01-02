Rails.application.routes.draw do

 
  
  

  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks",
                                      :registrations => "registrations"}
  root 'home#index'

  get 'products/result' => 'products#result'
  post 'products/result' => 'products#result'
  post 'products/result_filter' => 'products#result_filter'
  post 'home/search' => 'home#search'
  post 'set_currency' => 'application#set_currency'


  resources :products
  resources :store
  resources :product_attachments
  resources :store_images
  resources :user_avatars

  get 'become_merchant' => 'users#become_merchant'
  post 'become_merchant' => 'users#become_merchant'
  get 'profile' => 'users#profile'
  post 'profile' => 'users#profile'
  patch 'profile' => 'users#profile'
  get 'profile/avatar' => 'users#profile_avatar'
  post 'profile/avatar' => 'users#profile_avatar'
  patch 'profile/avatar' => 'users#profile_avatar'
  get 'profile/accounts' => 'users#profile_accounts'
  post 'profile/accounts' => 'users#profile_accounts'
  patch 'profile/accounts' => 'users#profile_accounts'

  get 'profile/photos' => 'users#photos'
  post 'profile/photos' => 'users#photos'
  post 'complete_merchant' => 'users#complete_merchant'

  get 'users/verify_store_username' => 'users#verify_store_username'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
