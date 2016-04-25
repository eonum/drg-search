class SystemsController < ApplicationController
  before_action :set_variables, :except => ['index']

  def show
  end

  def compare
    render partial: 'results'
  end

  def index
    @system = System.order(version: :desc).first()
    redirect_to system_path(@system)
  end

  private
    def set_variables
      @system = System.find(params[:id])
      params_hospitals = params[:hospitals] == nil ? [] : params[:hospitals].split(',')
      @hospitals = Hospital.where(id: params_hospitals)
      param_codes = params[:codes] == nil ? [] : params[:codes].split(',')
      @codes = Mdc.where(code: param_codes, version: @system.version)
      @codes += Drg.where(code: param_codes, version: @system.version)
      @codes += Adrg.where(code: param_codes, version: @system.version)
      @codes += Partition.where(code: param_codes, version: @system.version)
    end
end
