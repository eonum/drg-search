
def add_code(drg_code, index, code)
  drg_code = 'Pre' if drg_code == 'Prä'
  index[drg_code] = [] if index[drg_code].nil?
  index[drg_code] << code unless index[drg_code].include? code
end

# Read a map that maps from DRG|MDC|ADRG code to all its relevant
# ICD or CHOP codes within the grouping process.
def read_code_index index_file_name
  index = {}
  index_file = File.new(index_file_name, 'r')
  current_code = nil

  # skip first 3 lines
  (1..3).each {|d| index_file.gets}

  while line = index_file.gets
    elements = line.split("\t")
    current_code = elements[0].gsub(/[^0-9A-Z]/, '') unless elements[0].blank?
    # MDC
    add_code(elements[1], index, current_code)
    next if elements.length < 3

    elements[2].split(', ').each do |drg|
      # DRG
      add_code(drg, index, current_code)
      # ADRG
      add_code(drg[0..2], index, current_code)
    end
  end

  return index
end

# Combine ICD and CHOP indices and the description texts
def combine_indices(icds, chops, relevant_diagnoses_by_code, relevant_procedures_by_code)
  texts = {}

  relevant_diagnoses_by_code.each do |code, relevant_codes|
    text_de = ''
    text_fr = ''
    text_it = ''

    relevant_codes.each do |relevant_code|
      text_de += icds[relevant_code][:text_de] + "\n" unless icds[relevant_code].nil?
      text_fr += icds[relevant_code][:text_fr] + "\n" unless icds[relevant_code].nil?
      text_it += icds[relevant_code][:text_it] + "\n" unless icds[relevant_code].nil?
    end

    texts[code] = {text_de: text_de, text_fr: text_fr, text_it: text_it}
  end

  relevant_procedures_by_code.each do |code, relevant_codes|
    text_de = texts[code].nil? ? '' : texts[code][:text_de]
    text_fr = texts[code].nil? ? '' : texts[code][:text_fr]
    text_it = texts[code].nil? ? '' : texts[code][:text_it]

    relevant_codes.each do |relevant_code|
      text_de += chops[relevant_code][:text_de] + "\n" unless chops[relevant_code].nil?
      text_fr += chops[relevant_code][:text_fr] + "\n" unless chops[relevant_code].nil?
      text_it += chops[relevant_code][:text_it] + "\n" unless chops[relevant_code].nil?
    end

    texts[code] = {text_de: text_de, text_fr: text_fr, text_it: text_it}
  end

  return texts
end