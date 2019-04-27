Rails.application.routes.draw do
  
  root 'static_pages#home'
  
  get    '/chat', to: 'rooms#show'
  post '/chat/destroy' => 'rooms#destroy'
  
  get 'password_resets/new'
  get 'password_resets/edit'

  get 'sessions/new'
  
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  
  get '/pictures',  to: 'pictures#new'
  get 'pictures/list',  to: 'pictures#list'
  
  get '/signup', to: 'users#new'
  post '/signup',  to: 'users#create'
  
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]
  resources :pictures, only: [:create, :index, :destroy]
  
  # Serve websocket cable requests in-process
  mount ActionCable.server => '/cable'
end
