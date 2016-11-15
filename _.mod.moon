--//
--// * Freya MainModule
--// | Provides access to controls for Freya, using the most up-to-date
--// | FreyaStudio module. Checks if Freya is installed or needs updating before
--// | returning the FreyaStudio module.
--//

local ^
local FreyaStudio, IsStudio, HttpEnabled, FreyaStudio

HttpService = with game\GetService "HttpService"
  IsStudio = pcall -> HttpEnabled = .HttpEnabled
  return error "The Freya MainModule must be required from the Studio command bar" unless IsStudio
  .HttpEnabled = true
JSONDecode = HttpService\JSONDecode

if not script\FindFirstChild "Version"
  with Instance.new "StringValue"
    .Name = "Version"
    .Value = script.GitMeta.HeadCommitID.Value\sub 1,8
    .Parent = script
if not script\FindFirstChild "PackageList"
  with Instance.new "ModuleScript"
    .Name = "PackageList"
    .Source = "return {}"
    .Parent = script

Freya = game.ServerStorage\FindFirstChild "Freya"
if Freya
  -- Check Freya version
  Version = Freya\FindFirstChild "Version"
  if Version and Version.Value != script.Version.Value
    --// Update Freya
    print "[Freya] Updating Freya to " .. script.Version.Value
    script.Core.PackageList\Destroy!
    Freya.PackageList.Parent = script
    Packages = require script.PackageList
    Hearth = require script.Core.Util.Hearth
    Locate = Hearth.Locate
    --// Preserve Packages
    for Package in *Packages
      print "[Freya] Preserving #{Package.Origin.Name}"
      Package.Resource.Parent = nil
    --// Update Freya
    require(script.unpack) script
    --// Recognise the new Freya
    Freya = game.ServerStorage.Freya
    --// Restore packages
    for Package in *Packages
      print "[Freya] Restoring #{Package.Origin.Name}"
      loc = Locate Package.Origin.Type
      new = loc\FindFirstChild Package.Resource.Name
      if new
        warn "[Freya] Installed package #{Package.Origin.Name} is provided by Freya."
        if Package.Origin.Force
          warn "[Freya] Retaining old version of #{Package.Origin.Name}"
          Package.Resource.Parent = loc
        else
          warn "[Freya] Upgrading to new version of #{Package.Origin.Name}. Storing old version in ServerStorage.Freya.UpgradeBin"
          Package.Resource.Parent = with Freya\FindFirstChild("UpgradeBin") or Instance.new "Folder"
            .Name = "UpgradeBin"
            .Parent = Freya
      else
        Package.Resource.Parent = loc

  FreyaStudio = Freya.FreyaStudio
else
  -- Install Freya!
  FreyaStudio = script.Core.FreyaStudio
  print "[Freya] Installing Freya " .. script.Version.Value
  require(script.unpack) script

-- Set the HttpService state back to the original
HttpService.HttpEnabled = HttpEnabled

return require FreyaStudio
