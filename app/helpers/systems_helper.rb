module SystemsHelper
  # data description text for a system
  def data_from system
    additional_years = system.years - [system.base_year]
    additional_data = ''
    additional_data = I18n.t('additional_data_singular') + ' ' + additional_years[0].to_s if additional_years.length == 1
    additional_data = I18n.t('additional_data_plural') + ' ' + additional_years.join(', ') if additional_years.length > 1
    application = I18n.t('application_year') + system.application_year.to_s + ' (' + system.text(locale) + '). '
    return application + I18n.t('data_from') + ' ' + system.base_year.to_s + ' ' + additional_data
  end

  # prepare data for the bar chart
  def chart_data(codes, hospitals, num_cases)
    data = []
    identifiers = [I18n.t('hospitals')] + codes.map{|code| code.code_display_long }
    hospitals.each do |h|
      ncs = num_cases[h.hospital_id]
      a = [h.name]
      codes.each {|code|  a << numcase_number(ncs[code.code]); a << numcase_display(ncs[code.code]) }
      data << a
    end
    [identifiers, data]
  end

  # prepare data for the time series line chart
  def time_series_data(codes, hospitals, num_cases)
    temp_num_cases = NumCase.where(version: @system.version, hospital_id: @hop_ids, code: codes.map {|c| c.code })
    num_cases = {}
    @hop_ids.each do |hop_id|
      num_cases[hop_id] = {}
    end
    temp_num_cases.each do |nc|
      num_cases[nc.hospital_id][nc.code] = {} if num_cases[nc.hospital_id][nc.code].nil?
      num_cases[nc.hospital_id][nc.code][nc.year] = nc
    end

    identifiers = [I18n.t('year')]
    hospitals.each do |h|
       identifiers += @codes.map{|code| code.code_display + ' - ' + h.name }
    end
    data = []
    @system.years.each do |year|
      row = [year.to_s]
      hospitals.each do |h|
        row += @codes.map{|code| num_cases[h.hospital_id][code.code].nil? ? Float::NAN : numcase_number(num_cases[h.hospital_id][code.code][year]) }
      end
      data << row
    end
    [identifiers, data, hospitals.length, @codes.length]
  end

  # get the number from a NumCase
  # anonymize if lower than 5
  def numcase_number numcase
    return 0 if numcase.nil?
    #return 0 if numcase.n < 5
    return numcase.n
  end

  # format the number. handle NaN and anonymized numbers
  def numcase_display numcase
    number = numcase_number numcase
    return '0' if number == 0
    return '< 5' if number.to_f.nan?
    return '< 5' if number < 5
    return number.to_s
  end
end
