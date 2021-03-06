# Ephesus::Core Development Notes

## Core

## Actions

- DSL: set options for Controller#available_actions (see below)
  - short description (< 80 chars? for "what can I do")
  - long description (for "help")
  - examples

## Applications

## Controllers

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

- conditional actions with method names:

  action :request_clearance, RequestClearance, if: :can_request_clearance?

- action aliases:

  alias_action :do_trick, as: :do_a_trick
  alias_action :dance, as: %i[shake rattle roll]

## Results

- error messages should be namespaced strings
- Command::Result#command_class
  => name of class (can be different from command name)

## Ephesus::RSpec

- matchers, examples, helpers for testing Ephesus applications
  - should be a passing result
  - should be a failing result
  - should define action, action_name, action_class
  - should have available action, action_name, action_class
