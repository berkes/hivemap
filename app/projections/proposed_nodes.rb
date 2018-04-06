module HiveMap
  module Projections
    module ProposedNodes
      ##
      # Handles the ProposedNodes Projection
      class Projector
        include EventSourcery::Postgres::Projector

        projector_name :proposed_nodes

        # Database tables that form the projection.

        table :query_proposed_nodes do
          column :node_id, 'UUID NOT NULL'
          column :lat, BigDecimal, size: [10, 7] # TODO: move to postgis?
          column :lon, BigDecimal, size: [10, 7]
          column :name, :text
          column :author_email, :text
          column :contact_details, :text
          column :amount, Integer
          column :proposed_at, DateTime
        end

        # Event handlers that update the projection in response to different
        # events from the store.

        project NodeAdded do |event|
          table.insert(
            node_id: event.aggregate_id,
            lat: event.body['lat'],
            lon: event.body['lon'],
            name: event.body['name'],
            author_email: event.body['author_email'],
            contact_details: event.body['contact_details'],
            amount: event.body['amount'].to_i,
            proposed_at: Time.now
          )
        end
      end
    end
  end
end
