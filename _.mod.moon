--//
--// * Freya MainModule
--// | Provides access to controls for Freya, using the most up-to-date
--// | FreyaStudio module. Checks if Freya is installed or needs updating before
--// | returning the FreyaStudio module.
--//

local ^

HttpService = with game\GetService("HttpService")
  HttpEnabled = .HttpEnabled
  IsStudio = pcall -> .HttpEnabled = not HttpEnabled
  return error "The Freya MainModule must be required from the Studio command bar" unless IsStudio
  .HttpEnabled = true
  GET = \GetAsync
  POST = \PostAsync
  JSONEncode = \JSONEncode
  JSONDecode = \JSONDecode

Freya = game.ServerStorage\FindFirstChild "Freya"
if Freya
  -- Check Freya version
  Version = Freya\FindFirstChild "Version"
  if Version and Version.Value != script.Version.Value
    -- Update Freya
    print "[Freya] Updating Freya to " .. script.Version.Value
    script.PackageList\Destroy!
    Freya.PackageList.Parent = script
    Packages = script.PackageList.Source:sub(5,-3):gsub('^%s+',''):gsub('%s+$','');
    require script.unpack script
    -- Reinstall packages
    FreyaStudio = require Freya.FreyaStudio
    Packages = JSONDecode Packages
    for v in *Packages
      FreyaStudio.Install v.Package, v.Version

  FreyaStudio = Freya.FreyaStudio
else
  -- Install Freya!
  FreyaStudio = script.Core.FreyaStudio
  print "[Freya] Installing Freya " .. script.Version.Value
  require script.unpack script

return require FreyaStudio
