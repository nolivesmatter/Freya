local select = select;
local getmetatable,setmetatable = getmetatable,setmetatable;
local getfenv,setfenv = getfenv,setfenv;
local type = type;
local pairs = pairs;
local error = error;
local unpack = unpack;
local game = game;
local gs = game.IsA;
local pcall = pcall;
local newproxy = newproxy;
local rawget, rawset = rawget, rawset;
local http = game:GetService("HttpService");

local GlobalUnwrapper = {unwrapper = true; pairs = setmetatable({},{__mode = 'k'})};
local GlobalWrapper = {unwrapper = false; pairs = setmetatable({},{__mode = 'v'})};
GlobalWrapper.ref = GlobalWrapper.pairs;
GlobalUnwrapper.ref = GlobalUnwrapper.pairs;

local empty = newproxy(false)
local pack = function(...)
	return {n=select('#',...),...}
end;
local echo = function(...)
	return ...
end;
local echoerror = function(e,s)
	s = s or 1;
	error(e,s+1);
end;

local convert do
	local ignorerec = {};
	local convertAll = function(from, to, this, ...)
		local returns = pack(...);
		for i=1, returns.n do
			returns[i] = convert(from, to, this, returns[i]);
		end;
		return unpack(returns, 1, returns.n);
	end;
	convert = function(from, to, this, value)
		local ret = to.pairs[value];
		if ret ~= nil then
			if ret == empty then
				return nil;
			else
				if type(value) == 'table' and type(ret) == 'table' then
					ignorerec[value] = true;
					for k,v in pairs(value) do
						if not ignorerec[v] then
							pcall(rawset, ret, convert(from, to, this, k), convert(from, to, this, v));
						end;
					end;
					ignorerec[value] = nil;
				elseif type(ret) == 'userdata' then
					if pcall(gs, value, 'Instance') then
						getmetatable(ret).__index = this.imt.__index;
					end;
				end;
				return ret;
			end;
		end;
		if from.unwrapper and from.pairs[value] and this.useStackedWrappers == false then
			return value
		end;
		if to.unwrapper then
			if not this.convertFullBidirectional then
				return value
			else
				if from.pairs[value] and this.useContextInversion then
					return value;
				end
			end
		end;
		local type = type(value);
		if type == 'function' then
			ret = function(...)
				local args = pack(convertAll(to, from, this, ...))
				local returns = pack(pcall(
					function(...) return value(...) end,
					unpack(args,1,args.n) -- Ugly.
				));
				if returns[1] then
					if this.fixTables then
						convertAll(from, to, this, unpack(args,1,args.n));
					end;
					return convertAll(from, to, this, unpack(returns, 2, returns.n));
				else
					echoerror(returns[2], 2);
				end;
			end;
			to.pairs[value] = ret;
			from.pairs[ret] = value;
			return ret;
		elseif type == 'table' then
			ret = {};
			to.pairs[value] = ret;
			from.pairs[ret] = value;
			for k,v in pairs(value) do
				ret[convert(from, to, this, k)] = convert(from, to, this, v);
			end;
			if from.unwrapper then
				setmetatable(ret,this.mt);
			else
				pcall(setmetatable, value, this.mt);
			end;
			return ret;
		elseif type == 'userdata' then
			if this.useFullConversion == false and to.unwrapper then
				return value
			end;
			ret = newproxy(true);
			local mt = getmetatable(ret);
			if from.unwrapper then
				for event, metamethod in pairs(this.mt) do
					mt[event] = metamethod;
				end;
				if this.TypeIdentities[value] then
					for e,m in pairs(this.umt[this.TypeIdentities[value]]) do
						mt[e] = m;
					end
				elseif pcall(gs,value,'Instance') then
					for e,m in pairs(this.imt) do
						mt[e] = m;
					end;
				else
					for t,v in pairs(this.Overrides.Types) do
						if this.TypeChecks[t] and pcall(this.TypeChecks[t],value) then
							for e,m in pairs(v) do
								mt[e] = m;
							end
							break;
						end;
					end
				end
			else
				for event, metamethod in pairs(this.inversemt) do
					mt[event] = metamethod;
				end;
			end;
			from.pairs[ret] = value;
			to.pairs[value] = ret;
			return ret
		else
			return value;
		end;
	end;
end;

