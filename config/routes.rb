Rails.application.routes.draw do
  root to: 'home#index', locale: :de
  scope "(:locale)", locale: [/#{I18n.available_locales.join("|")}/], defaults: {locale: :de} do
    get 'home/index'
  end
end
