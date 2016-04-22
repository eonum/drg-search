class SearchController < ApplicationController
  include SearchHelper

  before_action :set_variables

  # JSON API for hospital search
  # parameters:
  # term: search term
  # limit: maximum number of items
  def hospitals
    @hospitals = Hospital.where("year = '#{@system.base_year}' and (name ILIKE ? or address ILIKE ?)", "%#{Regexp.escape(@query)}%", "%#{Regexp.escape(@query)}%")
                .order(name: :asc).limit(@limit)

    respond_to do |format|
      format.json { render json: @hospitals.map { |hospital| {:id => hospital.id.to_s, :code => hospital.hospital_id, :text => hospital.name}}}
      format.html { render partial: 'search_results_hospitals' }
    end
  end

  # JSON API for code search
  # parameters:
  # term: search term
  # limit: maximum number of items
  # level: one of 'drg', 'adrg', 'mdc'
  def codes
    model = {'drg' => Drg, 'mdc' => Mdc, 'adrg' => Adrg}[params[:level]]
    model = Drg if model.nil?

    @codes = model.where("version = '#{@system.version}' and (code ILIKE ? or text_#{@locale} ILIKE ?)", "%#{Regexp.escape(@query)}%", "%#{Regexp.escape(@query)}%")
                .order(code: :asc).limit(@limit)

    respond_to do |format|
      format.json { render json: @codes.map { |code| {:id => code.id.to_s, :code => code.code, :text => code.text(@locale)}}}
      format.html { render partial: 'search_results_codes' }
    end
  end

  private
    def set_variables
      @system = System.find(params[:system_id])
      @query = params[:term].blank? ? '' : params[:term]
      @limit = params[:limit].blank? ? 5 : params[:limit].to_i
      @locale =  check_locale(params[:locale])
    end

    def check_locale locale
      if(locale != 'fr' && locale != 'it')
        locale = 'de'
      end
      return locale
    end
end
