Ppclient::Application.routes.draw do
  match 'merchants/request_permissions_callback' => 'merchants#request_permissions_callback', :via => [ :get ], :as => :merchants_request_permissions_callback
  resources :merchants
end
