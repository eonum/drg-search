require 'fileutils'
require 'csv'
require 'json'
require_relative 'code_index_helper'

namespace :db do
  desc "Seed a DRG system. You have to provide a folder containing adrgs.csv, drgs.csv, mdcs.csv and system.json"
  task :seed_drg_version, [:directory] => :environment do |t, args|
    puts "Seeding DRG version from folder #{args.directory}"
    system_file = File.read(File.join(args.directory, 'system.json'))
    system_hash = JSON.parse(system_file)
    system = System.new(system_hash)
    system.save!

    puts 'Loading and linking diagnoses index..'
    icds = {}
    CSV.foreach(File.join(args.directory, 'icds.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      icds[row[0].gsub('.', '')] = { text_de: row[2], text_fr: row[3], text_it: row[4]}
    end
    relevant_diagnoses_by_code = read_code_index(File.join(args.directory, 'Index/DgIndex.txt'))

    puts 'Loading and linking procedures index..'
    chops = {}
    CSV.foreach(File.join(args.directory, 'chops.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      chops[row[0].gsub('.', '')] = { text_de: row[2], text_fr: row[3], text_it: row[4]}
    end
    relevant_procedures_by_code = read_code_index(File.join(args.directory, 'Index/PrIndex.txt'))
    relevant_codes_texts = combine_indices(icds, chops, relevant_diagnoses_by_code, relevant_procedures_by_code)

    puts 'Loading MDCs..'
    Mdc.create!({code: 'ALL', version: system.version, text_de: 'Alle Fälle', text_fr: 'Tous les cas', text_it: 'Tutti i casi', prefix: '0'})
    CSV.foreach(File.join(args.directory, 'mdcs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of MDC #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version
      rcodes = relevant_codes_texts[row[0]]
      mdc = Mdc.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4], prefix: row[5],
                         relevant_codes_de: '',
                         relevant_codes_fr: '',
                         relevant_codes_it: ''})
      Partition.create!({code: "#{row[5]} O", version: system.version, mdc_id: mdc.id})
      Partition.create!({code: "#{row[5]} M", version: system.version, mdc_id: mdc.id})
      Partition.create!({code: "#{row[5]} A", version: system.version, mdc_id: mdc.id})
    end

    puts 'Loading ADRGs..'
    CSV.foreach(File.join(args.directory, 'adrgs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of ADRG #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version

      rcodes = relevant_codes_texts[row[0]]
      Adrg.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4],
                    relevant_codes_de: rcodes.nil? ? '' : rcodes[:text_de],
                    relevant_codes_fr: rcodes.nil? ? '' : rcodes[:text_fr],
                    relevant_codes_it: rcodes.nil? ? '' : rcodes[:text_it]})
    end

    puts 'Loading DRGs..'
    CSV.foreach(File.join(args.directory, 'drgs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of DRG #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version
      partition_letter = row[5]
      partition_letter = 'O' if partition_letter == 'X'

      rcodes = relevant_codes_texts[row[0]]
      Drg.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4], partition_letter: partition_letter,
                   relevant_codes_de: rcodes.nil? ? '' : rcodes[:text_de],
                   relevant_codes_fr: rcodes.nil? ? '' : rcodes[:text_fr],
                   relevant_codes_it: rcodes.nil? ? '' : rcodes[:text_it]})
    end

    puts 'Link codes..'
    # load ID caches
    mdc_ids = {}
    adrg_ids = {}
    partition_ids = {}
    ActiveRecord::Base.transaction do
      Mdc.where(:version => system.version).all.each do |mdc|
        mdc_ids[mdc.prefix] = mdc.id
        mdc.partitions.each {|partition| partition_ids[partition.code] = partition.id}
      end
    end
    ActiveRecord::Base.transaction do
      Adrg.where(:version => system.version).all.each {|adrg| adrg_ids[adrg.code] = adrg.id}
    end

    ActiveRecord::Base.transaction do
      Drg.where(:version => system.version).all.each do |drg|
        drg.mdc_id = mdc_ids[drg.code[0..0]]
        drg.adrg_id = adrg_ids[drg.code[0..2]]
        drg.partition_id = partition_ids[drg.code[0..0] + ' ' + drg.partition_letter]
        drg.save!
      end
    end

    ActiveRecord::Base.transaction do
      Adrg.where(:version => system.version).all.each do |adrg|
        adrg.mdc_id = mdc_ids[adrg.code[0..0]]
        if adrg.drgs.empty?
          puts "Warning: No DRG found for ADRG #{adrg.code}"
        else
          adrg.partition_id = partition_ids[adrg.code[0..0] + ' ' + adrg.drgs[0].partition_letter]
        end
        adrg.save!
      end
    end

    puts 'Reindex search index..'
    Mdc.reindex
    Adrg.reindex
    Drg.reindex
  end

  desc 'Seed all data in a certain directory from a certain year. This includes hospital data and number of cases data.
      All files must be encoded using UTF-8. All rows in one  numcase file must have identical version, year and level.'
  task :seed_numcase_data, [:directory, :year] => :environment do |t, args|
    puts "Seed folder #{args.directory}"

    # create pseudo hospital ALL
    Hospital.create!({year: args.year.to_i, hospital_id: 9999, name: 'Alle stationären Spitäler der Schweiz/ Tous les hôpitaux stationnaires suisses / Tutti gli ospedali stazionari svizzeri', street: '', address: '', canton: 'CH'})

    Dir.entries(args.directory).sort.each do |file|
      next unless file.downcase.end_with?('csv.utf8')

      file_name = File.join(args.directory, file)
      count = `wc -l "#{file_name}"`.to_i  +  1
      pg = ProgressBar.create(total: count, title: "Importing #{file_name}..")

      is_hospital_table = file.include? 'hosp_table'
      csv_contents = CSV.read(file_name, col_sep: ';')
      # skip header
      csv_contents.shift
      version = csv_contents[0][2]
      year = csv_contents[0][1].to_i
      level = csv_contents[0][3]

      partitions_by_drg = {}
      adrgs_by_drg = {}
      ActiveRecord::Base.transaction do
        Drg.where(:version => version).all.each do |drg|
          if not drg.partition.nil?
            partitions_by_drg[drg.code] = drg.partition.code
          else
            puts "Warning: Could not find a partition in DRG #{drg.code}"
          end

          if not drg.adrg.nil?
            adrgs_by_drg[drg.code] = drg.adrg.code
          else
            puts "Warning: Could not find a ADRG in DRG #{drg.code}"
          end
        end
      end

      numcases_by_partition_and_hospital = {}
      numcases_by_adrg_and_hospital = {}
      numcases_by_hospital = {}

      ActiveRecord::Base.transaction do
        csv_contents.each do |row|
          pg.increment
          if is_hospital_table
            Hospital.create!({year: row[0].to_i, hospital_id: row[1].to_i, name: row[2], street: row[3], address: row[4], canton: row[4]})
          else
            if version != row[2] || year != row[1].to_i || level != row[3]
              puts "Warning row #{row} has not the same version, year or level as other rows in this file!"
              puts "version: #{version}, level: #{level}, year: #{year}"
            end
            numcase = NumCase.create!({hospital_id: row[0].to_i, year: row[1].to_i, version: row[2], level: row[3], code: row[4], n: row[5].to_i})

            if level == 'DRG'
              # Calculate aggregations for ADRGs and Partitions

              partition = partitions_by_drg[numcase.code]
              adrg = adrgs_by_drg[numcase.code]
              if numcases_by_partition_and_hospital[partition].nil?
                numcases_by_partition_and_hospital[partition] = {}
              end
              if numcases_by_partition_and_hospital[partition][numcase.hospital_id].nil?
                numcases_by_partition_and_hospital[partition][numcase.hospital_id] = 0
              end
              numcases_by_partition_and_hospital[partition][numcase.hospital_id] += numcase.n

              if numcases_by_adrg_and_hospital[adrg].nil?
                numcases_by_adrg_and_hospital[adrg] = {}
              end
              if numcases_by_adrg_and_hospital[adrg][numcase.hospital_id].nil?
                numcases_by_adrg_and_hospital[adrg][numcase.hospital_id] = 0
              end
              numcases_by_adrg_and_hospital[adrg][numcase.hospital_id] += numcase.n
            end

            if level == 'MDC'
               numcases_by_hospital[numcase.hospital_id] = 0 if numcases_by_hospital[numcase.hospital_id].nil?
               numcases_by_hospital[numcase.hospital_id] += numcase.n
            end
          end
        end
      end
      pg.finish

      next if level != 'DRG' && level != 'MDC'

      puts 'Store aggregations for ADRGs and Partitions..'
      ActiveRecord::Base.transaction do
        numcases_by_partition_and_hospital.each do |partition, hospitals|
          hospitals.each do |hospital_id, n|
            NumCase.create!({hospital_id: hospital_id, year: year, version: version, level: 'PARTITION', code: partition, n: n})
          end
        end

        # store ALL MDC
        numcases_by_hospital.each do |hospital_id, n|
          NumCase.create!({hospital_id: hospital_id, year: year, version: version, level: 'MDC', code: 'ALL', n: n})
        end
      end

      ActiveRecord::Base.transaction do
        numcases_by_adrg_and_hospital.each do |adrg, hospitals|
          hospitals.each do |hospital, n|
            NumCase.create!({hospital_id: hospital, year: year, version: version, level: 'ADRG', code: adrg, n: n})
          end
        end
      end
    end

    # aggregate all num cases for pseudo hospital ALL

    NumCase.where(year: args.year).group("version").group("level").group("code").sum(:n).each do |key, n|
      NumCase.create!({hospital_id: 9999, year: args.year, version: key[0], level: key[1], code: key[2], n: n})
    end

    Hospital.reindex
  end

  desc 'Truncate all tables (empties all tables exept from schema_migrations and resets pk sequence).'
  task :truncate => :environment do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      postgres = "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname='public'"
      tables = conn.execute(postgres).map { |r| r['tablename'] }
      tables.delete "schema_migrations"
      tables.each do |t|
        puts "Truncating #{t}"
        conn.execute("TRUNCATE \"#{t}\" CASCADE")
        conn.reset_pk_sequence!(t)
      end
    end
  end

  desc 'Store the code_display property of all MDCs in the database. Hence we can search for MDCs'
  task :save_code_display => :environment do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      Mdc.all.each do |mdc|
        mdc.code_search = mdc.code_display + ' ' + mdc.code.gsub('0', '')
        mdc.save!
      end
    end
  end

  desc 'Link codes to num_cases directly.'
  task :link_codes_to_num_cases => :environment do
    pg = ProgressBar.create(total: NumCase.count, title: "Linking codes to num_cases..")
    codes = {}
    ['MDC', 'PARTITION', 'ADRG', 'DRG'].each do |level|
      codes[level] = {}
      code_class = {'MDC': Mdc, 'PARTITION': Partition, 'ADRG': Adrg, 'DRG': Drg}[level.to_sym]
      code_class.all.each do |code|
        codes[level][code.code + '--' + code.version] = code
      end
    end

    NumCase.find_each do |nc|
      pg.increment
      nc.code_object = codes[nc.level][nc.code + '--' + nc.version] unless nc.level.nil? || nc.code.nil? || nc.version.nil?
      nc.save!
    end
    pg.finish
  end

  desc 'Empties all tables and executes all tasks to setup the database.'
  task :reseed, [:directory] => :environment do |t, args|
    Rake::Task['db:truncate'].invoke()
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V1.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V2.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V3.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V4.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V5.0/'))

    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2012'), '2012')
    Rake::Task['db:seed_numcase_data'].reenable
    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2013'), '2013')
    Rake::Task['db:seed_numcase_data'].reenable
    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2014'), '2014')
    Rake::Task['db:seed_numcase_data'].reenable
    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2015'), '2015')
    Rake::Task['db:save_code_display'] .invoke()
    Rake::Task['db:link_codes_to_num_cases'].invoke()
  end
end
