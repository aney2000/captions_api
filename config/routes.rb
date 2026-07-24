Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Auth
  post "signup", to: "users#signup"
  post "login", to: "users#login"

  # Meme 
  post "memes", to: "memes#create"

  # Captions
  post "captions/instagram",  to: "instagram_captions#create"
  post "captions/instagrams", to: "instagram_captions#create"
  get  "captions/instagram",  to: "instagram_captions#index"
  get  "captions/instagrams", to: "instagram_captions#index"

  resources :captions, only: %i[index show create destroy]
end
