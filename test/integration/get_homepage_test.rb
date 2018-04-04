require 'test_helper'

class GetHomepageTest < Minitest::JsTest
  before do
    setup_projectors
  end

  it 'gets an HTML response' do
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response.content_type
  end

  it 'shows the features in the sidebar' do
    skip('fix timing issues')
    add_and_process_hive
    Capybara.current_driver = Capybara.javascript_driver
    visit '/'

    page.assert_text('visit me at home')
  end

  it 'highlights the features under the click' do
    skip('fix timing issues')
    add_and_process_hive(contact_details: 'one')

    Capybara.current_driver = Capybara.javascript_driver
    visit '/'

    page.assert_text('one') # ensure it is all loaded
    page.driver.click(575, 408)

    page.find('.highlighted').assert_text('one')
  end

  private

  def add_and_process_hive(node_id: SecureRandom.uuid,
                           lat: 51.84, lon: 5.86,
                           author_email: 'harry@example.com',
                           contact_details: 'visit me at home')
    post_json "/nodes/#{node_id}",
              lat: lat,
              lon: lon,
              author_email: author_email,
              contact_details: contact_details
    assert_equal(201, last_response.status)
    projector_process_event(node_id)
  end
end
