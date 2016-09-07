local Util 					= {};
local Core 					= _G.Valkyrie;
local GetType				= Core:GetComponent "DataTypes";
local RunService = game:GetService"RunService";
local isLocal 				= RunService:IsStudio() and script:IsDescendantOf(game.Players) or RunService:IsClient();

local RenderStepped 		= RunService.RenderStepped;
local ewait = RenderStepped.wait;

function Util.GetRealType(Value)
	if type(Value) == "userdata" then
		return GetType(Value);
	end

	return type(Value);
end

function Util.CheckSingleType(Value, Type)
	if type(Type) ~= "string" then
		error("Your type must be a string!", 2);
	end

	return Util.GetRealType(Value) == Type;
end

function Util.AssertType(Name, Value, Type, IgnoreNil)
	if not (IgnoreNil and Value == nil) then
		assert(Util.CheckSingleType(Value, Type), string.format("%s needs to be a %s (%s given)", Name, Type, Util.GetRealType(Value)), 3);
	end
end

function Util.RunAsync(Runner,...)
	local ret;
	local listener = Instance.new("BoolValue");
	listener.Value = false;
	local Coroutine = coroutine.create(function(...)
		ret = {Runner(...)};
		listener.Value = true;
	end);
	coroutine.resume(Coroutine,...);
	return function()
		listener.Changed:wait();
		return unpack(ret);
	end
end

function Util.CopyMetatable(Object, Metatable)
	local ObjMetatable		= getmetatable(Object);
	for Name, Method in next, Metatable do
		ObjMetatable[Name] 	= Method;
	end
end

function Util.GetScreenResolution()
	return Core:GetOverlay().AbsoluteSize;
end

do
	local mt = {
 __index = {
  case = function(this, ...)
   local args = {...};
   return function(r)
    for i=1, #args do
     this.cases[args[i]] = r;
    end;
    return this;
   end;
  end;
  default = function(this,r)
   local v = this.cases[this.switch] or r;
   if type(v) == 'function' then
    return v(this.switch);
   else
    return v;
   end;
  end;
  eval = function(this)
   local v = this.cases[this.switch];
   if type(v) == 'function' then
    return v(this.switch);
   else
    return v;
   end;
  end;
 };
};
function Util.switch(obj)
 return setmetatable({switch = obj, cases = {}},mt);
end;
end;

local chainmeta = {
	__newindex = function(t,k,v) t._obj[k] = v; end;
	__index = function(t,k)
		return function(v)
			t._obj[k] = v;
			return t;
		end;
	end;
	__call = function(t)
		return t._obj;
	end;
}
function Util.Chain(obj)
	return setmetatable({_obj = obj},chainmeta);
end;

Util.isLocal = isLocal;

Util.wait = wait;
local tick = tick;
if isLocal then
	Util.Player = game.Players.LocalPlayer;
	Util.wait = function(n)
		if n then
			local i = 0;
			while i < n do
				i = i + ewait(RenderStepped);
			end;
			return i;
		else
			return ewait(RenderStepped);
		end
	end;
end;
Util.ewait = function(ev)
	local newewait;
	local now = tick();
	local r={ewait(ev)};
	return tick()-now, unpack(r)
end;
local yield = coroutine.yield;
Util.ywait = function(n)
	n = n or 0.029;
	local now = tick();
	local later = now+n;
	while tick() < later do
		yield();
	end;
	return tick() - now;
end;

return Util;
