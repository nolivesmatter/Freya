--//
--// * Freya Studio util module
--//

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Controller = {
  Install: Hybrid (Package, Version) ->
    -- Install a package.
    return nil
  Update: ->
    -- Update Freya
    return nil
  UpdatePackage: Hybrid (Package) ->
    -- Update a package.
    return nil
  GetPackages: ->
    -- Get the current packages list
    return nil
  Load: Hybrid (UtilPackage) ->
    -- Load something from Util
    -- Come back to extend this later when you know how the command bar env
    -- works and persists between calls.
    assert type(UtilPackage) == 'string',
      "You need to supply a string Package name to use",
      2
    mod = script.Parent.Util\FindFirstChild UtilPackage
    assert mod,
      "Invalid package to load",
      2
    return require mod
  Uninstall: Hybrid (Package) ->
    -- Use the package uninstall script or use metadata
    return nil
}

with getmetatable ni
  .__index = Controller
  .__tostring = -> "FreyaStudio Controller"
  .__metatable = "Locked Metatable: Freya"

return ni
