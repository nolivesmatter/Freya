local function pack(...)
  return {n=select('#',...),...};
end;

local Freya = require(game.ServerStorage.Freya.Main);

local API = Freya:GetComponent"Admin";
local Permissions = Freya:GetComponent"Permissions";

Permissions:CreatePermission("Admin.Target.Kill");

return {
  kill = function(as, ...)
    local p = pack(...);
    for i=1,p.n do
      for player in API.GetMatching(as, p[i]) do
        if player.Character and Permissions:GetUserPermission(player, "Admin.Target.Kill") ~= false then
          player.Character:BreakJoints();
        end;
      end
    end;
  end;
  tp = function(as, who, where)
    local p = API.GetMatching(as, where)();
    if (not p) or not (p.Character and p.Character:FindFirstChild("Torso")) then return end;
    for player in API.GetMatching(as, who) do
      if player.Character and player.Character:FindFirstChild("Torso") then
        player.Character.Torso.CFrame = p.Character.Torso;
      end
    end;
  end;
  kick = function(as, who)
    for player in API.GetMatching(as, who) do
      player:Kick();
    end;
  end;
  freeze = function(as, who)
    for player in API.GetMatching(as, who) do
      (player.Character or player.CharacterAdded:wait()):WaitForChild("Torso").Anchored = true;
    end;
  end;
  thaw = function(as, who)
    for player in API.GetMatching(as, who) do
      (player.Character or player.CharacterAdded:wait()):WaitForChild("Torso").Anchored = false;
    end;
  end;
}
