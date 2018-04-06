require 'test_helper'

describe HiveMap::Commands::Node::Add::Command do
  describe '.build' do
    subject { HiveMap::Commands::Node::Add::Command }

    let(:params) do
      {
        node_id: SecureRandom.uuid,
        lat: 10,
        lon: 10,
        author_email: 'harry@example.com',
        name: 'Hogwards Hyves',
        amount: 1
      }
    end

    describe 'without a node_id' do
      before { params.delete(:node_id) }

      it 'raises as error' do
        assert_raises(BadRequest, 'todo_id is blank') { subject.build(params) }
      end
    end

    describe 'without a lat' do
      before { params.delete(:lat) }

      it 'raises as error' do
        assert_raises(BadRequest, 'lat is blank') { subject.build(params) }
      end
    end

    describe 'without a lon' do
      before { params.delete(:lon) }

      it 'raises as error' do
        assert_raises(BadRequest, 'lon is blank') { subject.build(params) }
      end
    end

    describe 'without an author_email' do
      before { params.delete(:author_email) }

      it 'raises as error' do
        assert_raises(BadRequest, 'author_email is blank') do
          subject.build(params)
        end
      end
    end

    describe 'without a name' do
      before { params.delete(:name) }

      it 'raises as error' do
        assert_raises(BadRequest, 'name is blank') { subject.build(params) }
      end
    end

    describe 'without an amount' do
      before { params.delete(:amount) }

      it 'raises as error' do
        assert_raises(BadRequest, 'amount is blank') { subject.build(params) }
      end
    end

    describe 'with a too large amount' do
      before { params[:amount] = 101 }

      it 'raises as error' do
        assert_raises(BadRequest, 'amount must be between 1 and 100') do
          subject.build(params)
        end
      end
    end

    describe 'with a too small amount' do
      before { params[:amount] = 0 }

      it 'raises as error' do
        assert_raises(BadRequest, 'amount must be between 1 and 100') do
          subject.build(params)
        end
      end
    end
  end
end
