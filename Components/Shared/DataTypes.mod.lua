local cxitio = {};
local VComponents;
local r;
local next = next;
local setfenv = setfenv;
local assert = assert;

local customDatas = {};
local identityPairs = setmetatable({},{__mode = 'k'});

local extract = function(...)
	if (...) == r then
		return select(2,...)
	else
		return ...
	end
end;

local igetType do
	local TypeIdentities = setmetatable({},{__mode='k'});
	local workspace = workspace;
	local fpor = workspace.FindPartOnRay;
	local fpir3 = workspace.FindPartsInRegion3;
	local testComponent = Instance.new("Part");
	local testGui = Instance.new("ImageLabel");
	local etest = game.ChildAdded.connect;
	local junk = function()end;
	local Enum = Enum;
	local getItems = Enum.KeyCode.GetEnumItems;
	local enumTest = function(o) return assert(o == Enum or getItems(o),'') end;
	local UDim = UDim;
	local assert = assert;
	local next = next;
	local type = type;
	local pcall = pcall;
	local game = game;
	local pcall = pcall;
	local gs = game.GetService;
	local function checkud(o)
		return UDim.new(0,0) + o
	end;
	local function set(o,p,i)
		o[p] = i;
	end
	igetType = function(...)
		local o = extract(...);
		if TypeIdentities[o] or identityPairs[o] then
			return TypeIdentities[o] or identityPairs[o];
		end
		local t = type(o);
		if t ~= 'userdata' then return t end;
		if pcall(gs, game, o) then
			t = "Instance";
		elseif pcall(set, testComponent, "Position", o) then
			t = "Vector3";
		elseif pcall(set, testComponent, "CFrame", o) then
			t = "CFrame";
		elseif pcall(set, testGui, "BackgroundColor3", o) then
			t = "Color3";
		elseif pcall(set, testGui, "Size", o) then
			t = "UDim2";
		elseif pcall(set, testComponent, "BrickColor", o) then
			t = "BrickColor";
		elseif pcall(etest, o, junk) then
			t = "Event";
		elseif pcall(enumTest, o) then
			t = "Enum";
		elseif pcall(function() return assert(type(o.disconnect) == 'function' and o.connected ~= nil,'') end) then
			t = "Connection";
		elseif pcall(fpor, workspace, o) then
			t = "Ray";
		elseif pcall(fpir3, workspace, o) then
			t = "Region3";
		elseif pcall(checkud, o) then
			t = "UDim";
		elseif pcall(set, testGui, "ImageRectOffset", o) then
			t = "Vector2";
		end
		if t == 'userdata' then
			for k,v in next, customDatas do
				if pcall(v, o) then t = k; break; end;
			end;
		end;
		return t;
	end
end

cxitio.AddCheck = function(...)
	local data, check = extract(...);
	assert(type(data) == 'string', "You need to supply an identity name as #1",2);
	assert(type(check) == 'function', "You must supply a check as #2", 2);
	customDatas[data] = check;
end;
cxitio.RegisterType = function(...)
	local itype, name = extract(...);
	assert(itype, "You need to supply an identity to match", 2);
	assert(type(name) == 'string', "You need to supply a name for this identity", 2);
	identityPairs[itype] = name;
end;
cxitio.GetCheck = function(...)
	local data = extract(...);
	return customDatas[data];
end
cxitio.GetType = igetType;

r = newproxy(true);
local mt = getmetatable(r);
mt.__index = cxitio;
mt.__call = igetType;
mt.__metatable = "Locked metatable: Valkyrie";

_G.TypeIdentities = identityPairs;

setfenv(0,{});
setfenv(1,{});

for k,v in next,cxitio do
	setfenv(v,{});
end

return r;
