class SearchController < ApplicationController
  include SearchHelper

  before_action :set_variables

  # JSON / HTML API for codes and hospital search
  # parameters:
  # term_hospital: search term for hospitals
  # term_codes: search term for codes
  # limit: maximum number of items
  def all
    @query_codes = params[:term_codes].blank? ? '' : params[:term_codes]
    @query_hospital = params[:term_hospitals].blank? ? '' : params[:term_hospitals]

    if @locale.to_s == 'de'
      @query_codes.gsub!('ue', 'u')
      @query_codes.gsub!('ae', 'a')
      @query_codes.gsub('oe', 'o')
    end

    if @query_codes.blank? || @query_codes.length < 3
      @drgs = []
      @adrgs = []
      @mdcs = []
    else
      @drgs = code_search(Drg, @query_codes, 'code')
      @adrgs = code_search(Adrg, @query_codes, 'code')
      @mdcs = code_search(Mdc, @query_codes, 'code_search')
      Searchkick.multi_search([@drgs, @adrgs, @mdcs])

      if @drgs.empty? && @adrgs.empty? && @mdcs.empty? && @query_codes.length > 5
        @drgs = code_search_tolerant(Drg, @query_codes, 'code')
        @adrgs = code_search_tolerant(Adrg, @query_codes, 'code')
        @mdcs = code_search_tolerant(Mdc, @query_codes, 'code_search')
        Searchkick.multi_search([@drgs, @adrgs, @mdcs])
      end
    end

    json = {}
    json[:drgs] = @drgs
    json[:adrgs] = @adrgs
    json[:mdcs] = @mdcs

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

    def check_locale loc
      if(loc != 'fr' && loc != 'it')
        loc = 'de'
      end
      return loc
    end

    def code_search model, query, code_field
      return model.search query, where: {version: @system.version},
                           fields: [code_field + '^5', 'text_' + @locale.to_s + '^2', 'relevant_codes_' + @locale.to_s],
                           limit: @limit, highlight: {tag: '<mark>'},
                           misspellings: false, execute: false
    end

    def code_search_tolerant model, query, code_field
      return model.search query, where: {version: @system.version},
                             fields: [code_field + '^5', {'text_' + @locale.to_s + '^2' => :word_middle}, 'relevant_codes_' + @locale.to_s],
                             operator: 'or',
                             limit: @limit, highlight: {tag: '<mark>'},
                             misspellings: {below: 1}, execute: false
    end

    def hospital_search query
      return [] if query.blank? || query.length < 3
      hospitals = Hospital.search query, where: {year: @system.base_year},
                                  fields: ['name^2', :street, :address],
                                  match: :word_middle,
                                  limit: @limit, highlight: {tag: '<mark>'},
                                  misspellings: false
      if query.length > 5 and hospitals.empty?
        hospitals = Hospital.search query, where: {year: @system.base_year},
                                    fields: ['name^2', :street, :address],
                                    operator: 'or',
                                    limit: @limit, highlight: {tag: '<mark>'}, misspellings: {below: 1}
      end
      return hospitals
    end
end
