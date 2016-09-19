--//
--// * Unpack for Freya:
--// | Provides all the code for uninstalling Freya
--//

Clear = (Location, Name) ->
  obj = Location\FindFirstChild Name
  if obj
    print "[Freya] Cleaning", obj\GetFullName
    obj\Destroy!

->
  -- TODO: Less lazy uninstall;
  -- Actually uninstall packages instead of just clearing Freya.
  Clear game.ReplicatedFirst, "Freya"
  Clear game.ServerStorage, "Freya"
  Clear game.ServerScriptService, "Freya"
  Clear game.StarterPlayer.StarterPlayerScripts, "Freya"
  Clear game.ReplicatedStorage, "Freya"
  print "
*| Vanished Freya from your game :(
*| To get Freya back, simply require it again
*| Your packages have not been saved.
" -- TODO: Save packages (Studio DS access?)
