class SystemsController < ApplicationController
  before_action :set_variables, :except => ['index']
  after_filter :track_action

  def show
  end

  def compare
    render partial: 'results'
  end

  def index
    @system = System.order(version: :desc).first()
    redirect_to system_path(@system)
  end


  protected
    def track_action
      ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
      ahoy.track_visit
    end

  private
    def set_variables
      @system = System.find(params[:id])
      @hospitals_url_query = params[:hospitals]
      params_hospitals = params[:hospitals] == nil ? [] : params[:hospitals].split(',').map {|id| id.to_i}

      # Keep the order. I'm sure this could be done more elegant.
      hops = Hospital.where(id: params_hospitals)
      temp = {}
      hops.each {|h| temp[h.id] = h}
      @hospitals = params_hospitals.map{|id| temp[id] }
      @hospitals.reject! {|h| h.nil?}

      @codes_url_query = params[:codes]
      param_codes = params[:codes] == nil ? [] : params[:codes].split(',')
      @codes = Mdc.where(code: param_codes, version: @system.version)
      @codes += Drg.where(code: param_codes, version: @system.version)
      @codes += Adrg.where(code: param_codes, version: @system.version)
      @codes += Partition.where(code: param_codes, version: @system.version)
      temp = {}
      @codes.each {|c| temp[c.code] = c}
      @codes = param_codes.map{|code| temp[code] }
      @codes.reject! {|c| c.nil?}

      @hop_ids = @hospitals.map {|h| h.hospital_id }
      codes = @codes.map {|c| c.code }
      temp_num_cases = NumCase.where(version: @system.version, year: @system.base_year, hospital_id: @hop_ids, code: codes)
      @num_cases = {}
      @hop_ids.each do |hop_id|
        @num_cases[hop_id] = {}
      end
      temp_num_cases.each do |nc|
        @num_cases[nc.hospital_id][nc.code] = nc
      end
    end
end