local defaultmt = {
	__len       = function(a) return #echo(a) end;
	__unm       = function(a) return -echo(a) end;
	__add       = function(a,b) return echo(a)+echo(b) end;
	__sub       = function(a,b) return echo(a)-echo(b) end;
	__mul       = function(a,b) return echo(a)*echo(b) end;
	__div       = function(a,b) return echo(a)/echo(b) end;
	__mod       = function(a,b) return echo(a)%echo(b) end;
	__pow       = function(a,b) return echo(a)^echo(b) end;
	__lt        = function(a,b) return echo(a) < echo(b) end;
	__eq        = function(a,b) return echo(a) == echo(b) end;
	__le        = function(a,b) return echo(a) <= echo(b) end;
	__concat    = function(a,b) return echo(a)..echo(b) end;
	__call      = function(t,...) return echo(t)(...) end;
	__tostring  = tostring;
	__index     = function(t, k) return echo(t)[k] end;
	__newindex  = function(t, k, v) echo(t)[k] = v end;
}

local defaultimt do
	local current = setmetatable({},{__mode = 'k'});
	defaultimt = {
		__len = function(a) return #a:GetChildren() end;
		__call = function(a,_,n)
			if not current[a] then current[a] = a:GetChildren() end;
			local k,v = next(current[a], n);
			if not k then current[a] = nil; end;
			return k,v
		end;
	}
end

local WrapperClass = {};

function WrapperClass:wrap(val)
	return convert(self.unwrapper,self.wrapper,self,val);
end;

function WrapperClass:mod(from, to)
	local substitute;
	if to == nil then
		substitute = empty;
	else
		substitute = convert(self.unwrapper,self.wrapper,self,to);
		self.unwrapper.pairs[substitute] = to;
	end
	self.wrapper.pairs[from] = substitute;
	self.wrapper.pairs[substitute] = substitute;
end;

function WrapperClass:Override(thing)
	return setmetatable({
		Instance = function(_,n)
			assert(type(n) == 'table', "Not a table? You're doing it wrong.", 2);
			local newer = self.Overrides.Instance[thing] or {};
			for k,v in pairs(n) do
				newer[k] = convert(self.unwrapper,self.wrapper,self,v)
			end;
			self.Overrides.Instance[thing] = newer;
		end
	},{
		__call = function(_,n)
			assert(type(n) == 'table', "Not a table? You're doing it wrong.", 2);
			local newer = self.Overrides.Types[thing] or {};
			for e,m in pairs(n) do
				newer[e] = convert(self.unwrapper,self.wrapper,self,m);
			end;
			self.Overrides.Types[thing] = newer;
		end
	})
end;

function WrapperClass:GenExt(f)
	return convert(self.wrapper, self.unwrapper, self, f);
end;

function WrapperClass:OverrideGlobal(global)
	return function(override)
		local oldGlobal = self.Overrides.Globals[global] or getfenv(2)[global];
		local t,ot = type(override), type(oldGlobal);
		if t == 'table' then
			if ot == 'function' then
				setmetatable(override,{__call = function(_,...) oldGlobal(...) end});
				self.Overrides.Globals[global] = override;
			elseif ot == 'table' then
				for k,v in pairs(oldGlobal) do
					rawset(override,k,v);
				end;
				setmetatable(override,{__index = oldGlobal});
				self.Overrides.Globals[global] = override;
			elseif ot == 'userdata' then
				setmetatable(override,{
					__call = function(_,...) return oldGlobal(...) end;
					__index = function(_,k) return oldGlobal[k] end;
				});
				self.Overrides.Globals[global] = override;
			else
				self.Overrides.Globals[global] = override;
			end;
		elseif t == 'userdata' then
			local prox = newproxy(true);
			local mt = getmetatable(prox);
			for e,m in pairs(self.mt) do
				mt[e] = m;
			end;
			self.ulist.ref[prox] = override;
			self.wlist.ref[override] = prox;
			if ot == 'function' then
				mt.__call = function(_,...) return oldGlobal(...) end;
				self.Overrides.Globals[global] = override;
			elseif ot == 'table' or ot == 'userdata' then
				local oi = mt.__index;
				mt.__index = function(t,k) return oi(t,k) or oldGlobal[k] end;
				self.Overrides.Globals[global] = override;
			else
				self.Overrides.Globals[global] = override;
			end
		else
			self.Overrides.Globals[global] = override;
		end;
	end;
end;

function WrapperClass:unwrap(val)
	return convert(self.wlist,self.ulist,self,val);
end;

function WrapperClass:wrapAll(...)
	local r = pack(...);
	for i=1,r.n do
		r[i] = convert(self.ulist,self.wlist,self,r[i])
	end
	return unpack(r,1,r.n);
end;

function WrapperClass:unwrapAll(...)
	local r = pack(...);
	for i=1,r.n do
		r[i] = convert(self.wlist,self.ulist,self,r[i]);
	end;
	return unpack(r,1,r.n);
end;

WrapperClass._rawConvert = convert;

