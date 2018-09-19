# frozen_string_literal: true

require 'sleeping_king_studios/tasks'

SleepingKingStudios::Tasks.configure do |config|
  config.ci do |ci|
    ci.steps =
      if ENV['CI']
        %i[rspec rspec_each rubocop simplecov]
      else
        %i[rspec rubocop simplecov]
      end
  end
end

load 'sleeping_king_studios/tasks/ci/tasks.thor'
load 'sleeping_king_studios/tasks/file/tasks.thor'
