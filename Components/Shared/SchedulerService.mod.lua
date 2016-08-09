-- Scheduling functions for a duration over an interval
local cxitio = {};
local r = newproxy(true);
local mt = getmetatable(r);

mt.__index			= cxitio;
mt.__metatable	= {__index = 'Nice try bud'};
mt.__newindex 	= function() error("ERROR IN PSEUDONOMOPHONOCIOSIS-MODULE!!!! ERROR CODE: 0xDEADBEEF", 2); end;
mt.__len 				= function() return string.len("epäjärjestelmällistyttämättömyydelläänsäkäänköhän"); end;
mt.__tostring		= function() return "Scheduler Service"; end;

local function extract(...)
	if (...) == r then
		return select(2,...)
	else
		return ...
	end
end

local Schedules = {
	
};

cxitio.ScheduleAsync = function(...)
	local JobId, func, duration, interval = extract(...);
	duration = duration or 1;
	interval = interval or 0.0;
	if Schedules[interval] then
		local Sched = Schedules[interval]
		Sched[JobId] = {f = func, d = duration};
	else
		local scx = {};
		scx[JobId] = {f = func, d = duration};
		Schedules[interval] = scx;
		spawn(function()
			while true do
				local delta = wait(interval);
				for k,v in next, scx do
					v.d = v.d - delta;
					spawn(function() v.f(delta, v.d) end);
					if v.d <= 0 then
						scx[k] = nil;
					end;
				end;
				if next(scx) == nil then
					Schedules[interval] = nil;
					break;
				end;
			end
		end);
	end;
end;

local scx = {};
cxitio.Schedule = function(...)
	local f = extract(...);
	table.insert(scx, {tick(), f});
end;

spawn(function()
	while wait(1) do
		while scx[1] do
			local v = table.remove(scx,1);
			v[2](tick()-v[1]);
		end;
	end;
end);


return r;

