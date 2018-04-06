##
# Helpers for testing events.
module EventHelpers
  def last_event(aggregate_id)
    HiveMap.event_store.get_events_for_aggregate_id(aggregate_id).last
  end

  def projector_process_event(aggregate_id)
    projectors.each do |projector|
      projector.process(last_event(aggregate_id))
    end
  end

  def setup_projectors
    projectors.each(&:setup)
  end

  protected

  def projectors
    @projectors = [
      HiveMap::Projections::ProposedNodes::Projector.new,
      HiveMap::Projections::ProposedNodesKml::Projector.new(
        tracker: EventSourcery::Memory::Tracker.new
      )
    ]
  end
end
