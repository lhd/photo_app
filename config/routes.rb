PhotoApp::Application.routes.draw do
  resources :friendships, :only => [:index, :create, :destroy] do
    member do
      get 'add'
    end
  end
  resources :comments, :only => [:create, :destroy]
  resources :shares, :only => [:index, :show, :create, :destroy]

  resources :users
  
  resources :images do
    member do
      get 'access'
    end
  end
  
  resources :sessions, :only => [:new, :create, :destroy]

  match '/signup',  :to => 'users#new'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  
  match '/image_orders', :to => 'image_orders#update'
  
  match '/contact', :to => 'photo_app#contact'
  match '/about',   :to => 'photo_app#about'
  match '/help',    :to => 'photo_app#help'
  match '/preferences',   :to => 'photo_app#preferences'
  match '/galleries',    :to => 'photo_app#galleries'
  match '/upload',    :to => 'images#new'
  match '/search', :to => 'application#search'
  match '/images/:id/access' => 'images#access'

  root :to => 'photo_app#home'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end