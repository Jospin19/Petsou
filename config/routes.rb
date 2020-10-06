Rails.application.routes.draw do

  root to: 'users#new'

  # Routes manuelles de gestion de l'user après confirmation et connexion
  # Fait partie des action du controller Users_controller
  #get '/profil' => 'users#edit', as: :profil
  #patch '/profil' > 'users#update'

  get '/profil', to: 'users#edit', as: :profil
  patch '/profil', to: 'users#update'

  #Création des routes pour le controller Session
  # Action new, create => Pour la création des sessions
  # Action destroy => Pour la fermeture ou la suppression des sessions
  #
  # Session: Définition manuelle
  get '/login', to: 'sessions#new', as: :new_session
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :destroy_session

  #Définition avec le système de ressoruce
  #resources :sessions, only: [:new, :create, :destroy]

  #Création des routes pour le controller User
  resources :users, only: [:new, :create] do
    member do
      get 'confirm'
    end
  end

  # Ressource pour le controlleur de MDP
  resources :passwords, only: [:new, :create, :edit, :update]


end
