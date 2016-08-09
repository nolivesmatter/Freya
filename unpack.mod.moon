--//
--// * Unpack for Freya:
--// | Provides all the code for installing Freya to a place by unpacking all
--// | of various core components to their respective locations in the game.
--//

=>
  -- ReplicatedFirst
  RFFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ReplicatedFirst
  for v in *@Core.ReplicatedFirst\GetChildren!
    v.Parent = RFFreya

  -- ServerScriptService
  SSSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ServerScriptService
  for v in *@Core.ServerScriptService\GetChildren!
    v.Parent = SSSFreya

  -- StarterPlayer
  -- | StarterPlayerScripts
  SPSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.StarterPlayer.StarterPlayerScripts
  for v in *@Core.StarterPlayerScripts\GetChildren!
    v.Parent = SPSFreya

  -- Components
  -- | Server
  SSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ServerStorage
  SSComponents = with Instance.new "Folder"
    .Name = "Components"
    .Parent = SSFreya
  for v in *@Components.Server\GetChildren!
    v.Parent = SSComponents
  -- | Client
  RSFreya = with Instance.new "Folder"
    .Name = "Freya"
    .Parent = game.ReplicatedStorage
  RSComponents = with Instance.new "Folder"
    .Name = "Components"
    .Parent = RSFreya
  RSComponentsC = with Instance.new "Folder"
    .Name = "Client"
    .Parent = RSComponents
  for v in *@Components.Client\GetChildren!
    v.Parent = RSComponentsC
  -- | Shared
  RSComponentsS = with Instance.new "Folder"
    .Name = "Shared"
    .Parent = RSComponents
  for v in *@Components.Shared\GetChildren!
    v.Parent = RSComponentsS

  -- Libraries
  RSLibraries = with Instance.new "Folder"
    .Name = "Libraries"
    .Parent = RSFreya
  for v in *@Libraries\GetChildren!
    v.Parent = RSLibraries

  -- LiteLibraries
  RSLiteLibraries = with Instance.new "Folder"
    .Name = "LiteLibraries"
    .Parent = RSFreya
  for v in *@LiteLibraries\GetChildren!
    v.Parent = RSLiteLibraries

  -- Core
  SSUtil = with Instance.new "Folder"
    .Name = "Util"
    .Parent = SSFreya
  for v in *@Core.Util\GetChildren!
    v.Parent = SSUtil
  RSCore = with Instance.new "Folder"
    .Name = "Core"
    .Parent = RSFreya
  @Core.LiteLib.Parent = RSCore
  @Core.BaseLib.Parent = RSCore
  @Core.FreyaStudio.Parent = SSFreya
  with @Core.MainServer
    .Name = "Main"
    .Parent = SSFreya
  with @Core.MainClient
    .Name = "Main"
    .Parent = RSFreya
