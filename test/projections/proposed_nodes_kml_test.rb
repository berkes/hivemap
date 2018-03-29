require 'test_helper'

describe HiveMap::Projections::ProposedNodesKml::Projector do
  let(:file) { File.join('public', 'proposed_nodes.kml') }
  let(:tracker) { Minitest::Mock.new }
  subject do
    HiveMap::Projections::ProposedNodesKml::Projector.new(tracker: tracker)
  end

  before do
    File.delete(file) if File.exist?(file)
  end

  describe 'setup' do
    it 'creates a KML file' do
      subject.setup

      assert(File.exist?(file), "File #{file} not found")
    end
  end

  describe 'process on NodeAdded' do
    let(:event) do
      NodeAdded.new(
        aggregate_id: SecureRandom.uuid,
        body: {
          lat: 20.01,
          lon: 20.02,
          author_email: 'ronweasly@example.com',
          contact_details: 'The Nest'
        }
      )
    end

    let(:kml_file_mock) do
      Minitest::Mock.new.expect(:objects, [])
    end

    before do
      subject.setup
    end

    it 'inserts a PlaceMark' do
      subject.process(event)
      assert_file_contains(file, '<coordinates>20.02,20.01</coordinates>')
    end

    it 'saves a file' do
      kml_file_mock.expect(:save, true, [file])
      subject.kml_file = kml_file_mock

      subject.process(event)
      assert_mock kml_file_mock
    end

    it 'appends a file' do
      kml_builder = KMLFile.new
      kml_builder.objects << KML::Placemark.new(
        geometry: KML::Point.new(coordinates: { lat: 30.01, lng: 30.02 })
      )
      kml_builder.save(file)

      subject.process(event)

      # the order does not really matter
      assert_file_contains(file, '<coordinates>20.02,20.01</coordinates>')
      assert_file_contains(file, '<coordinates>30.02,30.01</coordinates>')
    end
  end
end
