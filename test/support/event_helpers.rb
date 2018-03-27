##
# Helpers for testing events.
module EventHelpers
  def last_event(aggregate_id)
    HiveMap.event_store.get_events_for_aggregate_id(aggregate_id).last
  end
end
