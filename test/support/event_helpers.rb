##
# Helpers for testing events.
module EventHelpers
  def last_event(aggregate_id)
    HiveMap.event_store.get_events_for_aggregate_id(aggregate_id).last
  end

  def projector_process_event(aggregate_id)
    ## TODO: refactor to avoid harcoding the projectors here.
    projector = HiveMap::Projections::ProposedNodes::Projector.new
    projector.setup
    projector.process(last_event(aggregate_id))
  end
end
