class HomeController < ApplicationController
  def index
  end

  def redirect
    redirect_to "/#{session[:language] || I18n.locale}"
  end

  def contact
  end

  def documentation
  end
end
