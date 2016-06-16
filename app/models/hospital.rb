# A hospital is a representation of a hospital in one year.
# Hence a unique hospital can have multiple hospital objects. One for each year.
class Hospital < ActiveRecord::Base
  has_many :num_cases

  searchkick word_middle: [:name, :address], language: 'german', callbacks: false,
             synonyms: [['freiburg', 'fribourg'], ['centre hospitalier', 'spitalzentrum'], ['Biel', 'Bienne'], ['neuenburg', 'Neuchâtel', 'Neuchatel'],
             ['Hôpital de l’île', 'Inselspital'], ['Genf', 'Geneve', 'Genève'], ['Bern', 'Berne', 'Berna'], ['Geburtshaus', 'Maison de naissance']]
  # hospital_id is only unique within one year
  # id is unique over all hospital objects
end
