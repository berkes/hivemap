module HiveMap
  module Aggregates
    ##
    # A +node+ is one of the core elements in the OpenStreetMap data model. It
    # consists of a single point in space defined by its latitude, longitude
    # and node id.
    class Node
      include EventSourcery::AggregateRoot

      # These apply methods are the hook that this aggregate uses to update
      # its internal state from events.

      apply NodeAdded do |event|
        # We track the ID when a node is added so we can ensure the same node
        # isn't added twice.
        #
        # We can save more attributes off the event in here as necessary.
        @aggregate_id = event.aggregate_id
      end

      def add(payload)
        raise UnprocessableEntity, "Node #{id.inspect} already exists" if added?

        apply_event(NodeAdded, aggregate_id: id, body: payload)
      end

      # The methods below are how this aggregate handles different commands.
      # Note how they raise new events to indicate the change in state.

      private

      def added?
        @aggregate_id
      end
    end
  end
end
