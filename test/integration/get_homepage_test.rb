require 'test_helper'

class GetHomepageTest < Minitest::JsTest
  it 'gets an HTML response' do
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response.content_type
  end

  it 'shows the features in the sidebar' do
    add_and_process_hive
    Capybara.current_driver = Capybara.javascript_driver
    visit '/'
    page.assert_text('visit me at home')
  end

  private

  def add_and_process_hive(node_id: SecureRandom.uuid,
                           lat: 51.84, lon: 5.86,
                           author_email: 'harry@example.com',
                           contact_details: 'visit me at home')
    setup_projectors
    post_json "/nodes/#{node_id}",
              lat: lat,
              lon: lon,
              author_email: author_email,
              contact_details: contact_details
    projector_process_event(node_id)
  end
end
