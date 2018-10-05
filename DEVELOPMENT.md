# Ephesus::Core Development Notes

## Core

## Actions

- DSL: set options for Controller#available_actions (see below)
- ::properties method:
  - returns Hash of action info, see #available_actions
- ::signature method:
  - returns an Action::Signature for the Action, see below

## Action::Result

- Custom subclass of Cuprum::Result.
- Action generates with #build_result method.
- Has additional properties:
  - action_name
  - arguments
  - keywords

### Action::Signature

- constructor takes an Action
- #match(arguments, keywords):

  returns [success(Boolean), error_result(Action::Result, nil)]

## Applications

## Controllers

- ::action:

  Set additional metadata
  - :name
  - :properties, from action_class::properties
  - :signature, from action_class::signature

- #available_actions :
  ```
  {
    cast: {
      aliases: ['incant'],
      arguments: [
        {
          name: 'spell',
          type: String,
          description:
            'The spell to cast.'
        }
      ],
      keywords: {
        targets: {
          name: 'on',
          aliases: ['at'],
          type: Array[String],
          description:
            'The target of the spell.',
          optional: true
        }
      },
      description: 'Casts a spell at the specified target.',
      examples: [
        {
          command: 'cast mage armor',
          description: 'Casts the "mage armor" spell'
        },
        {
          header: 'Casting a spell with a target',
          command: 'cast magic missile on goblin',
          description: 'Casts the "magic missile" spell at the goblin'
        }
      ]
    },
    go: {},
    look: {}
  }
  ```

- #execute_action:
  - catch (pre-check?) argument errors, respond with failing Result
  - see Action::Signature above

- conditional actions with method names:

  action :request_clearance, RequestClearance, if: :can_request_clearance?

- action aliases:

  alias_action :do_trick, as: :do_a_trick
  alias_action :dance, as: %i[shake rattle roll]

## Events

- StateUpdateEvent:
  - used for handling output
  - CANNOT BE USED IN A REDUCER
  - #parent_event
  - #previous_state
  - #current_state

## Ephesus::RSpec

- matchers, examples, helpers for testing Ephesus applications
