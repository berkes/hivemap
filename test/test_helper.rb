require 'minitest/autorun'
require 'capybara/minitest'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'byebug'

require 'hive_map'

require 'awesome_print'
require 'ostruct'

ENV['RACK_ENV'] = 'test'
Sinatra::Application.environment = :test

## Include all support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |file| require file }

module Minitest
  class Spec
    include EventHelpers
    include FileHelpers
    include RequestHelpers
    include TimeHelpers

    EventSourcery.configure do |config|
      config.logger = Logger.new(nil)
    end

    before do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end
  end
end
