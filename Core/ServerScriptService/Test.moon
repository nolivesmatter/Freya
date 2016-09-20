--//
--// * Test script for Freya Server
--// | Makes sure modules work
--//

print "Loaded Freya Server test"
local Intents, Permissions, Events
with _G.Freya
  Intents = .GetComponent "Intents"
  Permissions = .GetComponent "Permissions"
  Events = .GetComponent "Events"

print "Loaded Components"
