require 'minitest/autorun'
require 'database_cleaner'

require 'hive_map'

require 'awesome_print'
require 'ostruct'

ENV['RACK_ENV'] = 'test'

## Include all support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |file| require file }

module Minitest
  class Spec
    include RequestHelpers
    include EventHelpers
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
