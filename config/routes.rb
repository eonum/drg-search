Rails.application.routes.draw do
  root to: 'home#redirect'

  # redirect all English requests except the landing page to its German equivalents
  get '/en/systems/*path', to: redirect("/de/systems/%{path}")

  scope '/:locale', :locale => /de|fr|it|en/, :format => /json|html/ do
    get '', to: 'home#index', as: 'home'
    get 'contact', to: 'home#contact'
    get 'documentation', to: 'home#documentation'

    resources :systems,  only: ['index', 'show'] do
      get :compare, on: :member
      get 'search/all'
      resources :hospitals, only: [:show]
      resources :codes, only: [:show]
    end
  end
end
