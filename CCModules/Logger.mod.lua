local Logger            = {};
local Time              = _G.Valkyrie:GetComponent("Time");
local Settings          = _G.Valkyrie:GetSettings("Logger");

-- Since I don't know what order the user is going to use for the arguments, I'm doing this kind of formatting:
-- \1 is changed into the level
-- \2 is changed into the tag list
-- \3 is changed into the message
local MessageFormat     = "[\1 ~ \2] ~ \3";
Settings:RegisterSetting("MessageFormat", {
    get                 = function()
        return MessageFormat;
    end;
    set                 = function(New)
        assert(type(MessageFormat) == "string", "MessageFormat must be a string!");
        assert(New:find("\3"), "MessageFormat must contain a place for the message!");
        MessageFormat   = New;
    end;
});
-- This table's structure:
-- {[userdata] = Settings}
-- I don't want to prevent the garbage collection of the userdata.

local Settings          = setmetatable({}, {__mode = "k"});
--[[
    Plan:
    Settings = {
        [LoggerInstance1]   = {
            Tags            = {"Intent", "Core", "Valkyrie"},
            LastCondition   = true,
            Level           = "Fatal" or "Error" or "Warn" or "Info" or "Verbose" or "Debug",
            StopScriptFlag  = false
        },
        [LoggerInstance2]   = {
            ...
        },
        ...
    }
    So when the user does:
    local Tagged            = Logger:Tag("MyTag", "MyOtherTag");
    A new userdata will be created. The userdata's metatable will be set to the common metatable.
    Settings[userdata] will be {Tags = {"MyTag", "MyOtherTag"}}
    Next, when they do:
    local Conditioned       = Tagged:If(1 == 1);
    Another userdata will be created. The userdata's metatable will be set to the common metatable.
    Settings[userdata] will be {Tags = {"MyTag", "MyOtherTag"}, LastCondition = true}
    Then they can do:
    Conditioned:Warn("Hey! 1 equals 1!");
    This will send a warning that says "Hey! 1 equals 1!".
    They could also combine all this to one statement:
    Logger:Tag("MyTag", "MyOtherTag"):If(1 == 1):Warn("Hey! 1 equals 1!");
    They can also change the order of the first two calls.
    Optionally it is possible to pass no value to :Fatal()/:Error()/:Warn()/:Info()/:Verbose()/:Debug().
    In that case, yet another userdata will be created. The userdata's metatable will be set to the common metatable.
    Settings[userdata] will be {Tags = {"MyTag", "MyOtherTag"}, LastCondition = true, Level = ???}
    In that case, the user can call :Send(msg) on the userdata. Then, that will finally print the message.
    That API might be convenient if the user wants to do something like:
    local ErrorContext = Logger:Error();
    ...
    ...
    ...
    ErrorContext:Send("The monitor is going to sleep! PANIC!") -- AHHHHH
    And also, two more functions.
    Logger:SetStopScriptFlag(bool Flag)
    By default, Error() and Fatal() would stop the script when they would print something. The other functions would not.
    This function can be used to if they would. e.g.
    Logger:If(1 == 0):SetStopScriptFlag(false):Error("Math has failed but this script shall continue.");
    Logger:Assert(var(bool) Condition, string Message).
    It is an alias for:
    Logger:If(Condition):Tag("Assert"):Error(Message);
]]

local CommonMetatable;

local DefaultSettings   = {
    Tags                = {};
    LastCondition       = true;
    Level               = "Info";
    StopScriptFlag      = nil; -- nil = default; true = force stop; false = never stop
};

local function GenerateObject(Old)
    local NewObject     = newproxy(true);
    local Metatable     = getmetatable(NewObject);
    for MethodName, Method in next, CommonMetatable do -- ily Roblox >_>
        Metatable[MethodName] = Method;
    end

    Settings[NewObject] = Settings[Old] or DefaultSettings;

    return NewObject;
end

