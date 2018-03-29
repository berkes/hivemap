require 'ruby_kml'

module HiveMap
  module Projections
    module ProposedNodesKml
      ##
      # Handles the ProposedNodes Projection
      class Projector
        include EventSourcery::EventProcessing::EventStreamProcessor
        attr_accessor :filename
        attr_writer :kml_file

        def initialize(tracker:)
          @tracker = tracker
          @filename = File.join('public', 'proposed_nodes.kml')
        end

        def setup
          KMLFile.new.save(filename)
        end

        process NodeAdded do |event|
          kml_file.objects << KML::Placemark.new(
            id: event.aggregate_id,
            name: event.body[:author_email],
            geometry: KML::Point.new(
              coordinates: {
                lat: event.body['lat'],
                lng: event.body['lon']
              }
            )
          )
          kml_file.save(filename)
        end

        private

        def kml_file
          @kml_file ||= KMLFile.parse(File.open(filename, 'r'))
        end
      end
    end
  end
end
