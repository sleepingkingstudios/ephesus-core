# Ephesus::Core Development Notes

Event
- ::from_hash, #to_h
- nested event types
- comparisons:
  - ==(event): compare event_type(s), data equality
  - ==(event_type): event.event_type == event_type
  - <  event is a event of type

EventDispatcher

EventListener

Core::Events namespace?
- CustomEvent
- EventBuilder
- EventRegistry
  - ::event :custom_event, ParentEvent, \*prop_names
    - creates My::Namespace::CustomEvent < ParentEvent
    - event_type = 'my.namespace.custom_event'
      - 1-1 correspondence bt event class name, event type

```
module Ephesus::Explorer::Events
  include Ephesus::Core::Events::EventRegistry

  event :RoomEvent, :room
  event :EnterRoomEvent, RoomEvent
  event :ExitRoomEvent, RoomEvent, :exit
end
```
