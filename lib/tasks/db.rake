require 'fileutils'
require 'csv'
require 'json'

namespace :db do
  desc "Seed a DRG system. You have to provide a folder containing adrgs.csv, drgs.csv, mdcs.csv and system.json"
  task :seed_drg_version, [:directory] => :environment do |t, args|
    puts "Seeding DRG version from folder #{args.directory}"
    system_file = File.read(File.join(args.directory, 'system.json'))
    system_hash = JSON.parse(system_file)
    system = System.new(system_hash)
    system.save!

    puts 'Loading MDCs..'
    CSV.foreach(File.join(args.directory, 'mdcs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of MDC #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version
      mdc = Mdc.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4], prefix: row[5]})
      Partition.create!({code: 'O', version: system.version, mdc_id: mdc.id})
      Partition.create!({code: 'M', version: system.version, mdc_id: mdc.id})
      Partition.create!({code: 'A', version: system.version, mdc_id: mdc.id})
    end

    puts 'Loading ADRGs..'
    CSV.foreach(File.join(args.directory, 'adrgs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of ADRG #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version
      Adrg.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4]})
    end

    puts 'Loading DRGs..'
    CSV.foreach(File.join(args.directory, 'drgs.csv'), col_sep: ';') do |row|
      next if row[0] == 'code' # skip header if any
      version = row[1]
      puts "Warning: version of DRG #{row[0]} is not identical with version of system: #{version} vs. #{system.version}" if system.version != version
      Drg.create!({code: row[0], version: row[1], text_de: row[2], text_fr: row[3], text_it: row[4], partition_letter: row[5]})
    end

    puts 'Link codes..'
    # load ID caches
    mdc_ids = {}
    adrg_ids = {}
    partition_ids = {}
    ActiveRecord::Base.transaction do
      Mdc.where(:version => system.version).all.each do |mdc|
        mdc_ids[mdc.prefix] = mdc.id
        mdc.partitions.each {|partition| partition_ids[mdc.prefix + partition.code] = partition.id}
      end
    end
    ActiveRecord::Base.transaction do
      Adrg.where(:version => system.version).all.each {|adrg| adrg_ids[adrg.code] = adrg.id}
    end

    ActiveRecord::Base.transaction do
      Drg.where(:version => system.version).all.each do |drg|
        drg.mdc_id = mdc_ids[drg.code[0..0]]
        drg.adrg_id = adrg_ids[drg.code[0..2]]
        drg.partition_id = partition_ids[drg.code[0..0] + drg.partition_letter]
        drg.save!
      end
    end

    ActiveRecord::Base.transaction do
      Adrg.where(:version => system.version).all.each do |adrg|
        adrg.mdc_id = mdc_ids[adrg.code[0..0]]
        if adrg.drgs.empty?
          puts "Warning: No DRG found for ADRG #{adrg.code}"
        else
          adrg.partition_id = partition_ids[adrg.code[0..0] + adrg.drgs[0].partition_letter]
        end
        adrg.save!
      end
    end
  end

  desc 'Seed all data in a certain directory. This includes hospital data and number of cases data.'
  task :seed_numcase_data, [:directory] => :environment do |t, args|
    Dir.entries(args.directory).sort.each do |file|
      puts "Seed data in #{file}"
      CSV.foreach(file, col_sep: ';') do |row|
        # TODO
      end
    end
  end

  desc "Truncate all tables (empties all tables exept from schema_migrations and resets pk sequence)."
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

  desc 'Empties all tables and executes all tasks to setup the database.'
  task :reseed, [:directory] => :environment do |t, args|
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V1.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V2.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V3.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V4.0/'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke(File.join(args.directory, 'catalogues/V5.0/'))

    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2012'))
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_numcase_data'].invoke(File.join(args.directory, '2013'))
  end
end