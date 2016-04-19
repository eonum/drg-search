class SystemsController < ApplicationController
  def show
    @system = System.find(params[:id])
  end

  def index
    @system = System.order(version: :desc).first()
    redirect_to system_path(@system)
  end
end
