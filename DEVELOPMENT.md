# Ephesus::Core Development Notes

## Core

- Autoload top-level classes.

## Applications

- Update Application#initialize :
  If no event_dispatcher is given, initialize a new EventDispatcher.

## Controllers

- #available_actions :
  {
    radio: {},
    takeoff: {},
    taxi: {
      aliases: [],
      arguments: [
        {
          name: 'to',
          aliases: [],
          type: String,
          description:
            'The destination to taxi to. Can be "hangar", "tarmac" or "runway".'
        }
      ],
      description:
        'Taxis your aircraft to another location in the airport.'
    }
  }
- Conditional actions:

  action :taxi, TaxiAction, if: ->(state) { state.get(:landed) }
