# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

require 'ephesus/core/command'
require 'ephesus/flight/commands'
require 'ephesus/flight/state/actions'

module Ephesus::Flight::Commands
  class DoTrick < Ephesus::Core::Command
    TRICK_VALUES = {
      barrel_roll:    10,
      loop:           20,
      immelmann_turn: 30
    }.freeze

    argument :trick

    private

    def process(trick)
      amount = score_trick(trick)

      if amount.nil?
        result.errors[:trick].add(:invalid, trick: trick)

        return
      end

      dispatch(Ephesus::Flight::State::Actions.update_score by: amount)
    end

    def score_trick(trick)
      key = tools.string.underscore(trick).downcase.gsub(/\s+/, '_').intern

      TRICK_VALUES[key]
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
