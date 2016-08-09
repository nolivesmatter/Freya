-- Valkyrie Admin framework, latching onto the Valkyrie Permissions

local Permissions = require(game.ServerStorage.Freya.Main):GetComponent "Permissions";
local Players = game:GetService "Players"

-- Set up Permissions
Permissions:CreatePermission("Admin.Command.ExampleCommand")

-- Create the Player Matcher
local getMatching do
  local wrapiter = function(t)
    local curr = 0;
    return function()
      curr = curr+1;
      return t[curr];
    end;
  end;
  getMatching = function(self, str)
    if str == 'me' then
      return wrapiter{self};
    elseif str == 'all' then
      return wrapiter(Players:GetPlayers())
    elseif str == 'other' or str == 'others' then
      local p = {};
      for i,v in pairs(Players:GetPlayers()) do
        if v ~= self then
          p[#p+1] = v;
        end;
      end
      return wrapiter(p);
    elseif str == 'random' then
      return wrapiter{Players:GetPlayers()[math.random(Players.NumPlayers)]}
    else
      -- Not matching a special group. Fun.
      -- Check if it matches a permissions group
      if Permissions:GetGroup(str) then
        -- We got a group. Magic.
        local p = {};
        local gp = Permissions.GetGroup(str).Users
        for i,v in pairs(Players:GetPlayers()) do
          if gp[v] then
            p[#p+1]=v;
          end;
        end;
        return wrapiter(p);
      else
        -- No group :c
        -- Look for Players
        local PlayerList = Players:GetPlayers();
        local currentPlayer;
        local bestMatch = 99;
        for i=1,#PlayerList do
          local v = PlayerList[i];
          local k,j = v.Name:find(str);
          if k and j and bestMatch > k then
            -- Match, and it's better than our last
            currentPlayer = v;
            bestMatch = k;
          end;
        end;
        return wrapiter{currentPlayer};
      end;
    end;
    return wrapiter{};
  end;
end;

-- Create the commands support
local CommandList = {};

-- Create the command runner
local function runCommand(as,cmd)
  cmdns = cmd:gsub('%s','')
  local cmdname = cmdns:match('^(%a+)')
  if not cmdname then return end;
  if not Permissions:GetUserPermission(as, "Admin.Command."..cmd) then return end;
  if CommandList[cmdname] then
    -- We got a valid command, guys
    local cmdf = CommandList[cmdname];
    local params = {};
    if cmdns:sub(-1,-1) == ')' then
      -- Probably got parameters
      for param in cmd:match('^[^(]*%((.+)%)%s*$'):gmatch('[^,]') do
        params[#params+1] = param:match('^%s*(.-)%s*$');
      end;
    end;
    cmdf(as,unpack(params));
  else return end;
end;

local clientAdmin = script.VAClient;

-- Bind the Player events
do
  local pebind = function(p)
    -- Bind the Chat commands
    p.Chatted:connect(function(str)
      if str:sub(1,2) == '#!' then
        runCommand(p,str:sub(3,#str));
      end;
    end)
    local ca = clientAdmin:Clone();
    ca.DoCommand.OnServerEvent:connect(runCommand);
    ca.Parent = p:WaitForChild("PlayerScripts");
  end
  game.Players.PlayerAdded:connect(pebind)
  for k,v in next, game.Players:GetPlayers() do pebind(v) end;
end

-- Create the API
local addCommand = function(name, command)
  assert(type(name) == 'string' and type(command) == 'function', "You need to supply (name, command)", 2);
  local newPermission = Permissions:CreatePermission("Admin.Command."..name);
  CommandList[name] = command;
  return newPermission;
end;

-- Schedule to build the defaults
spawn(function()
  for k,v in next, require(script.DefaultCommands) do
    addCommand(k,v)
  end
end)

-- Create the controller
local controller = newproxy(true);
local controllermt = getmetatable(controller);
local controllerclass = {};

local extract = function(...)
  if ... == controller then
    return select(2, ...);
  else
    return ...
  end
end

controllerclass.AddCommand = function(...) return addCommand(extract(...)) end;

controllerclass.RunCommand = function(...)
  local as, command = extract(...)
  assert(as and command, "You need to supply a Player to run the command as, and a command to run", 2);
  runCommand(as, command);
end;

controllerclass.GetMatching = function(...) return getMatching(extract(...)) end;

controllermt.__index = controllerclass;
controllermt.__metatable = "Locked metatable: Freya"
controllermt.__tostring = function() return "Admin controller" end;

return controller;
