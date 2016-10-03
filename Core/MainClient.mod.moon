--//
--// * Main Module for Freya Client
--// | Utility entry point for everything not done manually
--// | Tracks all modules, components, libraries, etc.
--//

ni = newproxy true

Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...
  
IsInstance = do
  game = game
  gs = game.GetService
  type = type
  pcall = pcall
  (o using nil) ->
    type = type o
    return false if type ~= 'userdata'
    s,e = pcall gs, game, o
    return s and not e
  

Components = {}

with game.ReplicatedStorage.Freya.Components
  \WaitForChild "Events"
  for v in *.Shared\GetChildren!
    Components[v.Name] = require v
  for v in *.Client\GetChildren!
    Components[v.Name] = require v

ComponentAdded = Components.Events.new!

game.ReplicatedStorage.Freya.Components.DescendantAdded\connect (obj) ->
  Components[obj.Name] = require obj;
  ComponentAdded\Fire obj.Name

Controller = with {
    GetComponent: Hybrid (ComponentName) ->
      component = Components[ComponentName]
      if component
        if IsInstance(component)
          component = require component
        return component
      warn "[WARN][Freya Client] Yielding for #{ComponentName}"
      while ComponentAdded\wait! ~= ComponentName do nothing
      return Components[ComponentName]
    SetComponent: Hybrid (ComponentName, ComponentValue) ->
      if Components[ComponentName]
        warn "[WARN][Freya Client] Overwriting component #{ComponentName}"
      Components[ComponentName] = ComponentValue
      ComponentAdded\Fire ComponentName
  }
  .GetService = .GetComponent
  .SetService = .SetComponent
  .GetModule = .GetComponent
  .SetModule = .SetComponent

with getmetatable ni
  .__index = Controller
  .__tostring = -> "Freya Client Controller"
  .__metatable = "Locked metatable: Freya Client"
  
return ni
