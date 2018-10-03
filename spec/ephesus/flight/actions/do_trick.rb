# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'ephesus/core/action'
require 'ephesus/flight/actions'
require 'ephesus/flight/events'

module Ephesus::Flight::Actions
  class DoTrick < Ephesus::Core::Action
    TRICK_VALUES = {
      barrel_roll:    10,
      loop:           20,
      immelmann_turn: 30
    }.freeze

    private

    def process(trick)
      key = tools.string.underscore(trick).downcase.gsub(/\s+/, '_').intern

      unless TRICK_VALUES.key?(key)
        result.errors[:trick].add(:invalid, trick: trick)

        return
      end

      dispatch_event(score_event key)
    end

    def score_event(key)
      amount = TRICK_VALUES[key]

      Ephesus::Flight::Events::UpdateScore.new(by: amount)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
