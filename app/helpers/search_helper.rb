module SearchHelper
  def highlight_text(text, details, field)
    return text if details.nil?
    return text if details[:highlight].nil?
    highlighted_text = details[:highlight][field]
    return text if highlighted_text.nil?
    to_replace = highlighted_text.gsub('<mark>', '').gsub('</mark>', '')

    return text.gsub(to_replace, highlighted_text)
  end

  def highlight_code(text, detail, locale)
    return highlight_text(text, detail, ('text_' + locale.to_s).to_sym)
  end
end