# Ephesus::Core Development Notes

## Core

## Actions

- DSL: set options for Controller#available_actions (see below)

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

## Ephesus::RSpec

- matchers, examples, helpers for testing Ephesus applications
