class SearchController < ApplicationController
  include SearchHelper

  before_action :set_variables

  # JSON / HTML API for hospital search
  # parameters:
  # term: search term
  # limit: maximum number of items
  def hospitals
    @hospitals = hospital_search @query

    respond_to do |format|
      format.json { render json: @hospitals.map { |hospital| {:id => hospital.id.to_s, :code => hospital.hospital_id, :text => hospital.name}}}
      format.html { render partial: 'search_results_hospitals' }
    end
  end

  # JSON / HTML API for code search
  # parameters:
  # term: search term
  # limit: maximum number of items
  # level: one of 'drg', 'adrg', 'mdc'
  def codes
    model = {'drg' => Drg, 'mdc' => Mdc, 'adrg' => Adrg}[params[:level]]
    model = Drg if model.nil?

    @codes = code_search model, @query

    respond_to do |format|
      format.json { render json: @codes.map { |code| {:id => code.id.to_s, :code => code.code, :text => code.text(@locale)}}}
      format.html { render partial: 'search_results_codes', locals: {codes: @codes} }
    end
  end

  # JSON / HTML API for codes and hospital search
  # parameters:
  # term_hospital: search term for hospitals
  # term_codes: search term for codes
  # limit: maximum number of items
  def all
    @query_codes = params[:term_codes].blank? ? '' : params[:term_codes]
    @query_hospital = params[:term_hospitals].blank? ? '' : params[:term_hospitals]

    json = {}
    json[:drgs] = @drgs = code_search(Drg, @query_codes)
    json[:adrgs] = @adrgs = code_search(Adrg, @query_codes)
    json[:mdcs] = @mdcs = code_search(Mdc, @query_codes)
    json[:hospitals] = @hospitals = hospital_search @query_hospital

    respond_to do |format|
      format.json { render json: json}
      format.html { render partial: 'systems/search_results' }
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

    def code_search model, query
      return [] if query.blank?
      return model.where("version = '#{@system.version}' and (code ILIKE ? or text_#{@locale} ILIKE ?)", "%#{Regexp.escape(query)}%", "%#{Regexp.escape(query)}%")
                 .order(code: :asc).limit(@limit)
    end

    def hospital_search query
      return [] if query.blank?
      Hospital.where("year = '#{@system.base_year}' and (name ILIKE ? or address ILIKE ?)", "%#{Regexp.escape(query)}%", "%#{Regexp.escape(query)}%")
          .order(name: :asc).limit(@limit)
    end
end
