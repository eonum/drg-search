# A hospital is a representation of a hospital in one year.
# Hence a unique hospital can have multiple hospital objects. One for each year.
class Hospital < ActiveRecord::Base
  has_many :num_cases

  searchkick word_middle: [:name, :address], language: 'german', callbacks: false,
             synonyms: [['freiburg', 'fribourg'], ['centre hospitalier', 'spitalzentrum'], ['biel', 'bienne'], ['neuenburg', 'neuchâtel', 'neuchatel'],
             ['hôpital de l\'ile', 'inselspital', 'ile'], ['genf', 'geneve', 'genève'], ['bern', 'berne', 'berna'], ['geburtshaus', 'maison de naissance']]
  # hospital_id is only unique within one year
  # id is unique over all hospital objects
end
