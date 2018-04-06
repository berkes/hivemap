require 'test_helper'

class AddNodeUITest < Minitest::JsTest
  before do
    setup_projectors
    Capybara.current_driver = Capybara.javascript_driver
  end

  it 'shows a popup with a link' do
    visit '/'
    page.driver.click(575, 408)

    assert page.has_link?('Add hive')
    link = page.find('a#popup-link')
    assert_match %r{/nodes/new\?lat=[\d.]*&lon=[\d.]*}, link[:href]

    link.click
    assert_text('Add hive')
  end

  it 'nodes/new form submits a minimal node' do
    visit '/nodes/new?lat=51.86652806229796&lon=5.839233398437499'

    fill_in 'E-mail', with: 'harry@example.com'
    click_button 'Submit'

    skip('TODO: find out why the show/hide JS does not trigger when testing')
    page.find('ui.message.success').assert_text('Hive submitted successfully.')
  end
end
