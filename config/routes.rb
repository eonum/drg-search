Rails.application.routes.draw do
  root to: 'home#redirect'

  scope '/:locale', :locale => /de|fr|it/, :format => /json|html/ do
    get '', to: 'home#index', as: 'home'

    resources :systems,  only: ['index'] do
      get :compare, :on => :member
    end
  end
end
