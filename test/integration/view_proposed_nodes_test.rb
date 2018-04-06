require 'test_helper'

describe 'pending nodes' do
  describe 'GET /nodes/proposed' do
    let(:node_id_1) { SecureRandom.uuid }
    let(:node_id_2) { SecureRandom.uuid }
    let(:events) do
      [
        NodeAdded.new(
          aggregate_id: node_id_1,
          body: {
            lat: 10.0001,
            lon: 10.0002,
            author_email: 'harrypotter@example.com',
            contact_details: 'Cupboard under the stairs'
          }
        ),
        NodeAdded.new(
          aggregate_id: node_id_2,
          body: {
            lat: 20.0001,
            lon: 20.0002,
            author_email: 'ronweasly@example.com',
            contact_details: 'The Nest'
          }
        )
      ]
    end
    let(:projector) { HiveMap::Projections::ProposedNodes::Projector.new }

    it 'returns a list of proposed Nodes' do
      projector.setup

      events.each do |event|
        projector.process(event)
      end

      get '/nodes/proposed'

      assert_equal(200, last_response.status)
      expected = [
        {
          node_id: node_id_2,
          lat: BigDecimal('20.0001').to_s,
          lon: BigDecimal('20.0002').to_s,
          author_email: 'ronweasly@example.com',
          contact_details: 'The Nest'
        },
        {
          node_id: node_id_1,
          lat: BigDecimal('10.0001').to_s,
          lon: BigDecimal('10.0002').to_s,
          author_email: 'harrypotter@example.com',
          contact_details: 'Cupboard under the stairs'
        }
      ]
      parsed = JSON.parse(last_response.body, symbolize_names: true)
      assert_equal(expected, parsed)
    end
  end
end
