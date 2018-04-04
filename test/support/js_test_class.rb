module Minitest
  class JsTest < Minitest::Spec
    include Capybara::DSL
    include Capybara::Minitest::Assertions

    Capybara.app = Sinatra::Application
    Capybara.javascript_driver = :poltergeist

    def teardown
      super
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
end
