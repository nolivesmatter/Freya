--//
--// * Freya Studio util module
--//

ni = newproxy true
Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...
  
Hearth = require game.ServerStorage.Freya.Util.Hearth

Controller = with {
    InstallPackage: Hybrid (Package, Version) ->
      -- Install a package.
      -- Check for type
      t = type Package
      switch t
        when 'number'
          -- AssetId for package.
          s, package = pcall -> game\GetService"InsertService"\LoadAsset Package
          return error "Unable to get package: #{package}" unless s
          s, err = pcall Hearth.InstallPackage, package
          if s
            print "Successfully installed package ##{Package}"
          else
            warn "Unable to install package: #{err}"
        when 'string'
          --  Determine protocol
          switch Package\match '^(%w):'
            when 'github'
              -- Github-based package.
              -- No extended support (Scripts only)
              -- Count the path
              switch select 2, Package\gsub('/', '')
                when 2
                  -- Repo is package
                when 3
                  -- Repo is package repo; Get defs from repo
                else
                  return warn "Invalid Github package protocol", 2
            when 'freya'
              -- Freya-based package.
              -- No Freya APIs available for getting this data yet
            else
              -- Unknown protocol or no protocol.
              -- Assume Freya packages or Github packages.
              -- Check existing package repo list.
        when 'userdata'
          -- We'll assume it's a ModuleScript already.
          s, err = pcall Hearth.InstallPackage, Package
          if s
            print "Successfully installed package #{Package}"
          else
            warn "Unable to install package: #{err}"
        when 'table'
          -- It's a boy! Or, a table. Close enough.
          s, err = pcall Hearth.InstallPackage, Package
          if s
            print "Successfully installed package #{Package.Name or Package.Package}"
          else
            warn "Unable to install package: #{err}"
        else
          error "That doesn't look like a package. Check the package format.", 2
    Update: ->
      -- Update Freya
      -- Come back later when you can determine whether Freya is beta/bleeding/etc
      -- Or if you decide not to use that model for Freya
      return nil
    UpdatePackage: Hybrid (Package) ->
      -- Update a package.
      t = type Package
      switch t
        when 'number'
          -- AssetId for package.
          s, package = pcall -> game\GetService"InsertService"\LoadAsset Package
          return error "Unable to get package: #{package}" unless s
          s, err = pcall Hearth.UpdatePackage, package
          if s
            print "Successfully updated package ##{Package}"
          else
            warn "Unable to update package: #{err}"
        when 'string'
          --  Determine protocol
          switch Package\match '^(%w):'
            when 'github'
              -- Github-based package.
              -- No extended support (Scripts only)
              -- Count the path
              switch select 2, Package\gsub('/', '')
                when 2
                  -- Repo is package
                when 3
                  -- Repo is package repo; Get defs from repo
                else
                  return warn "Invalid Github package protocol", 2
            when 'freya'
              -- Freya-based package.
              -- No Freya APIs available for getting this data yet
            else
              -- Unknown protocol or no protocol.
              -- Assume Freya packages or Github packages.
              -- Check existing package repo list.
        when 'userdata'
          -- We'll assume it's a ModuleScript already.
          s, err = pcall Hearth.UpdatePackage, package
          if s
            print "Successfully updated package #{Package}"
          else
            warn "Unable to update package: #{err}"
        when 'table'
          -- It's a boy! Or, a table. Close enough.
          s, err = pcall Hearth.UpdatePackage, Package
          if s
            print "Successfully updated package #{Package.Name or Package.Package}"
          else
            warn "Unable to update package: #{err}"
        else
          error "That doesn't look like a package. Check the package format.", 2
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
      t = type Package
      switch t
        when 'number'
          -- AssetId for package.
          s, package = pcall -> game\GetService"InsertService"\LoadAsset Package
          return error "Unable to get package: #{package}" unless s
          s, err = pcall Hearth.UninstallPackage, package
          if s
            print "Successfully removed package ##{Package}"
          else
            warn "Unable to remove package: #{err}"
        when 'string'
          --  Determine protocol
          switch Package\match '^(%w):'
            when 'github'
              -- Github-based package.
              -- Only metadata and uninstall needed
              -- Count the path
              switch select 2, Package\gsub('/', '')
                when 2
                  -- Repo is package
                when 3
                  -- Repo is package repo; Get defs from repo
                else
                  return warn "Invalid Github package protocol", 2
            when 'freya'
              -- Freya-based package.
              -- No Freya APIs available for getting this data yet
            else
              -- Unknown protocol or no protocol.
              -- Assume Freya packages or Github packages.
              -- Check existing package repo list.
        when 'userdata'
          -- We'll assume it's a ModuleScript already.
          s, err = pcall Hearth.UninstallPackage, Package
          if s
            print "Successfully removed package #{Package}"
          else
            warn "Unable to remove package: #{err}"
        when 'table'
          -- It's a boy! Or, a table. Close enough.
          s, err = pcall Hearth.UninstallPackage, Package
          if s
            print "Successfully removed package #{Package.Name or Package.Package}"
          else
            warn "Unable to removed package: #{err}"
        else
          error "That doesn't look like a package. Check the package format.", 2
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
