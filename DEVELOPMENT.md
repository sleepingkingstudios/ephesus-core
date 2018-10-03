# Ephesus::Core Development Notes

## Core

## Applications

## Controllers

- execute_action should return the Result (may only need tests)
- return a failing Result when no matching action (instead of raising error)
  - if the action exists but is unavailable, "you can't do that right now"
  - if the action does not exist, "I don't know how to X"

- secret actions:
  - action :do_something, secret: true
  - if the action exists but is unavailable, display message as does not exist

- conditional actions with method names:

  action :request_clearance, RequestClearance, if: :can_request_clearance?

- action aliases:

  alias_action :do_trick, as: :do_a_trick
  alias_action :dance, as: %i[shake rattle roll]

## Ephesus::RSpec

- matchers, examples, helpers for testing Ephesus applications
