-- DO IT SOME TIME
local newproxy = newproxy;
local unpack = unpack;
local getmetatable, setmetatable = getmetatable, setmetatable;
local type = type;
local pcall = pcall;
local tostring = tostring;
local getfenv = getfenv;
local setfenv = setfenv;
local table = table;

local null = newproxy(false);
local wlistg = {wrapper = true, ref = setmetatable({},{__mode = 'v'})};
local ulistg = {wrapper = false, ref = setmetatable({},{__mode = 'k'})};
local ftrack = setmetatable({},{__mode = 'k'});

local convert do
	local function All(this, from, to, ...)
		local ret = {...};
		local n = #ret;
		for i=1,n do
			ret[i] = convert(this, from, to, ret[i]);
		end;
		return unpack(ret)
	end;
	convert = function(this, from, to, obj)
		local v = to.ref[obj];
		if v ~= nil then
			if v == null then
				return nil;
			else
				-- Temporary, until the quirks are found.
				return v;
			end;
		end;
		if to.wrapper and from.ref[obj] then return obj end;
		-- May cause unexpected behaviour with functions. No alternative available.
		local type = type(obj);
		if type == 'function' then
			v = function(...)
				-- LiteLib becomes LazyLib,
				-- Not even worrying about proxying errors
				-- It makes no difference functionally, because the stack trace
				-- was going to be the same no matter what.
				return All(this, from, to, obj(All(this, to, from, ...)));
				-- WARNING: Returned tables are impure.
			end;
			from.ref[v] = obj;
			to.ref[obj] = v;
			ftrack[v] = true;
			return v;
		elseif type == 'table' then
			if to.wrapper then
				-- We're wrapping this table. This means it probably came from a
				-- function and it's probably in a wrapped environment.
				v = newproxy(true);
				local tmt = getmetatable(v);
				for e,m in next, this.mt do
					tmt[e] = m;
				end;
				from.ref[v] = obj;
				to.ref[obj] = v;
				return v;
				-- Did you notice we're cheating? Yes, cheating is good fun. The joy of
				-- cheating here is in that wrapped tables don't really need to be
				-- tables. They just need to pretend they're tables - The only thing
				-- that knows the difference is the metamethods. Slimy buggers.
			else
				-- We're unwrapping this table, but god help the poor bugger who made it
				-- because it's unwrapping with no target. The only way this can be
				-- true for a table is if it's hitting -1
				-- In which case, ouch.

				-- The fundamental issue here is now making sure that the table at -1
				-- isn't going to try and hit +1, and at the same time making sure that
				-- it doesn't die a horrible painful death of deathness.

				-- Why can't it hit +1? The contents would hit +2
				-- Why can't the contents hit +2? They're expected at +1
				-- What's the issue? Tables. Tables are the fucking issue.

				-- A nice solution would be to restructure how the conversion works.
				-- It could be modified so that it is just (this, levelmod, obj), but
				-- that doesn't really work all the time. It assumes something magically
				-- tracks which level obj came from. Which is nice and all but I don't
				-- know the implications.

				-- One issue is that it doesn't use the same graph style conversions
				-- that BaseLib uses. This means that you can't cheat with the wrap and
				-- unwrap pairs for objects the same way as you can with BaseLib because
				-- instead of giving it a loop, it gives it a limit.

				-- Fortunately, this issue is solved by making sure that nothing with
				-- an unwrap target can make a new wrap target. This is the same
				-- solution that prevents stuff at +1 from hitting anything higher.
				v = {};
				from.ref[v] = obj;
				to.ref[obj] = v;
				for k,nv in next, obj do
					v[convert(this,from,to,k)] = convert(this,from,to,nv);
				end;
				setmetatable(v, this.imt);
				pcall(setmetatable, obj, this.mt); -- It should be raw, but just incase.
				return v;
				-- But on a more serious note, not tracking what level everything is on
				-- does cause some serious issues.
		elseif type == 'userdata' then
			if from.wrapper and from.ref[obj] then return obj end;
			-- In the off chance that we're attempting to invert a userdata which
			-- already has a wrapper, we're going to bail. Normally we should bail
			-- right away with userdata, because some functions can malform it, but
			-- we're not going to just yet. Yet.
			v = newproxy(true);
			local tmt = getmetatable(v);
			for e,m in next, this.mt do
				tmt[e] = m;
			end;
			from.ref[v] = obj;
			to.ref[obj] = v;
			return v;
		else
			return obj;
		end;
	end;
end;

local defaultmt = {
	__len       = function(a) return #(a) end;
	__unm       = function(a) return -(a) end;
	__add       = function(a,b) return (a)+(b) end;
	__sub       = function(a,b) return (a)-(b) end;
	__mul       = function(a,b) return (a)*(b) end;
	__div       = function(a,b) return (a)/(b) end;
	__mod       = function(a,b) return (a)%(b) end;
	__pow       = function(a,b) return (a)^(b) end;
	__lt        = function(a,b) return (a) < (b) end;
	__eq        = function(a,b) return (a) == (b) end;
	__le        = function(a,b) return (a) <= (b) end;
	__concat    = function(a,b) return (a)..(b) end;
	__call      = function(t,...) return (t)(...) end;
	__tostring  = tostring;
	__index     = function(t, k) return (t)[k] end;
	__newindex  = function(t, k, v) (t)[k] = v end;
};

