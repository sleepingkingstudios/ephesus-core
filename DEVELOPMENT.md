# Ephesus::Core Development Notes

Context
- inherits from Bronze entity
- information about the current game state scoped to a controller

Controller
- constructor takes an event dispatcher (required)
- constructor takes or creates a context
- has actions, which modify the context and dispatch events

Application
- constructor takes or creates an event dispatcher
- has a stack of controllers (inject event dispatcher)
- manages controller stack (default controller)
- process input and forward to current controller

Events
- Event mixins? - can append event type(s), add data keys
- Event helpers
