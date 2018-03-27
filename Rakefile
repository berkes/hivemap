$LOAD_PATH.unshift '.'

task :environment do
  require 'lib/hive_map'
  require 'awesome_print'
end

desc 'Setup Event Stream Processors'
task setup_processors: :environment do
  HiveMap::Projections::ProposedNodes::Projector.new.setup
end

desc 'Run Event Stream Processors'
task run_processors: :environment do
  # Need to disconnect before starting the processors so
  # that the forked processes have their own connection / fork safety.
  HiveMap.projections_database.disconnect

  esps = [
    HiveMap::Projections::ProposedNodes::Projector.new
  ]

  # The ESPRunner will fork child processes for each of the ESPs passed to it.
  EventSourcery::EventProcessing::ESPRunner.new(
    event_processors: esps,
    event_source: HiveMap.event_source,
  ).start!
end

desc 'Run webserver'
task run_web: :environment do
  sh %(bundle exec rackup)
end

namespace :db do
  desc 'Create database'
  task create: :environment do
    url = HiveMap.config.database_url
    database_name = File.basename(url)
    database = Sequel.connect URI.join(url, '/template1').to_s
    database.run("CREATE DATABASE #{database_name}")
    database.disconnect
  end

  desc 'Drop database'
  task drop: :environment do
    url = HiveMap.config.database_url
    database_name = File.basename(url)
    database = Sequel.connect URI.join(url, '/template1').to_s
    database.run("DROP DATABASE IF EXISTS #{database_name}")
    database.disconnect
  end

  desc 'Migrate database'
  task migrate: :environment do
    database = EventSourcery::Postgres.config.event_store_database
    EventSourcery::Postgres::Schema.create_event_store(db: database)
  end
end
