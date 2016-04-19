class SystemsController < ApplicationController
  def compare
    @system = System.find(params[:id])
  end

  def index
    @system = System.order(version: :desc).first()
    redirect_to action: 'compare', id: @system.id
  end
end
