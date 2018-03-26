require 'test_helper'

describe HiveMap::Commands::Node::Add::Command do
  describe '.build' do
    subject { HiveMap::Commands::Node::Add::Command }

    describe 'without a node_id' do
      let(:params) { { lat: 10, lon: 10 } }

      it 'raises as error' do
        assert_raises(BadRequest, 'todo_id is blank') { subject.build(params) }
      end
    end

    describe 'without a lat' do
      let(:params) { { node_id: SecureRandom.uuid, lon: 10 } }

      it 'raises as error' do
        assert_raises(BadRequest, 'lat is blank') { subject.build(params) }
      end
    end

    describe 'without a lon' do
      let(:params) { { node_id: SecureRandom.uuid, lat: 10 } }

      it 'raises as error' do
        assert_raises(BadRequest, 'lon is blank') { subject.build(params) }
      end
    end
  end
end
