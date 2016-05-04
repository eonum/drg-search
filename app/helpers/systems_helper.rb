module SystemsHelper
  def data_from system
    additional_years = system.years - [system.base_year]
    additional_data = ''
    additional_data = I18n.t('additional_data_singular') + ' ' + additional_years[0].to_s if additional_years.length == 1
    additional_data = I18n.t('additional_data_plural') + ' ' + additional_years.join(', ') if additional_years.length > 1
    application = I18n.t('application_year') + system.application_year.to_s + ' (' + system.text(locale) + '). '
    return application + I18n.t('data_from') + ' ' + system.base_year.to_s + ' ' + additional_data
  end


  def chart_data(codes, hospitals, num_cases)
    num_data_points = codes.size * hospitals.size
    data = []
    data << [I18n.t('hospitals')] + @codes.map{|code| code.code_display + (num_data_points > 6 ? '' : ' ' + code.text(locale))}
    hospitals.each do |h|
      ncs = num_cases[h.hospital_id]
      data << [h.name] + codes.map {|code| numcase_number ncs[code.code] }
    end
    data
  end

  def numcase_number numcase
    return 0 if numcase.nil?
    return 0 if numcase.n < 5
    return numcase.n
  end

  def numcase_display numcase
    number = numcase_number numcase
    return '< 5' if number < 5
    return number.to_s
  end
end
