# frozen_string_literal: true

require 'ephesus/flight/application'
require 'ephesus/flight/session'

# rubocop:disable RSpec/FilePath
# rubocop:disable RSpec/NestedGroups
RSpec.describe Ephesus::Flight::Application do
  shared_context 'when at the runway' do
    before(:example) { session.execute_action :taxi, to: 'runway' }
  end

  shared_context 'when on the tarmac' do
    before(:example) { session.execute_action :taxi, to: 'tarmac' }
  end

  shared_context 'when flying' do
    before(:example) do
      session.execute_action :radio_tower
      session.execute_action :request_clearance
      session.execute_action :turn_off_radio
      session.execute_action :taxi, to: 'runway'
      session.execute_action :take_off
    end
  end

  shared_context 'when radioing the tower' do
    before(:example) { session.execute_action :radio_tower }
  end

  shared_context 'when clearance has been granted' do
    before(:example) do
      session.execute_action :radio_tower
      session.execute_action :request_clearance
      session.execute_action :turn_off_radio
    end
  end

  let(:application) { described_class.new }
  let(:session)     { Ephesus::Flight::Session.new(application) }
  let(:initial_state) do
    {
      landed:            true,
      landing_clearance: false,
      location:          'hangar',
      radio:             false,
      takeoff_clearance: false
    }
  end

  describe '#available_actions' do
    context 'when in the hangar' do
      let(:expected) { %i[radio_tower taxi] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      wrap_context 'when clearance has been granted' do
        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end

    wrap_context 'when at the runway' do
      let(:expected) { %i[radio_tower taxi] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      wrap_context 'when clearance has been granted' do
        let(:expected) { super() << :take_off }

        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end

    wrap_context 'when on the tarmac' do
      let(:expected) { %i[radio_tower taxi] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      wrap_context 'when clearance has been granted' do
        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end

    context 'when radioing the tower from the ground' do
      include_context 'when radioing the tower'

      let(:expected) { %i[request_clearance turn_off_radio] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      context 'when takeoff clearance has been granted' do
        let(:expected) { super().tap { |ary| ary.delete(:request_clearance) } }

        before(:example) { session.execute_action :request_clearance }

        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end

    wrap_context 'when flying' do
      let(:expected) { %i[do_trick radio_tower] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      wrap_context 'when clearance has been granted' do
        let(:expected) { super() << :land }

        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end

    context 'when radioing the tower from the air' do
      include_context 'when flying'
      include_context 'when radioing the tower'

      let(:expected) { %i[request_clearance turn_off_radio] }

      it 'should return the actions' do
        expect(session.available_actions.keys).to contain_exactly(*expected)
      end

      context 'when landing clearance has been granted' do
        let(:expected) { super().tap { |ary| ary.delete(:request_clearance) } }

        before(:example) { session.execute_action :request_clearance }

        it 'should return the actions' do
          expect(session.available_actions.keys).to contain_exactly(*expected)
        end
      end
    end
  end

  describe '#state' do
    context 'when in the hangar' do
      it { expect(application.state).to be == initial_state }

      describe 'radioing the tower' do
        let(:expected) { initial_state.merge(radio: true) }

        it 'should update the state' do
          expect { session.execute_action :radio_tower }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taking off' do
        it 'should raise an error' do
          expect { session.execute_action :take_off }
            .to raise_error ArgumentError, 'unavailable action name :take_off'
        end
      end

      describe 'taxi-ing to an invalid location' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'tower' }
            .not_to change(application, :state)
        end
      end

      describe 'taxi-ing to the hangar' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'hangar' }
            .not_to change(application, :state)
        end
      end

      describe 'taxi-ing to the runway' do
        let(:expected) { initial_state.merge(location: 'runway') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'runway' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taxi-ing to the tarmac' do
        let(:expected) { initial_state.merge(location: 'tarmac') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'tarmac' }
            .to change(application, :state).to be == expected
        end
      end

      context 'when takeoff clearance has been granted' do
        let(:initial_state) do
          super().merge(
            radio: false,
            takeoff_clearance: true
          )
        end

        before(:example) do
          session.execute_action :radio_tower
          session.execute_action :request_clearance
          session.execute_action :turn_off_radio
        end

        it { expect(application.state).to be == initial_state }

        describe 'radioing the tower' do
          let(:expected) { initial_state.merge(radio: true) }

          it 'should update the state' do
            expect { session.execute_action :radio_tower }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taking off' do
          it 'should raise an error' do
            expect { session.execute_action :take_off }
              .to raise_error ArgumentError, 'unavailable action name :take_off'
          end
        end

        describe 'taxi-ing to an invalid location' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'tower' }
              .not_to change(application, :state)
          end
        end

        describe 'taxi-ing to the hangar' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'hangar' }
              .not_to change(application, :state)
          end
        end

        describe 'taxi-ing to the runway' do
          let(:expected) { initial_state.merge(location: 'runway') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'runway' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taxi-ing to the tarmac' do
          let(:expected) { initial_state.merge(location: 'tarmac') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'tarmac' }
              .to change(application, :state).to be == expected
          end
        end
      end
    end

    wrap_context 'when at the runway' do
      let(:initial_state) { super().merge location: 'runway' }

      it { expect(application.state).to be == initial_state }

      describe 'radioing the tower' do
        let(:expected) { initial_state.merge(radio: true) }

        it 'should update the state' do
          expect { session.execute_action :radio_tower }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taking off' do
        it 'should raise an error' do
          expect { session.execute_action :take_off }
            .to raise_error ArgumentError, 'unavailable action name :take_off'
        end
      end

      describe 'taxi-ing to an invalid location' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'tower' }
            .not_to change(application, :state)
        end
      end

      describe 'taxi-ing to the hangar' do
        let(:expected) { initial_state.merge(location: 'hangar') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'hangar' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taxi-ing to the runway' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'runway' }
            .not_to change(application, :state)
        end
      end

      describe 'taxi-ing to the tarmac' do
        let(:expected) { initial_state.merge(location: 'tarmac') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'tarmac' }
            .to change(application, :state).to be == expected
        end
      end

      wrap_context 'when clearance has been granted' do
        let(:initial_state) do
          super().merge(
            radio: false,
            takeoff_clearance: true
          )
        end

        it { expect(application.state).to be == initial_state }

        describe 'radioing the tower' do
          let(:expected) { initial_state.merge(radio: true) }

          it 'should update the state' do
            expect { session.execute_action :radio_tower }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taking off' do
          let(:expected) do
            initial_state
              .merge(
                landed:            false,
                location:          nil,
                takeoff_clearance: false
              )
          end

          it 'should update the state' do
            expect { session.execute_action :take_off }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taxi-ing to an invalid location' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'tower' }
              .not_to change(application, :state)
          end
        end

        describe 'taxi-ing to the hangar' do
          let(:expected) { initial_state.merge(location: 'hangar') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'hangar' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taxi-ing to the runway' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'runway' }
              .not_to change(application, :state)
          end
        end

        describe 'taxi-ing to the tarmac' do
          let(:expected) { initial_state.merge(location: 'tarmac') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'tarmac' }
              .to change(application, :state).to be == expected
          end
        end
      end
    end

    wrap_context 'when on the tarmac' do
      let(:initial_state) { super().merge location: 'tarmac' }

      it { expect(application.state).to be == initial_state }

      describe 'radioing the tower' do
        let(:expected) { initial_state.merge(radio: true) }

        it 'should update the state' do
          expect { session.execute_action :radio_tower }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taking off' do
        it 'should raise an error' do
          expect { session.execute_action :take_off }
            .to raise_error ArgumentError, 'unavailable action name :take_off'
        end
      end

      describe 'taxi-ing to an invalid location' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'tower' }
            .not_to change(application, :state)
        end
      end

      describe 'taxi-ing to the hangar' do
        let(:expected) { initial_state.merge(location: 'hangar') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'hangar' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taxi-ing to the runway' do
        let(:expected) { initial_state.merge(location: 'runway') }

        it 'should update the state' do
          expect { session.execute_action :taxi, to: 'runway' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'taxi-ing to the tarmac' do
        it 'should not update the state' do
          expect { session.execute_action :taxi, to: 'tarmac' }
            .not_to change(application, :state)
        end
      end

      wrap_context 'when clearance has been granted' do
        let(:initial_state) do
          super().merge(
            radio: false,
            takeoff_clearance: true
          )
        end

        it { expect(application.state).to be == initial_state }

        describe 'radioing the tower' do
          let(:expected) { initial_state.merge(radio: true) }

          it 'should update the state' do
            expect { session.execute_action :radio_tower }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taking off' do
          it 'should raise an error' do
            expect { session.execute_action :take_off }
              .to raise_error ArgumentError, 'unavailable action name :take_off'
          end
        end

        describe 'taxi-ing to an invalid location' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'tower' }
              .not_to change(application, :state)
          end
        end

        describe 'taxi-ing to the hangar' do
          let(:expected) { initial_state.merge(location: 'hangar') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'hangar' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taxi-ing to the runway' do
          let(:expected) { initial_state.merge(location: 'runway') }

          it 'should update the state' do
            expect { session.execute_action :taxi, to: 'runway' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'taxi-ing to the tarmac' do
          it 'should not update the state' do
            expect { session.execute_action :taxi, to: 'tarmac' }
              .not_to change(application, :state)
          end
        end
      end
    end

    context 'when radioing the tower from the ground' do
      include_context 'when radioing the tower'

      let(:initial_state) { super().merge radio: true }

      it { expect(application.state).to be == initial_state }

      describe 'requesting takeoff clearance' do
        let(:expected) { initial_state.merge(takeoff_clearance: true) }

        it 'should update the state' do
          expect { session.execute_action :request_clearance }
            .to change(application, :state).to be == expected
        end
      end

      describe 'turning off the radio' do
        let(:expected) { initial_state.merge(radio: false) }

        it 'should update the state' do
          expect { session.execute_action :turn_off_radio }
            .to change(application, :state).to be == expected
        end
      end

      context 'when takeoff clearance has been granted' do
        let(:initial_state) { super().merge takeoff_clearance: true }

        before(:example) { session.execute_action :request_clearance }

        it { expect(application.state).to be == initial_state }

        describe 'requesting takeoff clearance' do
          it 'should raise an error' do
            expect { session.execute_action :request_clearance }
              .to raise_error ArgumentError,
                'unavailable action name :request_clearance'
          end
        end

        describe 'turning off the radio' do
          let(:expected) { initial_state.merge(radio: false) }

          it 'should update the state' do
            expect { session.execute_action :turn_off_radio }
              .to change(application, :state).to be == expected
          end
        end
      end
    end

    wrap_context 'when flying' do
      let(:initial_state) do
        super()
          .merge(
            landed:   false,
            location: nil
          )
      end

      it { expect(application.state).to be == initial_state }

      describe 'do a barrel roll' do
        let(:expected) { initial_state.merge(score: 10) }

        it 'should update the state' do
          expect { session.execute_action :do_trick, 'barrel roll' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'do an Immelmann turn' do
        let(:expected) { initial_state.merge(score: 30) }

        it 'should update the state' do
          expect { session.execute_action :do_trick, 'Immelmann turn' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'do a loop' do
        let(:expected) { initial_state.merge(score: 20) }

        it 'should update the state' do
          expect { session.execute_action :do_trick, 'loop' }
            .to change(application, :state).to be == expected
        end
      end

      describe 'landing' do
        it 'should raise an error' do
          expect { session.execute_action :land }
            .to raise_error ArgumentError, 'unavailable action name :land'
        end
      end

      describe 'radioing the tower' do
        let(:expected) { initial_state.merge(radio: true) }

        it 'should update the state' do
          expect { session.execute_action :radio_tower }
            .to change(application, :state).to be == expected
        end
      end

      wrap_context 'when clearance has been granted' do
        let(:initial_state) { super().merge(landing_clearance: true) }

        describe 'do a barrel roll' do
          let(:expected) { initial_state.merge(score: 10) }

          it 'should update the state' do
            expect { session.execute_action :do_trick, 'barrel roll' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'do an Immelmann turn' do
          let(:expected) { initial_state.merge(score: 30) }

          it 'should update the state' do
            expect { session.execute_action :do_trick, 'Immelmann turn' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'do a loop' do
          let(:expected) { initial_state.merge(score: 20) }

          it 'should update the state' do
            expect { session.execute_action :do_trick, 'loop' }
              .to change(application, :state).to be == expected
          end
        end

        describe 'landing' do
          let(:expected) do
            initial_state
              .merge(
                landed:            true,
                landing_clearance: false,
                location:          'runway'
              )
          end

          it 'should update the state' do
            expect { session.execute_action :land }
              .to change(application, :state).to be == expected
          end
        end

        describe 'radioing the tower' do
          let(:expected) { initial_state.merge(radio: true) }

          it 'should update the state' do
            expect { session.execute_action :radio_tower }
              .to change(application, :state).to be == expected
          end
        end
      end
    end

    context 'when radioing the tower from the air' do
      let(:initial_state) do
        super()
          .merge(
            landed:   false,
            location: nil,
            radio:    true
          )
      end

      before(:example) do
        session.execute_action :radio_tower
        session.execute_action :request_clearance
        session.execute_action :turn_off_radio
        session.execute_action :taxi, to: 'runway'
        session.execute_action :take_off
        session.execute_action :radio_tower
      end

      it { expect(application.state).to be == initial_state }

      describe 'requesting landing clearance' do
        let(:expected) { initial_state.merge(landing_clearance: true) }

        it 'should update the state' do
          expect { session.execute_action :request_clearance }
            .to change(application, :state).to be == expected
        end
      end

      describe 'turning off the radio' do
        let(:expected) { initial_state.merge(radio: false) }

        it 'should update the state' do
          expect { session.execute_action :turn_off_radio }
            .to change(application, :state).to be == expected
        end
      end

      context 'when landing clearance has been granted' do
        let(:initial_state) { super().merge(landing_clearance: true) }

        before(:example) { session.execute_action :request_clearance }

        describe 'requesting landing clearance' do
          it 'should raise an error' do
            expect { session.execute_action :request_clearance }
              .to raise_error ArgumentError,
                'unavailable action name :request_clearance'
          end
        end

        describe 'turning off the radio' do
          let(:expected) { initial_state.merge(radio: false) }

          it 'should update the state' do
            expect { session.execute_action :turn_off_radio }
              .to change(application, :state).to be == expected
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/FilePath
# rubocop:enable RSpec/NestedGroups
