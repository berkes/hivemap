require 'test_helper'

describe 'add node through REST' do
  describe 'POST /nodes/:node_id' do
    let(:node_id) { SecureRandom.uuid }
    let(:params) do
      {
        lat: 51.84,
        lon: 5.86,
        name: 'Hogwarts Hives',
        author_email: 'harry@example.com',
        contact_details: 'h.potter@example.com or visit me at home',
        amount: 1
      }
    end

    it 'returns success' do
      post_json "/nodes/#{node_id}", params

      assert_equal(201, last_response.status, "Fail with #{last_response.body}")
      assert_kind_of(NodeAdded, last_event(node_id))
      assert_equal(last_event(node_id).aggregate_id, node_id)
      assert_equal(
        last_event(node_id).body,
        'lat' => 51.84,
        'lon' => 5.86,
        'name' => 'Hogwarts Hives',
        'author_email' => 'harry@example.com',
        'contact_details' => 'h.potter@example.com or visit me at home',
        'amount' => 1
      )
    end

    it 'adds a node to proposed_nodes projection' do
      setup_projectors
      post_json "/nodes/#{node_id}", params

      projector_process_event(node_id)

      assert_equal(HiveMap::Projections::Proposed::Query.handle.first[:node_id],
                   node_id)
    end

    it 'adds a node to proposed_nodes KML projection' do
      setup_projectors
      post_json "/nodes/#{node_id}", params

      projector_process_event(node_id)

      kml = File.read(File.join('public', 'proposed_nodes.kml'))
      placemarks = Nokogiri::XML(kml).xpath('//xmlns:Placemark')

      assert_includes(placemarks.inner_text.strip, '5.86,51.84')
    end

    describe 'when the node id already exists' do
      before do
        post_json "/nodes/#{node_id}", params
      end

      it 'returns unprocessable entity' do
        post_json "/nodes/#{node_id}", params

        assert_equal(422, last_response.status)
        assert_equal(
          last_response.body,
          %(Unprocessable Entity: Node "#{node_id}" already exists)
        )
      end
    end

    describe 'with a missing lat or lon' do
      it 'returns bad request for missting lon' do
        post_json "/nodes/#{node_id}", params.merge(lon: nil)

        assert_equal(400, last_response.status)
        assert_equal last_response.body, 'Bad Request: lon is blank'
      end

      it 'returns bad request for missting lat' do
        post_json "/nodes/#{node_id}", params.merge(lat: nil)

        assert_equal(400, last_response.status)
        assert_equal last_response.body, 'Bad Request: lat is blank'
      end
    end
  end
end
