# A hospital is a representation of a hospital in one year.
# Hence a unique hospital can have multiple hospital objects. One for each year.
class Hospital < ActiveRecord::Base
  has_many :num_cases

  searchkick word_middle: [:name, :address], language: 'german', callbacks: false,
             synonyms: [['freiburg', 'fribourg'], ['centre hospitalier', 'spitalzentrum'], ['biel', 'bienne'], ['neuenburg', 'neuchâtel', 'neuchatel'],
             ['hôpital de l\'ile', 'inselspital', 'ile'], ['genf', 'geneve', 'genève'], ['bern', 'berne', 'berna'], ['geburtshaus', 'maison de naissance'],
             ['fmi', 'frutigen meiringen interlaken'], ['sro',	'spital region oberaargau'], ['hôpital du jura bernois', 'st imier'],
             ['spital thurgau ag kantonsspitäler frauenfeld & münsterlingen', 'stgag'], ['clinique le noirmont', 'rocmontès'],
             ['spital thurgau ag klinik st. katharinental', 'spital thurgau ag psychiatrische klinik münsterlingen', 'stgag'],
             ['spital thun simmental saanenland ag', 'sts', 'sts ag'], ['sozialpädagogische psychiatrische modellstation für schwere adoleszentenstörungen', 'modellstation somosa'],
             ['gesundheitsversorgung zürcher oberland', 'gzo'], ['hôpital de porrentruy', 'hôpital du jura'], ['spitalverbund appenzell ausserrhoden', 'spitalverbund ar', 'svar'],
             ['riviera', 'clinique cic'], ['swiss medical network', 'gsmn neuchâtel sa']]
  # hospital_id is only unique within one year
  # id is unique over all hospital objects
end
