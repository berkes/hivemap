HiveMap.configure do |config|
  default = "postgres://postgres@127.0.0.1:5432/hive_map_#{HiveMap.environment}"
  config.database_url = ENV['DATABASE_URL'] || default
end

EventSourcery::Postgres.configure do |config|
  database = Sequel.connect(HiveMap.config.database_url)

  # NOTE: Often we choose to split our events and projections into separate
  # databases. For the purposes of this example we'll use one.
  config.event_store_database = database
  config.projections_database = database
end
