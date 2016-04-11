require 'fileutils'
require 'csv'

namespace :db do
  desc "Seed a DRG system. You have to provide a folder containing adrgs.csv, drgs.csv, mdcs.csv and system.json"
  task :seed_drg_version, [:folder] => :environment do |t, args|
     # TODO
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
    Rake::Task['db:seed_drg_version'].invoke('data/catalogues/V1.0/')
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke('data/catalogues/V2.0/')
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke('data/catalogues/V3.0/')
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke('data/catalogues/V4.0/')
    Rake::Task['db:seed_drg_version'].reenable
    Rake::Task['db:seed_drg_version'].invoke('data/catalogues/V5.0/')
  end
end