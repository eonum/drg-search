module SystemsHelper
  def data_from system
    return I18n.t('data_from') + ' ' + system.years.join(', ')
  end
end
