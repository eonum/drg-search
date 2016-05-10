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
      hname = ''
      words = h.name.split(' ')
      words.each_with_index do |word, i|
        hname += word + ' ' if i % 2 == 0
        hname += word + "\r\n" if i % 2 == 1
      end
      data << [hname] + codes.map {|code| numcase_number ncs[code.code] }
    end
    data
  end

  def time_series_data(codes, hospitals, num_cases)
    num_data_points = codes.size * hospitals.size
    identifiers = []
    @hospitals.each do |h|
       identifiers += @codes.map{|code| code.code_display + ' - ' + h.name }
    end
    data = []
    data << [I18n.t('year')] + identifiers
    @system.years.each do |year|
      row = [year]
      @hospitals.each do |h|
        row += @codes.map{|code| Random.rand() }
      end
      data << row
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
