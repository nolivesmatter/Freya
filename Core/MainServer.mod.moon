--//
--// * Main Module for Freya Server
--// | Utility entry point for everything not done manually
--// | Tracks all modules, components, libraries, etc.
--//

ni = newproxy true

Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Components = {}

ComponentAdded = Components.Events.new!

Controller = with {
    GetComponent: Hybrid (ComponentName) ->
      component = Components[ComponentName]
      return component if component
      warn "[WARN][Freya Server] Yielding for #{ComponentName}"
      while ComponentAdded\wait! ~= ComponentName do nothing
      return Components[ComponentName]
    SetComponent: Hybrid (ComponentName, ComponentValue) ->
      if Components[ComponentName]
        warn "[WARN][Freya Server] Overwriting component #{ComponentName}"
      Components[ComponentName] = ComponentValue
      ComponentAdded\fire!
  }
  .GetService = .GetComponent
  .SetService = .SetComponent
  .GetModule = .GetComponent
  .SetModule = .SetComponent

for v in *game.ReplicatedStorage.Freya.Components.Shared\GetChildren!
  Components[v.Name] = require v

for v in *game.ServerStorage.Freya.Components\GetChildren!
  Components[v.Name] = require v

with getmetatable ni
  .__index = Controller
  .__tostring = -> "Freya Server Controller"
  .__metatable = "Locked metatable: Freya Server"
  
return ni
