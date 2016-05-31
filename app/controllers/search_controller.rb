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
    if @drgs.empty? && @adrgs.empty? && @mdcs.empty?
      json[:drgs] = @drgs = code_search_tolerant(Drg, @query_codes)
      json[:adrgs] = @adrgs = code_search_tolerant(Adrg, @query_codes)
      json[:mdcs] = @mdcs = code_search_tolerant(Mdc, @query_codes)
    end


    # remove all 'Z' DRGs already present as ADRG
    adrg_codes = @adrgs.map {|adrg| adrg.code}
    @exclude_codes = @drgs.map {|drg| drg.code}
    @exclude_codes.select! {|code| code.ends_with?('Z') && adrg_codes.include?(code[0..2])}

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
      return [] if query.blank? || query.length < 3
      codes = model.search query, where: {version: @system.version},
                           fields: ['code^5', {'text_' + locale.to_s + '^2' => :word_middle}, 'relevant_codes_' + locale.to_s],
                           limit: @limit, highlight: {tag: '<mark>'},
                           misspellings: false
      return codes
    end

    def code_search_tolerant model, query
      return [] if query.blank? || query.length < 3
      codes = model.search query, where: {version: @system.version},
                             fields: ['code^5', {'text_' + locale.to_s + '^2' => :word_middle}, 'relevant_codes_' + locale.to_s],
                             operator: 'or',
                             limit: @limit, highlight: {tag: '<mark>'},
                             misspellings: {below: 1}
      return codes
    end

    def hospital_search query
      return [] if query.blank? || query.length < 3
      hospitals = Hospital.search query, where: {year: @system.base_year},
                                  fields: ['name^2', :street, :address],
                                  match: :word_middle,
                                  limit: @limit, highlight: {tag: '<mark>'},
                                  misspellings: {below: 1}
      if hospitals.empty?
        hospitals = Hospital.search query, where: {year: @system.base_year},
                                    fields: ['name^2', :street, :address],
                                    operator: 'or', match: :word_middle,
                                    limit: @limit, highlight: {tag: '<mark>'}, misspellings: {below: 1}
      end
      return hospitals
    end
end
