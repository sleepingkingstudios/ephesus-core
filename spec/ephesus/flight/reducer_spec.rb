# frozen_string_literal: true

require 'ephesus/core/application'
require 'ephesus/flight/reducer'

RSpec.describe Ephesus::Flight::Reducer do
  let(:initial_state) { { landed: true, location: 'hangar' } }
  let(:application)   { Spec::ApplicationWithReducer.new }

  example_class 'Spec::ApplicationWithReducer',
    base_class: Ephesus::Core::Application \
  do |klass|
    klass.send :include, described_class

    hsh = initial_state
    klass.define_method(:initial_state) { hsh }
  end

  pending
end
