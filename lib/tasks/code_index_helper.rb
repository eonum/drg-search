

def read_code_index index_file_name
  index = {}
  index_file = File.new(index_file_name, 'r')
  current_code = nil

  # skip first 3 lines
  (1..3).each {|d| index_file.gets}

  while line = index_file.gets
    elements = line.split("\t")
    current_code = elements[0] unless elements[0].blank?
    (1..elements.length - 1).each do |i|
      drg_code = elements[i]
      index[drg_code] = [] if index[drg_code].nil?
      index[drg_code] << current_code
    end
  end
end