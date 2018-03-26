require 'minitest/autorun'
require 'database_cleaner'

require 'hive_map'

require 'awesome_print'
require 'ostruct'

ENV['RACK_ENV'] = 'test'

require_relative 'support/request_helpers.rb'

module EventHelpers
  def last_event(aggregate_id)
    HiveMap.event_store.get_events_for_aggregate_id(aggregate_id).last
  end
end

module Minitest
  class Spec
    include RequestHelpers
    include EventHelpers

    before do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end
  end
end
