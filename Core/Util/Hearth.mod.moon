--//
--// * Hearth for Freya
--// | Package manager for Freya.
--//

ni = newproxy true

Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Locate = (Type) ->
  return switch Type
    when 'ServerScript' then game.ServerScriptService.Freya
    when 'PlayerScript' then game.StarterPlayer.StarterPlayerScripts.Freya
    when 'ReplicatedFirst' then game.ReplicatedFirst.Freya
    when 'SharedComponent' then game.ReplicatedStorage.Freya.Components.Shared
    when 'ClientComponent' then game.ReplicatedStorage.Freya.Components.Client
    when 'ServerComponent' then game.ServerStorage.Freya.Components
    when 'Library' then game.ReplicatedStorage.Freya.Libraries
    when 'LiteLibrary' then game.ReplicatedStorage.Freya.LiteLibraries
    when 'Util' then game.ServerStorage.Freya.Util
    else error "Invalid Type for package!", 3

Hearth = {
  InstallPackage: Hybrid (Package) ->
    apkg = Package
    -- Verify the Package is a proper package
    if type(Package) == 'userdata'
      Package = require Package -- Assume ModuleScript.
      -- God forbid should it be anything else.
    if type(Package) ~= 'table'
      error "Invalid package file for Hearth!", 2
    with Package
      assert .Type,
        "Package file does not include a valid type for the package.",
        2
      unless .Package
        assert .Name,
          "Package has no name or package origin.",
          2
        .Package = apkg\FindFirstChild Name
        assert .Package,
          "Package origin is invalid.",
          2
      unless .Version
        warn "No package version. Treating the package as version 1"
        .Version = 1
      pkgloc = Locate .Type
      opkg = pkgloc\FindFirstChild .Package.Name
      if opkg
        if .Update then .Update opkg, .Package
        opkg\Destroy!
      .Package.Parent = pkgloc
      if .Install then .Install .Package
      if .Package\IsA "Script"
        -- Sort out other package metadata for Scripts
        pak = .Package
        if .LoadOrder
          lo = .LoadOrder
          with Instance.new "IntValue"
            .Name = "LoadOrder"
            .Value = lo
            .Parent = pak
  UpdatePackage: Hybrid (Package) ->
    apkg = Package
    -- Verify the Package is a proper package
    if type(Package) == 'userdata'
      Package = require Package -- Assume ModuleScript.
      -- God forbid should it be anything else.
    if type(Package) ~= 'table'
      error "Invalid package file for Hearth!", 2
    with Package
      assert .Type,
        "Package file does not include a valid type for the package.",
        2
      unless .Package
        assert .Name,
          "Package has no name or package origin.",
          2
        .Package = apkg\FindFirstChild Name
        assert .Package,
          "Package origin is invalid.",
          2
        pkgloc = Locate .Type
        opkg = pkgloc\FindFirstChild .Package.Name
        assert opkg,
          "Nothing to update from - Package was not already present",
          2
        if .Update then .Update opkg, .Package
        opkg\Destroy!
        .Package.Parent = pkgloc
        if .Package\IsA "Script"
        -- Sort out other package metadata for Scripts
          pak = .Package
          if .LoadOrder
            lo = .LoadOrder
            with Instance.new "IntValue"
              .Name = "LoadOrder"
              .Value = lo
              .Parent = pak
  UninstallPackage: Hybrid (Package) ->
    apkg = Package
    -- Verify the Package is a proper package
    if type(Package) == 'userdata'
      Package = require Package -- Assume ModuleScript.
      -- God forbid should it be anything else.
    if type(Package) ~= 'table'
      error "Invalid package file for Hearth!", 2
    with Package
      assert .Type,
        "Package file does not include a valid type for the package.",
        2
      unless .Name
        assert .Package,
          "Package has no name or package origin.",
          2
        .Name = .Package.Name
        assert .Name ~= '',
          "Package origin is invalid.",
          2
      ipkgloc = Locate .Type
      ipkg = ipkgloc\FindFirstChild .Name
      assert ipkg,
        "Package could not be located",
        2
      if .Uninstall then .Uninstall ipkg
      ipkg\Destroy!
}

with getmetatable ni
  .__index = Hearth
  .__metatable = "Locked metatable: Freya Hearth"
  .__tostring = => "Freya Hearth"

return ni
