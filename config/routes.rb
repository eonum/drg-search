Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/, defaults: {locale: "de"} do

  end
end
