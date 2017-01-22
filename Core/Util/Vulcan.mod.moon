--//
--// * Vulcan for Freya
--// | Package manager for Freya.
--//

ni = newproxy true

local ^
local InstallPackage, UpdatePackage, UninstallPackage, GetPackage

GitFetch = require(script.Parent.GitFetch)

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

PackageModule = script.Parent.Parent.PackageList
Packages = require PackageModule
Flush = ->
  PackageModule\Destroy!
  Buffer = {'return {'}
  for Package in *Packages
    Buffer[#Buffer+1] = "{
Resource = #{Package.Resource\GetFullName!\gsub '^([^%.%[]+)', 'game:GetService(\'%1\')'};
Origin = {
  Name = '#{Package.Origin.Name}';
  Type = '#{Package.Origin.Type}';
  Version = '#{Package.Origin.Version}';
}
};
"
  Buffer[#Buffer+1] = '}'
  PackageModule = with Instance.new("ModuleScript")
    .Source = table.concat Buffer, ''
    .Name = 'PackageList'
    .Parent = script.Parent.Parent

ResolveVersion = Hybrid (Version) ->
    i,j,branch,major,minor,patch = Version\find("^(%a[%w_-]*)%.(%d+)%.?(%d*)%.?(%d*)$")
    if i
      return {
        :branch
        major: tonumber major
        minor: tonumber minor
        patch: tonumber patch
      }
    else
      warn "Unusual version format."
      i,j,major,minor,patch = Version\find("^(%d+)%.?(%d*)%.?(%d*)$")
      if i
        return {
          major: tonumber major
          minor: tonumber minor
          patch: tonumber patch
        }
      else
        warn "Uncomparable version format. Assuming simply major version."
        major: major

ResolvePackage = Hybrid (Package, Version) ->
    switch type Package
      when 'number'
        -- AssetId for package.
        -- Versions are irrelevant.
        s, package = pcall -> game\GetService"InsertService"\LoadAsset Package
        return nil, "Unable to get package: #{package}" unless s
        s, package = pcall require, package
        return nil, "Unable to require package: #{package}" unless s
        return nil, "Package does not return a table" unless type(package) == 'table'
        return package
      when 'string'
        --  Determine protocol
        switch Package\match '^(%w+):'
          when 'github'
            warn "Without authentication, github requests will be heavily ratelimited."
            -- Github-based package.
            -- No extended support (Scripts only)
            repo = Package\gsub('^github:','')
            print "[Info][Freya Vulcan] Building #{repo} from Github."
            return GitFetch.GetPackage repo
          when 'freya'
            -- Freya-based package.
            -- No Freya APIs available for getting this data yet
            nil, "Freya repo APIs are not available yet"
          else
            -- Unknown protocol or no protocol.
            -- Assume Freya packages or Github packages.
            -- Check existing package repo list.
            nil, "No resolver available for #{Package}"
      when 'userdata'
        -- We'll assume it's a ModuleScript already. No version check.
        s, err = pcall require, Package
        return nil, "Unable to load package: #{err}" unless s
        return nil, "Package does not return a table" unless type(err) == 'table'
        return err
      when 'table'
        -- It's a boy! No version check.
        return Package
      else
        return nil, "Invalid package format."

CompareVersions = (v1, v2) -> -- To, from
  v1 = ResolveVersion v1.Version
  v2 = ResolveVersion v2.Version
  check = true
  if v1.branch and v2.branch ~= v1.branch
    check = false
  if v1.major
    if type(v1.major) == 'string'
      -- Uncomparable. Check equality.
      unless v1.major == v2.major
        check = false
    elseif v1.major > v2.major
      check = false
  if (v1.major == v2.major) and v1.minor and v2.minor and (v1.minor > v2.minor)
    check = false
    if (v1.minor == v2.minor) and v1.patch and v2.patch and (v1.patch > v2.patch)
      -- God forbid should you *need* a patch version.
      check = false
  check

Vulcan = {
  InstallPackage: Hybrid (Package, Version, force) ->
    -- Will invoke Update too, but also installs.
    apkg = Package
    -- Resolve the package
    Package, err = ResolvePackage Package, Version
    return error "[Error][Freya Vulcan] Unable to install package: \"#{err}\"", 2 unless Package
    with Package
      assert .Type,
        "[Error][Freya Vulcan] Package file does not include a valid type for the package.",
        2
      assert .Package,
        "[Error][Freya Vulcan] Package origin is invalid.",
        2
      unless .Name
        .Name = .Package.Name
      pkgloc = Locate .Type
      unless .Version
        warn "[Warn][Freya Vulcan] No package version. Treating the package as version 1"
        .Version = 'initial.0'
      if .Depends
        for dep in *.Depends
          -- Origin
          -- Name
          -- Version
          return error "[Error][Freya Vulcan] Malformed dependency list" unless dep.Name
          pak = GetPackage dep.Name
          if pak -- If it's installed
            if dep.Version
              -- Check that the version is alright
              clear = CompareVersions dep.Version, pak.Version
              unless clear -- Failed dep version
                warn "[Warn][Freya Vulcan] Incomplete dependency #{dep.Name} #{dep.Version}. Attempting to install."
                s, err = pcall InstallPackage dep.Origin or dep.Name, dep.Version
                return error "[Error][Freya Vulcan] Failed to install dependency #{dep.Name} #{dep.Version} because \"#{err}\"", 2 unless s
                print "[Info][Freya Vulcan] Installed dependency #{dep.Name} #{dep.Version}"
            else
              warn "[Warn][Freya Vulcan] dependency #{dep.Name} has no version specified. Be warned that it may not function."
              -- No need to install anything else.
          else
            -- Try to install the package.
            warn "[Warn][Freya Vulcan] Missing dependency #{dep.Name} #{dep.Version or 'latest'}. Attempting to install."
            s, err = pcall InstallPackage dep.Origin or dep.Name, dep.Version
            return error "[Error][Freya Vulcan] Failed to install dependency #{dep.Name} #{dep.Version} because \"#{err}\"", 2 unless s
            print "[Info][Freya Vulcan] Installed dependency #{dep.Name} #{dep.Version or 'latest'}"
      pkgloc = Locate .Type
      opkg = pkgloc\FindFirstChild .Package.Name
      if opkg
        return error "[Error][Freya Vulcan] Unable to install package because it already exists." unless force
        if .Update
          .Update opkg, .Package
          warn "[Warn][Freya Vulcan] Updating #{.Name or .Package.Name} before an install."
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
      sav = {
        Resource: .Package
        Origin:
          Name: .Name or .Package.Name
          Type: .Type
          Version: .Version
      }
      Packages[#Packages+1] = sav
      Flush!
      return sav
  UpdatePackage: Hybrid (Package, Version) ->
    apkg = Package
    -- Resolve the package
    Package, err = ResolvePackage Package, Version
    return error "[Error][Freya Vulcan] Unable to update package: \"#{err}\"", 2 unless Package
    with Package
      assert .Type,
        "[Error][Freya Vulcan] Package file does not include a valid type for the package.",
        2
      assert .Package,
        "[Error][Freya Vulcan] Package origin is invalid.",
        2
      unless .Name
        .Name = .Package.Name
      pkgloc = Locate .Type
      opkg = pkgloc\FindFirstChild .Package.Name
      assert opkg,
        "[Error][Freya Vulcan] Nothing to update from - Package was not already present",
        2
      if .Depends
        for dep in *.Depends
          -- Origin
          -- Name
          -- Version
          return error "[Error][Freya Vulcan] Malformed dependency list" unless dep.Name
          pak = GetPackage dep.Name
          if pak -- If it's installed
            if dep.Version
              -- Check that the version is alright
              clear = CompareVersions dep.Version, pak.Version
              unless clear -- Failed dep version
                warn "[Warn][Freya Vulcan] Incomplete dependency #{dep.Name} #{dep.Version}. Attempting to install."
                s, err = pcall InstallPackage dep.Origin or dep.Name, dep.Version
                return error "[Error][Freya Vulcan] Failed to install dependency #{dep.Name} #{dep.Version} because \"#{err}\"", 2 unless s
                print "[Info][Freya Vulcan] Installed dependency #{dep.Name} #{dep.Version}"
            else
              warn "[Warn][Freya Vulcan] dependency #{dep.Name} has no version specified. Be warned that it may not function."
              -- No need to install anything else.
          else
            -- Try to install the package.
            warn "[Warn][Freya Vulcan] Missing dependency #{dep.Name} #{dep.Version or 'latest'}. Attempting to install."
            s, err = pcall InstallPackage dep.Origin or dep.Name, dep.Version
            return error "[Error][Freya Vulcan] Failed to install dependency #{dep.Name} #{dep.Version} because \"#{err}\"", 2 unless s
            print "[Info][Freya Vulcan] Installed dependency #{dep.Name} #{dep.Version or 'latest'}"
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
      sav = {
        Resource: .Package
        Origin:
          Name: .Name or .Package.Name
          Type: .Type
          Version: .Version
      }
      for pak in *Packages
        if pak.Origin.Name == sav.Origin.Name
          pak.Resource = sav.Resource
          sav = pak
          break
      Flush!
      return sav
  UninstallPackage: Hybrid (Package) ->
    apkg = Package
    -- Resolve the package
    Package, err = ResolvePackage Package
    return error "[Error][Freya Vulcan] Unable to uninstall package: #{err}", 2 unless Package
    with Package
      assert .Type,
        "[Error][Freya Vulcan] Package file does not include a valid type for the package.",
        2
      assert .Package,
        "[Error][Freya Vulcan] Package origin is invalid.",
        2
      unless .Name
        .Name = .Package.Name
      pkgloc = Locate .Type
      ipkgloc = Locate .Type
      ipkg = ipkgloc\FindFirstChild .Name
      assert ipkg,
        "[Error][Freya Vulcan] Package could not be located",
        2
      if .Uninstall then .Uninstall ipkg
      ipkg\Destroy!
      dest = false
      for i=1, #Packages
        v = Packages[i]
        if dest
          Packages[i-1] = v
          Packages[i] = nil
        elseif v.Origin.Name == (.Name or .Package.Name)
          dest = true
          Packages[i] = nil
      Flush!
  Locate: Hybrid Locate
  Flush: Hybrid Flush
  GetPackage: Hybrid (PackageName) ->
    for Package in *Packages
      return Package if Package.Origin.Name == PackageName
  :ResolveVersion
  :Packages
  :ResolvePackage
}

{:InstallPackage, :UninstallPackage, :UpdatePackage, :GetPackage} = Vulcan

with getmetatable ni
  .__index = Vulcan
  .__metatable = "Locked metatable: Freya Vulcan"
  .__tostring = => "Freya Vulcan"

return ni
