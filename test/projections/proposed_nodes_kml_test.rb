require 'test_helper'

describe HiveMap::Projections::ProposedNodesKml::Projector do
  let(:file) { File.join('public', 'proposed_nodes.kml') }
  let(:xml_doc) { Nokogiri::XML(File.read(file)) }
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
          contact_details: 'The Nest',
          amount: 1
        }
      )
    end

    let(:kml_file_mock) do
      Minitest::Mock.new.expect(:objects, [])
    end

    before do
      subject.setup
    end

    it 'inserts a PlaceMark point' do
      subject.process(event)
      assert_file_contains(file, '<coordinates>20.02,20.01</coordinates>')
    end

    it 'inserts amount times, this PlaceMark point' do
      event.body['amount'] = 2
      subject.process(event)
      descriptions = xml_doc.xpath('//xmlns:description')
      assert_equal(2, descriptions.length)
    end

    it 'inserts a PlaceMark description' do
      subject.process(event)
      descriptions = xml_doc.xpath('//xmlns:description')
      assert_includes(descriptions.text, 'The Nest')
    end

    it 'allows empty PlaceMark description' do
      event.body['contact_details'] = nil
      subject.process(event)
      descriptions = xml_doc.xpath('//xmlns:description')
      assert_empty(descriptions.text.strip)
    end

    it 'sanitizes PlaceMark description' do
      event.body['contact_details'] = '<h1>My name is "Bond"</h1>'
      subject.process(event)
      descriptions = xml_doc.xpath('//xmlns:description')
      refute_includes(descriptions.text, '<h1>')
      assert_includes(descriptions.text, '&lt;/h1&gt;')
      assert_includes(descriptions.text, '&quot;Bond&quot;')
    end

    it 'converts line endings to br in PlaceMark description' do
      event.body['contact_details'] = "one\ntwo\rthree"
      subject.process(event)
      descriptions = Nokogiri::XML(File.read(file)).xpath('//xmlns:description')
      assert_includes(descriptions.text, 'one<br/>two<br/>three')
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
