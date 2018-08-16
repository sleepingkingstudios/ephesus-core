# Ephesus::Core Development Notes

- EventRegistry
  - ::event :custom_event, ParentEvent, \*prop_names
    - creates My::Namespace::CustomEvent < ParentEvent
    - event_type = 'my.namespace.custom_event'
      - 1-1 correspondence bt event class name, event type

Refactor EventBuilder => SubclassBuilder

```
module Ephesus::Explorer::Events
  include Ephesus::Core::Events::EventRegistry

  event :RoomEvent, :room
  event :EnterRoomEvent, RoomEvent
  event :ExitRoomEvent, RoomEvent, :exit
end
```
