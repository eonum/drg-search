require 'csv'

class Adrg < ActiveRecord::Base
  belongs_to :mdc
  belongs_to :partition
  has_many :drgs

  include MultiLanguageText

  searchkick word_middle: [:text_de, :text_fr, :text_it],
             callbacks: false, language: 'german', batch_size: 200
             #synonyms: -> { CSV.read('data/mesh_2016/synonyms.csv', {col_sep: ';'}) }

  def code_display
    return code
  end

  def code_display_long
    return I18n.t('adrg') + ' ' + code
  end

  def generalize
    return self.partition
  end

  def specialize
    return self.drgs.order(code: :asc)
  end
end