local WrapperClass = {};

function WrapperClass:wrap(o)
	return convert(self, self.ulist, self.wlist, o);
end;
function WrapperClass:wrapAll(...)
	local ret = {...};
	local n = #ret;
	for i=1,n do
		ret[i] = convert(self, self.ulist, self.wlist ret[i]);
	end;
	return unpack(ret)
end;

function WrapperClass:unwrap(o)
	return convert(self, self.wlist, self.ulist, o);
end;
function WrapperClass:unwrapAll(...)
	local ret = {...};
	local n = #ret;
	for i=1,n do
		ret[i] = convert(self, self.wlist, self.ulist ret[i]);
	end;
	return unpack(ret)
end;

function WrapperClass:mod(from, to)
	local sub;
	if to == nil then
		sub = null;
	else
		sub = convert(self, self.ulist, self.wlist, to);
		self.ulist.ref[sub] = to;
	end
	self.wlist.ref[from] = sub;
end;

function WrapperClass:modmt(event, metamethod)
	self.mt[event] = convert(self, self.ulist, self.wlist, metamethod);
	self.imt[event] = convert(self, self.wlist, self.ulist, metamethod);
end;

WrapperClass.convert = convert;

return function(priv)
	-- Create a new wrapper object!
	local self = {};

	self.mt = {};
	self.imt = {};
	self.ulist = priv and ulistg or {wrapper = false, ref = setmetatable({},{__mode = 'k'})};
	self.wlist = priv and wlistg or {wrapper = true, ref = setmetatable({},{__mode = 'v'})};

	-- No overrides right now.
	-- The cost of LiteLib being lite is in fact some API stuff being sacrificed
	-- for overall speed and efficiency boosts. This includes stuff like checking
	-- the datatypes of objects ahead of time and wrapping them separately, and
	-- instead providing the utility at a metamethod level.

	-- This improves performance in cases where the extra metamethod utility is
	-- not being used massively, but it does mean that the Instance member method
	-- modification API has temporarily vanished off of the face of the earth.

	--[[
		The implementation in this case is simple enough however, and involves
		modifying __index to check if the object is an Instance. This can be cached.
		If the object is an Instance, it can resolve back to the list of overrides
		for the Instance. Notice how there's not one right now? It's because making
		one means that the Instance metatable has to be reapplied every time it
		passes through a wrapper. This is an issue with global wrapper lists, and is
		the reason that the meaning of the constructor argument has been reversed
		for LiteLib. Does this cause issues? Yes. Does it stop excessively messing
		with Instances and unexpected behaviour from modded environments? Yes.

		All evils are evil.
	--]]

	-- It does however mean that tweaking these sorts of things becomes a job for
	-- the lesser of two evils. An API for assigning callbacks to the actual
	-- conversion may be implemented at a later date for library level performance
	-- tweaking where the metamethods get cluttered and heavy.

	for e,m in next, defaultmt do
		self.mt[e] = convert(self, self.ulist, self.wlist, m);
		self.imt[e] = convert(self, self.wlist, self.ulist, m);
		-- The worst part is that the order here is very important.
		-- Otherwise the wrapping would escape because it has an inversion.
		-- Again, this is a currently unavoidable issue with graph-based conversion,
		-- and is also present in BaseLib. No issues regarding this have cropped up
		-- from using BaseLib normally to date however.
	end;

	do
		local oni = self.mt.__newindex;
		self.mt.__newindex = function(...)
			if type(...) == 'table' then
				rawset(...);
			end
			oni(...);
		end
	end

	self.genSeed = tick();

	setmetatable(self,{__index = WrapperClass})

	local r = newproxy(true);
	local rmt = getmetatable(r);
	rmt.__index = self;
	rmt.__metatable = "Locked metatable: Freya LiteWrapper object";
	rmt.__call = WrapperClass.wrap;
	rmt.__tostring = function(_)
		return "Freya LiteWrapper Object: "..tostring(self):sub(7,-1);
	end;
	rmt.__len = function()
		return tick() - self.genSeed;
	end;

	self:mod(getfenv, function(f)
		f = f or 1;
		if type(f) == "number" and f > 0  then
			f = f + 1;
			local cnt, tru = 0,0;
			while tru < f do
				cnt = cnt+1;
				if not ftrack[setfenv(cnt, getfenv(cnt))] then
					tru = tru+1;
				end;
			end;
			return getfenv(cnt);
		else
			return getfenv(f);
		end;
	end);
	-- Modified version of the getfenv which ignores error handling but doesn't
	-- accidentally grab the function environment of a wrapper function.

	return r
end;
