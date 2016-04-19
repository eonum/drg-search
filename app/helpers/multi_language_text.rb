module MultiLanguageText
  def text locale
    return localized_field 'text', locale
  end

  def localized_field field, locale
    if(locale.to_s == 'fr')
      return self[field + '_fr']
    end
    if(locale.to_s == 'it')
      return self[field + '_it']
    end
    return self[field + '_de']
  end
end
