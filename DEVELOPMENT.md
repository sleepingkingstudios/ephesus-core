# Ephesus::Core Development Notes

Context
- inherits from Bronze entity
- information about the current game state scoped to a controller

Controller
- constructor takes an event dispatcher (required)
- constructor takes or creates a context
- has actions, which modify the context and dispatch events
- #identifier - UUID ?
- #action_info

```ruby
controller.action_info #=>
  {
    build => {
      arguments: [],
      about: [],
      help: []
    }
  }
```

Application
- constructor takes or creates an event dispatcher
- has a stack of controllers (inject event dispatcher)
- manages controller stack (default controller)
- process input and forward to current controller
- ::new(event_dispatcher:)
- #execute_action(action_name, \*\*options)
- #current_controller
- #start_controller(name, \*args) - builds, then pushes controller
- private #build_controller(name, \*args)
- #stop_controller(name)

Events
- Event mixins? - can append event type(s), add data keys
- Event helpers
