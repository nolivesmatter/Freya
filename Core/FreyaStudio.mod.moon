--//
--// * Freya Studio util module
--//

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Controller = 
  Install: Hybrid (Package, Version) ->
    -- Install a package.
    return nil
  Update: ->
    -- Update Freya
    return nil
  GetPackages: ->
    -- Get the current packages list 
    return nil
  Load: Hybrid (UtilPackage) ->
    -- Load something from Util
    return nil

with getmetatable ni
  .__index = Controller
  .__tostring = -> "FreyaStudio Controller"
  .__metatable = "Locked Metatable: Freya"

return ni
