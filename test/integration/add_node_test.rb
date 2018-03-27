require 'test_helper'

describe 'add node' do
  describe 'POST /nodes/:node_id' do
    let(:node_id) { SecureRandom.uuid }
    let(:lat) { 51.84 }
    let(:lon) { 5.86 }

    it 'returns success' do
      post_json "/nodes/#{node_id}",
                lat: lat,
                lon: lon,
                author_email: 'harry@example.com',
                contact_details: 'h.potter@example.com or visit me at home'

      assert_equal(201, last_response.status, "Fail with #{last_response.body}")
      assert_kind_of(NodeAdded, last_event(node_id))
      assert_equal(last_event(node_id).aggregate_id, node_id)
      assert_equal(
        last_event(node_id).body,
        'lat' => lat,
        'lon' => lon,
        'author_email' => 'harry@example.com',
        'contact_details' => 'h.potter@example.com or visit me at home'
      )
    end

    describe 'when the node id already exists' do
      before do
        post_json "/nodes/#{node_id}", lat: lat, lon: lon
      end

      it 'returns unprocessable entity' do
        post_json "/nodes/#{node_id}", lat: lat, lon: lon

        assert_equal(422, last_response.status)
        assert_equal(
          last_response.body,
          %(Unprocessable Entity: Node "#{node_id}" already exists)
        )
      end
    end

    describe 'with a missing lat or lon' do
      it 'returns bad request for missting lon' do
        post_json "/nodes/#{node_id}", lat: lat

        assert_equal(400, last_response.status)
        assert_equal last_response.body, 'Bad Request: lon is blank'
      end

      it 'returns bad request for missting lat' do
        post_json "/nodes/#{node_id}", lon: lon

        assert_equal(400, last_response.status)
        assert_equal last_response.body, 'Bad Request: lat is blank'
      end
    end
  end
end
