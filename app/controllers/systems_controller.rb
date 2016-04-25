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

      hop_ids = @hospitals.map {|h| h.hospital_id }
      codes = @codes.map {|c| c.code }
      temp_num_cases = NumCase.where(version: @system.version, year: @system.base_year, hospital_id: hop_ids, code: codes)
      @num_cases = {}
      hop_ids.each do |hop_id|
        @num_cases[hop_id] = {}
      end
      temp_num_cases.each do |nc|
        @num_cases[nc.hospital_id][nc.code] = nc
      end
    end
end
