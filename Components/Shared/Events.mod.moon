--//
--// * Events for Freya
--// | Extended events system which supports the standard Roblox API, without
--// | all the gotchas of the BindableEvent implementation
--//
--// # TODO: Add intent support
--//

Event = {}
Events = setmetatable {}, {__mode = 'k'}
Hold = setmetatable {}, {__mode = 'k'}
Intercept = setmetatable {}, {__mode = 'k'}
Disconnections = setmetatable {}, {__mode = 'k'}

ni = newproxy true

pack = (...) -> {
  n: select '#', ...
  ...
}
extract = (...) ->
  return select 2, ... if ... == ni else ...

local eClass = {
  fire: (...) =>
    ar = pack(...)
    Hold[@] = ar
    intercept = Intercept[@]
    if intercept
      ret = pack intercept ...
      if ret[1] ~= nil or ret.n > 1
        return unpack ret, 1, ret.n
    Events[@]\Fire!
  connect: (f) =>
		Events[@].Event\connect ->
      ar = Hold[@]
      f unpack ar, 1, ar.n
	wait: =>
		Events[@]\wait!
		ar = Hold[@]
    unpack ar, 1, ar.n
	intercept: (f) =>
		old = Intercept[@]
		Intercept[@] = f
		return old
};
eClass.Fire = eClass.fire;
eClass.Intercept = eClass.intercept;

dClass = {
  disconnect = =>
    if Disconnections[@]
      Disconnections[@]!
      Disconnections[@] = nil
    else
      error "Attempt to disconnect dead connection or invalid connection", 2
  connected = => not not Disconnections[@]
}
dClass.Connected = dClass.connected

Event.new = ->
  eni = newproxy true
  with getmetatable eni
    .__index = eClass
    .__metatable = "Locked Metatable: Freya Event"
  ne = Instance.new "BindableEvent"
  Events[eni] = ne
  return eni

Event.Intent = (...) ->
  IntentName = extract ...

Event.Connection = (...) ->
  f = extract ...
  eni = newproxy true
  with getmetatable eni
    .__index = dClass
    .__metatable = "Locked Metatable: Freya Connection"
  Disconnections[eni] = f
  return eni

with getmetatable ni
  .__index = Event
  .__tostring = -> "Freya Events"
  .__metatable = "Locked Metatable: Freya"

return ni
