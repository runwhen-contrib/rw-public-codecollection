# Discord Send Message

## TaskSet 
Sends a static message to a Discord chat channel via webhook. There is optional configuration for including live runsession info and links
for team members to quickly access running sessions.

## Use Cases
- Send an alert when an SLO is burning too much budget which contains a link to the active runsession.
- Let your team members know you're in a live runsession and provide them with a link to join you.

## Requirements
- A `webhook_url` secret which allows the codebundle to perform an incoming webhook post request against the service API.

## TODO
- [ ] Add additional documentation