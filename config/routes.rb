Cse280::Application.routes.draw do
  
  resources :user_sessions
  resources :users
  
  #user routes
  get "register" => "users#new",   :as => 'register'
  get "login" => "user_sessions#new",  :as => 'login'
  get "logout" => "user_sessions#destroy", :as => 'logout'
  
  #restaurant routes
  get "restaurant" => "restaurant#index"
  match "restaurant/order/(:category)/(:id)" => "restaurant#order"
  match "restaurant/order" => "restaurant#order"
  get "restaurant/range" => "restaurant#range"
  match "restaurant/processing/(:restaurant_id)" => "restaurant#processing", :as => 'restaurant_processing'

  #home routes
  root :to => "home#index"
   
  get "about" => "home#about"
  get "advertise" => "home#advertise"
  get "contact" => "home#contact"
  get "terms" => "home#terms"
  get "jobs" => "home#jobs"
  

end
