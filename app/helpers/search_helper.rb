module SearchHelper
  # JSON API for search
  # parameters:
  # term: search term
  # limit: maximum number of items
  # locale: language for search term and results
  # as_hash: if set deliver codes in a hash including the id, the localized text and the code
  def search_and_render model
    res = []
    query = params[:term].blank? ? '' : params[:term]
    limit = params[:limit].blank? ? 5 : params[:limit].to_i
    locale =  check_locale(params[:locale])

    codes = model.where({ '$or' => [{'code' => /#{Regexp.escape(query)}/i }, {'text_' + locale => /#{Regexp.escape(query)}/i}]})
        .order_by([[ :code, :asc ]]).limit(limit)
    codes.each do |code|
      res << "#{code.code} #{code.text(locale)}" if params[:as_hash].blank?
      res << {:id => code.id.to_s, :code => code.code, :text => code.text(locale)} if !params[:as_hash].blank?
    end

    render :json => res
  end

  def check_locale locale
    if(locale != 'fr' && locale != 'it')
      locale = 'de'
    end
    return locale
  end
end