module HiveMap
  module Projections
    module Proposed
      # Query handler that queries the projection table.
      class Query
        def self.handle
          HiveMap.projections_database[:query_proposed_nodes]
                 .select(:node_id, :lat, :lon, :author_email, :contact_details)
                 .order(Sequel.desc(:proposed_at))
                 .all
        end
      end
    end
  end
end
