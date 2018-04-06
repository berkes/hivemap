require 'cgi'
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
          event.body['amount'].to_i.times do
            kml_file.objects << KML::Placemark.new(
              description: simple_format(event.body['contact_details']),
              geometry: KML::Point.new(
                coordinates: {
                  lat: event.body['lat'],
                  lng: event.body['lon']
                }
              )
            )
          end
          kml_file.save(filename)
        end

        private

        def kml_file
          @kml_file ||= KMLFile.parse(File.open(filename, 'r'))
        end

        def simple_format(string)
          CGI.escapeHTML(string.to_s).gsub(/[\r\n]+/, '<br/>').strip
        end
      end
    end
  end
end
