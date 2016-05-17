class Partition < ActiveRecord::Base
  belongs_to :mdc

  has_many :adrgs
  has_many :drgs

  def partition_letter
    return self.code.split(' ')[1]
  end

  def code_display
    return I18n.t('partition') + ' ' + I18n.t('partition_' + self.partition_letter)
  end

  def text locale
    return ''
  end

  def generalize
    return self.mdc
  end

  def specialize
    return self.adrgs.order(code: :asc)
  end
end
