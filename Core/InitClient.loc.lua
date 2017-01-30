--//
--// * Init script for Freya Client
--// | Make sure everything actually loads
--//

-- Sort out ReplicatedFirst
-- -1 is for Freya-async. They'll get Freya themselves via Freya.Main
wait(1); -- I just want to hope that'll allow me to make sure everything is in.
for k,v in next, script.Parent:GetChildren() do
  if v ~= script then
    if v:IsA("LocalScript") and v.Enabled.Value then
      if v:FindFirstChild("LoadOrder") and v.LoadOrder.Value == -1 then
        v.Disabled = false;
      end
    end
  end
end
for k,v in next, game.ReplicatedFirst:WaitForChild("FreyaUserscripts"):GetChildren() do
  if v:IsA("LocalScript") and v.Enabled.Value then
    if v:FindFirstChild("LoadOrder") and v.LoadOrder.Value == -1 then
      v.Disabled = false;
    end
  end
end

-- Get our Freya Main
local Freya = require(game.ReplicatedStorage:WaitForChild("Freya"):WaitForChild("Main"));

-- ReplicatedFirst, after Freya exists.
local rflist = {}
for k,v in next, script.Parent:GetChildren() do
  if v ~= script then
    if v:IsA("LocalScript") and v.Enabled.Value then
      if v:FindFirstChild("LoadOrder") and v.LoadOrder.Value == -1 then else
        -- Lazy negation
        rflist[#rflist+1] = v;
      end
    end
  end
end
for k,v in next, game.ReplicatedFirst.FreyaUserscripts:GetChildren() do
  if v:IsA("LocalScript") and v.Enabled.Value then
    if v:FindFirstChild("LoadOrder") and v.LoadOrder.Value == -1 then else
      -- Lazy negation
      rflist[#rflist+1] = v;
    end
  end
end
table.sort(rflist, function(a,b)
  local loada = a:FindFirstChild("LoadOrder")
  loada = loada and loada.Value or 1
  local loadb = b:FindFirstChild("LoadOrder")
  loadb = loadb and loadb.Value or 1
  return loada < loadb
end);
for i=1, #rflist do
  local v = rflist[i];
  local ready = v:FindFirstChild("Ready");
  v.Disabled = false;
  if ready then
    while not ready.Value do ready.Changed:wait() end
  end
end

-- Put it in _G
_G.Freya = Freya
_G.FreyaClient = Freya
