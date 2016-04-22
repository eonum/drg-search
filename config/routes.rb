Rails.application.routes.draw do
  root to: 'home#redirect'

  scope '/:locale', :locale => /de|fr|it/, :format => /json|html/ do
    get '', to: 'home#index', as: 'home'
    get 'contact', to: 'home#contact'
    get 'about', to: 'home#about'
    get 'help', to: 'home#help'


    resources :systems,  only: ['index', 'show'] do
      get 'search/hospitals'
      get 'search/codes'
    end
  end
end
