-- Scripts are only run if they're Enabled anyway.
-- Later, scripts will be managed by Freya.
-- For now, they're not. For reasons.

local Key = script.Parent.Key.Value
Key = #Key > 1 and Key or "YourKeyHere" -- For 'secure' imp

local Game = script.Parent.Game.Value
Game = #Game > 1 and Game or "YourGameHere" -- For paranoids

local Version = script.Parent.Version.Value
Version = Version > 1 and Version or 299451592 -- Default to bleeding-edge

local Valkyrie = require(Version)(Game, Key);
-- If and when needed, add integration to Valk here
-- Assuming that it can't just use the default compat
