require 'event_sourcery'
require 'event_sourcery/postgres'
require 'securerandom'
require 'sinatra'

require_relative '../app/events/node_added.rb'
require_relative '../app/commands/node/add.rb'
require_relative '../app/aggregates/node.rb'
require_relative '../app/projections/proposed_nodes.rb'
require_relative '../app/projections/query.rb'

# Monkey patch
class Hash
  def slice(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key, true)
    keys.each_with_object(self.class.new) do |k, hash|
      hash[k] = self[k] if key?(k)
    end
  end
end

UnprocessableEntity = Class.new(StandardError)
BadRequest = Class.new(StandardError)

set :public_folder, 'public'
# Ensure our error handlers are triggered in development
set :show_exceptions, :after_handler

configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

error UnprocessableEntity do |error|
  body "Unprocessable Entity: #{error.message}"
  status 422
end

error BadRequest do |error|
  body "Bad Request: #{error.message}"
  status 400
end

def json_params
  # Coerce this into a symbolised Hash so Sintra data structures
  # don't leak into the command layer.
  Hash[
    params.merge(
      JSON.parse(request.body.read)
    ).map { |k, v| [k.to_sym, v] }
  ]
end

post '/nodes/:node_id' do
  command = HiveMap::Commands::Node::Add::Command.build(json_params)
  HiveMap::Commands::Node::Add::CommandHandler.new.handle(command)
  status 201
end

get '/nodes/proposed' do
  body JSON.pretty_generate(
    HiveMap::Projections::Proposed::Query.handle
  )
  status 200
end

## Core namespace for the app
module HiveMap
  ## Holds the configuration, singleton with a class variable.
  class Config
    attr_accessor :database_url
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config
  end

  def self.environment
    ENV.fetch('RACK_ENV', 'development')
  end

  def self.event_store
    EventSourcery::Postgres.config.event_store
  end

  def self.event_source
    EventSourcery::Postgres.config.event_store
  end

  def self.tracker
    EventSourcery::Postgres.config.event_tracker
  end

  def self.event_sink
    EventSourcery::Postgres.config.event_sink
  end

  def self.projections_database
    EventSourcery::Postgres.config.projections_database
  end

  def self.repository
    @repository ||= EventSourcery::Repository.new(
      event_source: event_source,
      event_sink: event_sink
    )
  end
end

require_relative '../config/environment.rb'
