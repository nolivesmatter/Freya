--//
--// * Unpack for Freya:
--// | Provides all the code for installing Freya to a place by unpacking all
--// | of various core components to their respective locations in the game.
--//

Clear = (Location, Name) ->
  obj = Location\FindFirstChild Name
  if obj
    print "[Freya] Cleaning", obj\GetFullName!
    obj\Destroy!

=>
  -- ReplicatedFirst
  Clear game.ReplicatedFirst, "Freya"
  RFFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ReplicatedFirst
  with Instance.new "Folder"
    .Name = "FreyaUserscripts"
    .Parent = game.ReplicatedFirst
  print "[Freya] Unpacking ReplicatedFirst:"
  for v in *@Core.ReplicatedFirst\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = RFFreya
    if v\IsA "Script"
      v.Disabled = true
      with Instance.new "BoolValue"
        .Name = "Enabled"
        .Value = false
        .Parent = v

  -- ServerScriptService
  Clear game.ServerScriptService, "Freya"
  SSSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ServerScriptService
  with Instance.new "Folder"
    .Name = "FreyaUserscripts"
    .Parent = game.ServerScriptService
  print "[Freya] Unpacking ServerScriptService:"
  for v in *@Core.ServerScriptService\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = SSSFreya
    if v\IsA "Script"
      v.Disabled = true
      with Instance.new "BoolValue"
        .Name = "Enabled"
        .Value = false
        .Parent = v

  -- StarterPlayer
  -- | StarterPlayerScripts
  Clear game.StarterPlayer.StarterPlayerScripts, "Freya"
  SPSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.StarterPlayer.StarterPlayerScripts
  with Instance.new "Folder"
    .Name = "FreyaUserscripts"
    .Parent = game.StarterPlayer.StarterPlayerScripts
  print "[Freya] Unpacking StarterPlayerScripts:"
  for v in *@Core.StarterPlayerScripts\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = SPSFreya
    if v\IsA "Script"
      v.Disabled = true
      with Instance.new "BoolValue"
        .Name = "Enabled"
        .Value = false
        .Parent = v

  -- Components
  -- | Server
  Clear game.ServerStorage, "Freya"
  SSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ServerStorage
  SSComponents = with Instance.new "Folder"
    .Name = "Components"
    .Parent = SSFreya
  print "[Freya] Unpacking Server Components:"
  for v in *@Components.Server\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = SSComponents
  -- | Client
  Clear game.ReplicatedStorage, "Freya"
  RSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ReplicatedStorage
  RSComponents = with Instance.new "Folder"
    .Name = "Components"
    .Parent = RSFreya
  RSComponentsC = with Instance.new "Folder"
    .Name = "Client"
    .Parent = RSComponents
  print "[Freya] Unpacking Client Components:"
  for v in *@Components.Client\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = RSComponentsC
  -- | Shared
  RSComponentsS = with Instance.new "Folder"
    .Name = "Shared"
    .Parent = RSComponents
  print "[Freya] Unpacking Shared Components:"
  for v in *@Components.Shared\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = RSComponentsS

  -- Libraries
  RSLibraries = with Instance.new "Folder"
    .Name = "Libraries"
    .Parent = RSFreya
  print "[Freya] Unpacking Libraries:"
  for v in *@Libraries\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = RSLibraries

  -- LiteLibraries
  RSLiteLibraries = with Instance.new "Folder"
    .Name = "LiteLibraries"
    .Parent = RSFreya
  print "[Freya] Unpacking LiteLibraries:"
  for v in *@LiteLibraries\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = RSLiteLibraries

  -- Core
  SSUtil = with Instance.new "Folder"
    .Name = "Util"
    .Parent = SSFreya
  print "[Freya] Unpacking Core Util"
  for v in *@Core.Util\GetChildren!
    print "[Freya] *", v.Name
    v.Parent = SSUtil
  RSCore = with Instance.new "Folder"
    .Name = "Core"
    .Parent = RSFreya
  print "[Freya] Unpacking Core LiteLib"
  @Core.LiteLib.Parent = RSCore
  print "[Freya] Unpacking Core BaseLib"
  @Core.BaseLib.Parent = RSCore
  print "[Freya] Unpacking FreyaStudio"
  @Core.FreyaStudio.Parent = SSFreya
  print "[Freya] Unpacking Freya Server"
  with @Core.MainServer
    .Name = "Main"
    .Parent = SSFreya
  print "[Freya] Unpacking Freya Client"
  with @Core.MainClient
    .Name = "Main"
    .Parent = RSFreya
  @Core.InitServer.Parent = SSSFreya
  @Core.InitClient.Parent = RFFreya
  @Core.PackageList.Parent = SSFreya
  Clear RSFreya, "Intent"
  print "[Freya] Creating Freya Intent RemoteEvent"
  with Instance.new "RemoteEvent"
    .Name = "Intent"
    .Parent = RSFreya
  @Version.Parent = SSFreya
  @vanish.Parent = SSFreya
  print "[Freya] Finished unpacking Freya"
