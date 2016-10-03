--//
--// * Init script for Freya Server
--// | Make sure everything actually loads
--//

-- Enable all in StarterPlayerScripts
for k,v in next, game.StarterPlayer.StarterPlayerScripts.Freya:GetChildren() do
  if v ~= script then
    if v.Enabled.Value then
      v.Disabled = false
    end
  end
end

-- Get our Freya Main
local Freya = require(game.ServerStorage.Freya.Main);

-- Put it in _G
_G.Freya = Freya
_G.FreyaServer = Freya

-- Load everything in ServerScriptService
-- Respect load orders
local loadtable = {};
for k,v in next, script.Parent:GetChildren() do
  if v ~= script then
    if v.Enabled.Value then
      loadtable[#loadtable+1] = v;
    end
  end
end
for k,v in next, game.ServerScriptService.FreyaUserscripts:GetChildren() do
  if v:FindFirstChild("Enabled") and v.Enabled.Value then
    loadtable[#loadtable+1] = v;
  end
end
table.sort(loadtable, function(a,b)
  local loada = a:FindFirstChild("LoadOrder")
  loada = loada and loada.Value or 1
  local loadb = b:FindFirstChild("LoadOrder")
  loadb = loadb and loadb.Value or 1
  return loada < loadb
end);
for i=1, #loadtable do
  local v = loadtable[i];
  local ready = v:FindFirstChild("Ready");
  v.Disabled = false;
  if ready then
    while not ready.Value do ready.Changed:wait() end
  end
end
