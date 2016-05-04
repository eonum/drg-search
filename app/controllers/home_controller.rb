class HomeController < ApplicationController
  def index
    redirect_to system_path(System.order(version: :desc).first())
  end

  def redirect
    redirect_to "/#{session[:language] || I18n.locale}"
  end

  def contact
  end

  def about
  end

  def help
  end
end
