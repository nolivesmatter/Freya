--//
--// * Freya Studio util module
--//

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...
  
Vulcan = require script.Parent.Util.Vulcan

Controller = with {
    InstallPackage: Hybrid (Package, Version) ->
      -- Install a package.
      s, err = pcall Vulcan.InstallPackage, Package, Version
      return error "[Error][Freya Studio] Unable to install package - '#{err}'" unless s
      print "[Info][Freya Studio] Successfully installed #{Package}"
    Update: ->
      -- Update Freya
      -- Come back later when you can determine whether Freya is beta/bleeding/etc
      -- Or if you decide not to use that model for Freya
      return require(480740831);
    UpdatePackage: Hybrid (Package, Version) ->
      -- Update a package.
      s, err = pcall Vulcan.UpdatePackage, Package, Version
      return error "[Error][Freya Studio] Unable to update package - '#{err}'" unless s
      print "[Info][Freya Studio] Succcessfully updated #{Package}"
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
    UninstallPackage: Hybrid (Package) ->
      -- Use the package uninstall script or use metadata
      s, err = pcall Vulcan.UninstallPackage, Package
      return error "[Error][Freya Studio] Unable to remove package - '#{err}'" unless s
      print "[Info][Freya Studio] Succcessfully uninstalled #{Package}"
    Uninstall: ->
      -- Uninstall Freya.
      return require(game.ServerStorage.Freya.vanish)!
  }
  .UpdateFreya = .Update
  .LoadUtil = .Load
  .UninstallFreya = .Uninstall

with getmetatable ni
  .__index = Controller
  .__tostring = -> "FreyaStudio Controller"
  .__metatable = "Locked Metatable: Freya"

return ni
