module SystemsHelper
  def data_from system
    additional_years = system.years - [system.base_year]
    additional_data = ''
    additional_data = I18n.t('additional_data_singular') + ' ' + additional_years[0].to_s if additional_years.length == 1
    additional_data = I18n.t('additional_data_plural') + ' ' + additional_years.join(', ') if additional_years.length > 1
    return I18n.t('data_from') + ' ' + system.base_year.to_s + ' ' + additional_data
  end


  def chart_data(codes, hospitals, num_cases)
    data = []
    data << [I18n.t('hospitals')] + @codes.map{|code| code.code_display}
    hospitals.each do |h|
      ncs = num_cases[h.hospital_id]
      data << [h.name] + codes.map {|code| ncs[code.code] == nil ? 0 : ncs[code.code].n }
    end
    data
  end
end
