local ReturningIntents = {};
local UserdataProxy = newproxy(true);
local IsClient;

local LocalIntent = Instance.new("BindableFunction");
local RemoteIntent;
local RemoteIntentBind = Instance.new("BindableFunction");
local RemoteListeners = {};
local LocalListeners = {};

if game:GetService("RunService"):IsClient() then
    IsClient = true;

    RemoteIntent = game.ReplicatedStorage:WaitForChild("ValkyrieRIntent");
    RemoteIntent.OnClientInvoke = function(Intent, ...)
        return RemoteIntentBind:Invoke(Intent, ...);
    end;
    function ReturningIntents:CallReturningIntentRemote(...)
        return RemoteIntent:InvokeServer(...);
    end;
else
    IsClient = false;

    RemoteIntent = game.ReplicatedStorage:FindFirstChild("ValkyrieRIntent");
    if not RemoteIntent then
        RemoteIntent = Instance.new("RemoteFunction", game.ReplicatedStorage);
        RemoteIntent.Name = "ValkyrieRIntent";
    end

    RemoteIntent.OnServerInvoke = function(p, Intent, ...)
        return RemoteIntentBind:Invoke(Intent, p, ...);
    end;

    function ReturningIntents:CallReturningIntentRemote(...) -- Might add some named args later
        local Arguments = {...};
        if Arguments[2] == 'All' then
            local ClientReturns = {};
            local Players = game.Players:GetAllPlayers();

            for i = 1, #Players do
                ClientReturns[Players[i].Name] = RemoteIntent:InvokeClient(Players[i], Arguments[1], unpack(Arguments, 3, #Arguments));
            end

            return ClientReturns;
        else
            return RemoteIntent:InvokeClient(Arguments[2], Arguments[1], unpack(Arguments, 3, #Arguments));
        end
    end
end

function ReturningIntents:RegisterReturningIntentRemote(Intent, Listener, Function)
    assert(Intent and type(Function) == 'function', "Invalid arguments", 2);

    local ThisIntentListeners = RemoteListeners[Intent];
    if ThisIntentListeners == nil then
        RemoteListeners[Intent] = {};
        ThisIntentListeners = RemoteListeners[Intent];
    end

    ThisIntentListeners[Listener] = Function;

    return function()
        RemoteListeners[Intent][Listener] = nil;
    end;
end

function ReturningIntents:RegisterReturningIntent(Intent, Listener, Function)
    assert(Intent and type(Function) == 'function', "Invalid arguments", 2);

    local ThisIntentListeners = LocalListeners[Intent];
    if ThisIntentListeners == nil then
        LocalListeners[Intent] = {};
        ThisIntentListeners = LocalListeners[Intent];
    end

    ThisIntentListeners[Listener] = Function;

    return function()
        LocalListeners[Intent][Listener] = nil;
    end;
end

function ReturningIntents:CallIntent(...)
    return LocalIntent:Invoke(...);
end

-- TODO
-- Possibly unify these functions

function LocalIntent.OnInvoke(Intent, ...) -- Reminder: "..." includes the player who sent the intent!!
    local Returns = {};

    for Name, Function in next, LocalListeners[Intent] do
        -- TODO
        -- Add a setting that prints each time a listener is about to be called
        -- Useful for end-user debugging to find out where their intents get stuck

        -- Might be a bit illogical, but will do for now
        local IntentReturn = {Function(...)};
        if #IntentReturn == 1 then
            Returns[Name] = IntentReturn[1];
        else
            Returns[Name] = IntentReturn;
        end
    end

    return Returns;
end

function RemoteIntentBind.OnInvoke(Intent, ...)
    local Returns = {};

    for Name, Function in next, RemoteListeners[Intent] do
        -- TODO
        -- Add a setting that prints each time a listener is about to be called
        -- Useful for end-user debugging to find out where their intents get stuck

        -- Might be a bit illogical, but will do for now
        local IntentReturn = {Function(...)};
        if #IntentReturn == 1 then
            Returns[Name] = IntentReturn[1];
        else
            Returns[Name] = IntentReturn;
        end
    end

    return Returns;
end

local Metatable = getmetatable(UserdataProxy);
Metatable.__index = ReturningIntents;
Metatable.__tostring = function()
    return "Valkyrie Returning Intents Component " .. (IsClient and "Client" or "Server");
end;
Metatable.__metatable = "I can't completely understand your intents...";

return UserdataProxy;
