module SearchHelper
  def highlight_text(text, details, field)
    return text if details.nil?
    return text if details[:highlight].nil?
    highlighted_text = details[:highlight][field]
    return text if highlighted_text.nil?
    to_replace = highlighted_text.gsub('<mark>', '').gsub('</mark>', '')

    return text.gsub(to_replace, highlighted_text)
  end

  def highlight_hospital(text, details, field)
    highlighted_text = highlight_text(text, details, field)
    highlighted_text.gsub!(@query_hospital.strip, "<mark>#{@query_hospital.strip}</mark>") unless highlighted_text.include? '<mark>'
    return highlighted_text
  end

  def highlight_code(text, detail, locale)
    text_field = ('text_' + locale.to_s + '.word_middle').to_sym
    return highlight_text(text, detail, text_field) unless detail.nil? || detail[:highlight].nil? || detail[:highlight][text_field].nil? || !detail[:highlight][text_field].include?('<mark>')

    # let's try to highlight a relevant code
    simple_highlight = text.gsub(@query_codes.strip, "<mark>#{@query_codes.strip}</mark>") unless text.include? '<mark>'
    return simple_highlight if detail.nil?
    return simple_highlight if detail[:highlight].nil?
    highlighted_text = detail[:highlight][('relevant_codes_' + locale.to_s).to_sym]
    return simple_highlight if highlighted_text.nil?
    relevant_codes = highlighted_text.split("\n")
    first = ''
    i = 0
    while first.blank? && relevant_codes.length > i
      first = relevant_codes[i] if relevant_codes[i].include? '<mark>'
      i += 1
    end
    return simple_highlight if first.blank?
    first += '</mark>' unless first.include? '</mark>'
    return text + '<div class="small">(' + I18n.t('relevant_code') + ': ' + first + ')</div>'
  end
end