class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_locale
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    session[:locale] = I18n.locale
  end

  def default_url_options
    { :locale => I18n.locale }
  end

  def escape_query query
    return (query or '').gsub(/\\/, '\&\&').gsub(/'/, "''")
  end

end
