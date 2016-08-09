-- Moonscript utility
local ^
ExtractWrapper = (o) ->
	(f) -> (...) ->
		return f select 2, ... if ... == o else f ...

r = newproxy true
extract = ExtractWrapper r

Util = with {}
-- Essentially extractizer but for Moonscript use.
-- With a little more ugly.
-- Can work with vanilla Lua but was designed for Moonscript syntax
	.ExtractWrapper = extract ExtractWrapper
-- I plan on putting more stuff in here.

with getmetatable r
	.__index = Util
	.__metatable = "Locked Metatable: Valkyrie"
	.__tostring = -> "Valkyrie MoonUtil"

return r
