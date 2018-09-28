# Ephesus::Core Development Notes

## Core

## Applications

## Controllers

- conditional actions with method names:

  action :request_clearance, RequestClearance, if: :can_request_clearance?