local TypeChecks do
	local tv2 = Vector2.new(0,0);
	local con = game.Changed.connect;
	local tsp = Instance.new("Part");
	local ud = UDim.new(0,0);
	local tui = Instance.new("ImageLabel");
	local BrickColor = BrickColor;
	TypeChecks = {
		Color3 = BrickColor.new;
		Vector2 = function(o) return tv2 + o end;
		Event = function(o) con(o,function()end):disconnect() end;
		Vector3 = function(o) tsp.Size = o end;
		UDim = function(o) return ud+o end;
		UDim2 = function(o) tui.Position = o end;
		BrickColor = function(o) tsp.BrickColor = o end;
	};
end;

local instancetable = http:JSONDecode(game.ReplicatedStorage:WaitForChild("Freya"):WaitForChild("InheritTable").Value);

local function newWrapper(private)
	local self = {};

	self.ulist = private and {unwrapper = true, ref = setmetatable({},{__mode = 'k'})} or GlobalUnwrapper;
	self.wlist = private and {unwrapper = false, ref = setmetatable({},{__mode = 'v'})} or GlobalWrapper;
	self.wlist.pairs = self.wlist.ref;
	self.ulist.pairs = self.ulist.ref;
	self.unwrapper = self.ulist;
	self.wrapper = self.wlist

	self.mt = {};
	self.imt = {};
	self.umt = {};
	self.inversemt = {};

	self.Overrides = {
		Globals = {};
		Instance = {};
		Types = {};
	}

	do local iOverrides = self.Overrides.Instance;
		for k,v in next, instancetable do
			iOverrides[k] = setmetatable({},{__index = iOverrides[v]});
		end;
	end;

	self.useStackedWrappers = false;
	self.useFullConversion = false;
	self.convertFullBidirectional = true;
	self.useContextInversion = true;
	self.fixTables = false;

	self.genSeed = tick();

	self.TypeIdentities = _G.TypeIdentities or setmetatable({},{__mode = 'k'});
	self.TypeChecks = TypeChecks;

	for e,m in pairs(defaultmt) do
		self.mt[e] = convert(self.ulist,self.wlist,self,m);
	end
	for e,m in pairs(defaultmt) do
		self.inversemt[e] = convert(self.wlist,self.ulist,self,m);
	end;
	for e,m in pairs(defaultimt) do
		self.imt[e] = convert(self.ulist,self.wlist,self,m);
	end

	do
		local oni = self.mt.__newindex;
		self.mt.__newindex = function(...)
			if type(...) == 'table' then
				rawset(...);
			end
			oni(...);
		end
	end

	self.imt.__index = convert(self.ulist,self.wlist,self,function(t,k)
		local cn = t.ClassName;
		local iOverride = self.Overrides.Instance[cn];
		if iOverride and iOverride[k] then
			return iOverride[k];
		else
			local r = pack(xpcall(function() return t[k] end,echo));
			if r[1] then
				return r[2];
			else
				error(r[2], 2)
			end
		end;
	end)

	setmetatable(self,{__index = WrapperClass})

	local r = newproxy(true);
	local rmt = getmetatable(r);
	rmt.__index = self;
	rmt.__metatable = "Locked metatable: Freya Wrapper object";
	rmt.__call = WrapperClass.wrap;
	rmt.__tostring = function(_)
		return "Freya Wrapper Object: "..tostring(self):sub(7,-1);
	end;
	rmt.__len = function()
		return tick() - self.genSeed;
	end;
	rmt.__newindex = function(t,k,v)
		if t and k and v ~= nil then
			if self[k] and type(self[k]) == type(v) then self[k] = v; end;
		end;
	end;

	local e = getfenv(2);
	if e.getfenv then
		self:mod(e.getfenv, function(f)
			f = f or 1;
			if type(f) == "number" and f > 0  then
				f = f + 1;
			end
			local s, r = xpcall(function() return getfenv(f) end, echo);
			if not s then
				error(r, 2);
			else
				return r
			end
		end);
	end;

	for _, f in pairs({e.table.insert, e.table.remove, e.table.sort, e.rawset}) do
		self:mod(f, function(...)
			local r = pack(pcall(f,...));
			if r[1] then
				local t = ...
				local _t = convert(self.ulist, self.wlist, self, t);
				for k in pairs(_t) do
					rawset(_t, k, nil);
				end
				for k, v in pairs(t) do
					local _k = convert(self.ulist, self.wlist, self, k);
					local _v = convert(self.ulist, self.wlist, self, v);
					rawset(_t,_k,_v);
				end
				return unpack(r,2,r.n)
			else
				error(r[2],2);
			end
		end)
	end

	convert(self.unwrapper, self.wrapper, self, _G);

	return r;
end;

return newWrapper;