local function IsInTable(Table, Value)
    for Index, FoundValue in ipairs(Table) do
        if FoundValue == Value then
            return Index;
        end
    end
    return false;
end

local function FormatMessage(self, ...)
    local Formatted     = MessageFormat;
    Formatted           = Formatted:gsub("\1", Settings[self].Level);
    Formatted           = Formatted:gsub("\2", table.concat(Settings[self].Tags, ", "));
    Formatted           = Formatted:gsub("\3", (function(...) local a, b = {...}, ""; for i = 1, #a do b = b .. tostring(a[i]) .. "\t"; end return b:sub(1, b:len() - 1); end)(...)); -- Add the message last because it may contain \1 or \2
    return Formatted;
end

local TestService       = game:GetService("TestService");

local function HandlePrintingFunction(self, Level, ...)
    local Args  = {...};
    if #Args    == 0 then
        local New   = GenerateObject(self);
        Settings[New].Level     = Level;
        return New;
    end

    if not Settings[self].LastCondition then
        Settings[self].LastCondition = true;
        return self;
    end

    local FormattedMessage      = FormatMessage(self, ...);

    -- TODO: Handle stop script flag!
    if Level == "Debug" or Level == "Verbose" then
        -- TODO: Insert date!!
        local CurrentTick       = tick();
        print(Time.TimeFromSeconds(math.floor(CurrentTick)) .. "." .. string.format("%.3d", CurrentTick * 1000 % 1000) .. " - TestService: " .. FormattedMessage); -- Adding TestService here for consistency...
    elseif Level == "Info" then
        TestService:Message(FormattedMessage);
    elseif Level == "Warn" then
        TestService:Warn(false, FormattedMessage);
    elseif Level == "Error" or Level == "Fatal" then
        TestService:Error(FormattedMessage);
    end

    if Settings[self].StopScriptFlag == true or (Settings[self].StopScriptFlag == nil and (Level == "Error" or Level == "Fatal")) then
        error("Script stopped by Valkyrie Logger. Flag = " .. tostring(Settings[self].StopScriptFlag));
    end

    return self;
end

CommonMetatable         = {
    __index             = {
        Tag             = function(self, ...)
            local New   = GenerateObject(self);

            local Tags  = {...};
            for Index, Tag in next, Tags do
                if not IsInTable(Settings[New].Tags, Tag) then
                    table.insert(Settings[New].Tags, Tag);
                end
            end

            return New;
        end;
        UnTag           = function(self, ...)
            local New   = GenerateObject(self);

            local Tags  = {...};
            for Index, Tag in next, Tags do
                local ResultIndex   = IsInTable(Settings[New].Tags, Tag);
                if ResultIndex then
                    table.remove(Settings[New].Tags, ResultIndex);
                end
            end

            return New;
        end;
        If              = function(self, Condition)
            local New   = GenerateObject(self);

            Settings[New].LastCondition = not not Condition;

            return New;
        end;
        SetStopScriptFlag = function(self, Flag)
            local New   = GenerateObject(self);

            Settings[New].StopScriptFlag = Flag;

            return New;
        end;
        Send            = function(self, ...)
            HandlePrintingFunction(self, Settings[self].Level, ...);
        end;
        Assert          = function(self, Condition, ...)
            return self:Tag("Assert"):If(not Condition):Error(...);
        end;
    };
    __metatable         = _VERSION;
    __newindex          = function() game.TestService:Destroy(); end; -- Errors but idc I wanted something random
    __len               = function() return "Hello world!\3\56\245\99"; end; -- Somebody forgot a null terminator!
    __tostring          = function() return  "Valkyrie Logging Object"; end;
};

for _, Level in next, {"Debug", "Verbose", "Info", "Warn", "Error", "Fatal"} do
    CommonMetatable.__index[Level] = function(self, ...)
        return HandlePrintingFunction(self, Level, ...);
    end;
end

return GenerateObject(nil);
