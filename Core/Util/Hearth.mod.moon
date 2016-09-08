--//
--// * Hearth for Freya
--// | Package manager for Freya.
--//

ni = newproxy true

Hybrid = (f) -> (...) ->
  return f select 2, ... if ... == ni else f ...

Hearth = {
  InstallPackage: Hybrid (Package) ->
    apkg = Package
    -- Verify the Package is a proper package
    if type(Package) == 'userdata' and 
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
      unless .Version
        warn "No package version. Treating the package as version 1"
        .Version = 1
  UninstallPackage: Hybrid (Package) ->
    
}

with getmetatable ni
  .__index = Hearth
  .__metatable = "Locked metatable: Freya Hearth"
  .__tostring = => "Freya Hearth"

return ni
