-- Unified input
-- Create actions, bind input.

local Controller = {};
local this = newproxy(true);
local IntentService = _G.Valkyrie:GetComponent "IntentService";
local Event = _G.Valkyrie:GetComponent "ValkyrieEvents";
local Translation = _G.Valkyrie:GetComponent "Translation";
local RenderStep = game:GetService('RunService').RenderStepped;

local function extract(...) -- Dynamic methods are pretty much standard now
  if (...) == this then
    return select(2,...);
  else
    return ...;
  end;
end;

local Actions = setmetatable({},{__mode = 'v'});
local ActionLinks = setmetatable({},{__mode = 'k'});
local ActionBinds = setmetatable({},{__mode = 'k'});
local ActionClass = {};
local ActionMt = {
  __tostring = function(this)
    return ActionLinks[this].Name;
  end;
  __call = function(this,...)
    return ActionLinks[this].Action(...);
  end;
  __index = function(this,k)
    return ActionClass[k] or ActionLinks[this][k];
  end;
  __metatable = "Locked metatable: Valkyrie";
  __len = function(this)
    return ActionLinks[this].FireCount;
  end;
  __gc = function(this) -- Is __gc enabled in Roblox?
    local binds = ActionBinds[this];
    for i=1,#binds do
      binds[i]:disconnect();
    end;
  end;
};
local UserActions = setmetatable({},{__mode = 'v'});

local iBinds = {};
local InputSources, LinkedTypes, LinkedNames do
  LinkedTypes = {};
  LinkedNames = {};
  local function make(sourceType, BindingName)
    local nop = newproxy(false);
    LinkedTypes[nop] = sourceType;
    LinkedNames[nop] = BindingName;
    return nop;
  end;
  InputSources = {
    Mouse = {
      Mouse1 = make("Mouse1", "Mouse1");
      Mouse2 = make("Mouse2", "Mouse2");
      Mouse3 = make("Mouse3", "Mouse3");
      Moved = make("MouseMoved", "Moved");
      Scrolled = make("MouseScrolled", "Scrolled");
    };
    Keyboard = {
      -- There's got to be a better way of doing this, surely.
      A = make("Keyboard", "A");
      B = make("Keyboard", "B");
      C = make("Keyboard", "C");
      D = make("Keyboard", "D");
      E = make("Keyboard", "E");
      F = make("Keyboard", "F");
      G = make("Keyboard", "G");
      H = make("Keyboard", "H");
      I = make("Keyboard", "I");
      J = make("Keyboard", "J");
      K = make("Keyboard", "K");
      L = make("Keyboard", "L");
      M = make("Keyboard", "M");
      N = make("Keyboard", "N");
      O = make("Keyboard", "O");
      P = make("Keyboard", "P");
      Q = make("Keyboard", "Q");
      R = make("Keyboard", "R");
      S = make("Keyboard", "S");
      T = make("Keyboard", "T");
      U = make("Keyboard", "U");
      V = make("Keyboard", "V");
      W = make("Keyboard", "W");
      X = make("Keyboard", "X");
      Y = make("Keyboard", "Y");
      Z = make("Keyboard", "Z");
      make("Keyboard", "One");
      make("Keyboard", "Two");
      make("Keyboard", "Three");
      make("Keyboard", "Four");
      make("Keyboard", "Five");
      make("Keyboard", "Six");
      make("Keyboard", "Seven");
      make("Keyboard", "Eight");
      make("Keyboard", "Nine");
      [0] = make("Keyboard", "Zero");
      Shift = make("Keyboard", "LeftShift");
      Tab = make("Keyboard", "Tab");
      Esc = make("Keyboard", "Escape");
      Space = make("Keyboard", "Space");
      Ctrl = make("Keyboard", "LeftControl");
      Alt = make("Keyboard", "LeftAlt");
      Super = make("Keyboard", "LeftMeta");
      Up = make("Keyboard","Up");
      Down = make("Keyboard","Down");
      Left = make("Keyboard","Left");
      Right = make("Keyboard","Right");
      Insert = make("Keyboard","Insert");
      KeypadZero = make("Keyboard","KeypadZero");
      Tilde = make("Keyboard","Tilde");
    };
    Controller1 = {
      A = make("ControllerButton", "ButtonA");
      B = make("ControllerButton", "ButtonB");
      X = make("ControllerButton", "ButtonX");
      Y = make("ControllerButton", "ButtonY");
      L1 = make("ControllerButton", "ButtonL1");
      R1 = make("ControllerButton", "ButtonR1");
      L2 = make("ControllerTrigger", "ButtonL2");
      R2 = make("ControllerTrigger", "ButtonR2");
      L3 = make("ControllerButton", "ButtonL3");
      R3 = make("ControllerButton", "ButtonR3");
      Start = make("ControllerButton", "ButtonStart");
      Select = make("ControllerButton", "ButtonSelect");
      Up = make("ControllerButton", "DPadUp");
      Down = make("ControllerButton", "DPadDown");
      Left = make("ControllerButton", "DPadLeft");
      Right = make("ControllerButton", "DPadRight");
      Analogue1 = make("ControllerAxis", "Thumbstick1");
      Analogue2 = make("ControllerAxis", "Thumbstick2");
    };
    Controller2 = {
      A = make("ControllerButton", "ButtonA");
      B = make("ControllerButton", "ButtonB");
      X = make("ControllerButton", "ButtonX");
      Y = make("ControllerButton", "ButtonY");
      L1 = make("ControllerButton", "ButtonL1");
      R1 = make("ControllerButton", "ButtonR1");
      L2 = make("ControllerTrigger", "ButtonL2");
      R2 = make("ControllerTrigger", "ButtonR2");
      L3 = make("ControllerButton", "ButtonL3");
      R3 = make("ControllerButton", "ButtonR3");
      Start = make("ControllerButton", "ButtonStart");
      Select = make("ControllerButton", "ButtonSelect");
      Up = make("ControllerButton", "DPadUp");
      Down = make("ControllerButton", "DPadDown");
      Left = make("ControllerButton", "DPadLeft");
      Right = make("ControllerButton", "DPadRight");
      Analogue1 = make("ControllerAxis", "Thumbstick1");
      Analogue2 = make("ControllerAxis", "Thumbstick2");
    };
    Controller3 = {
      A = make("ControllerButton", "ButtonA");
      B = make("ControllerButton", "ButtonB");
      X = make("ControllerButton", "ButtonX");
      Y = make("ControllerButton", "ButtonY");
      L1 = make("ControllerButton", "ButtonL1");
      R1 = make("ControllerButton", "ButtonR1");
      L2 = make("ControllerTrigger", "ButtonL2");
      R2 = make("ControllerTrigger", "ButtonR2");
      L3 = make("ControllerButton", "ButtonL3");
      R3 = make("ControllerButton", "ButtonR3");
      Start = make("ControllerButton", "ButtonStart");
      Select = make("ControllerButton", "ButtonSelect");
      Up = make("ControllerButton", "DPadUp");
      Down = make("ControllerButton", "DPadDown");
      Left = make("ControllerButton", "DPadLeft");
      Right = make("ControllerButton", "DPadRight");
      Analogue1 = make("ControllerAxis", "Thumbstick1");
      Analogue2 = make("ControllerAxis", "Thumbstick2");
    };
    Controller4 = {
      A = make("ControllerButton", "ButtonA");
      B = make("ControllerButton", "ButtonB");
      X = make("ControllerButton", "ButtonX");
      Y = make("ControllerButton", "ButtonY");
      L1 = make("ControllerButton", "ButtonL1");
      R1 = make("ControllerButton", "ButtonR1");
      L2 = make("ControllerTrigger", "ButtonL2");
      R2 = make("ControllerTrigger", "ButtonR2");
      L3 = make("ControllerButton", "ButtonL3");
      R3 = make("ControllerButton", "ButtonR3");
      Start = make("ControllerButton", "ButtonStart");
      Select = make("ControllerButton", "ButtonSelect");
      Up = make("ControllerButton", "DPadUp");
      Down = make("ControllerButton", "DPadDown");
      Left = make("ControllerButton", "DPadLeft");
      Right = make("ControllerButton", "DPadRight");
      Analogue1 = make("ControllerAxis", "Thumbstick1");
      Analogue2 = make("ControllerAxis", "Thumbstick2");
    };
    TouchActions = {
      Tapped = make("TouchAction", "Tapped");
      LongPressed = make("TouchAction", "TouchLongPress");
      Moved = make("TouchAction", "Moved");
      Panned = make("TouchAction", "Panned");
      Pinched = make("TouchAction", "Pinched");
      Rotated = make("TouchAction", "Rotated");
      Started = make("TouchAction", "Started");
      Ended = make("TouchAction", "TouchEnded");
      Swiped = make("TouchAction", "Swiped");
      Raw = make("TouchInput", "Raw");
    };
    Application = {
      Focus = make("ApplicationFocus", "Focus");
    };
    ClickDetector = {
      Click = make("ClickDetector", "Click");
      Hover = make("ClickDetector", "Hover");
    };
  };
  do
    -- ~ Keyboard input aliases
    local Keyboard = InputSources.Keyboard;
    for k,v in next, Keyboard do Keyboard[LinkedNames[v]] = v end;
    Keyboard.One = Keyboard[1];
    Keyboard.Two = Keyboard[2];
    Keyboard.Three = Keyboard[3];
    Keyboard.Four = Keyboard[4];
    Keyboard.Five = Keyboard[5];
    Keyboard.Six = Keyboard[6];
    Keyboard.Seven = Keyboard[7];
    Keyboard.Eight = Keyboard[8];
    Keyboard.Nine = Keyboard[9];
    Keyboard.Zero = Keyboard[0];
    Keyboard.Control = Keyboard.Ctrl;
    Keyboard.LeftControl = Keyboard.Ctrl;
    Keyboard.LCtrl = Keyboard.Ctrl;
    Keyboard.LControl = Keyboard.Ctrl;
    Keyboard.Win = Keyboard.Super;
    Keyboard.LeftSuper = Keyboard.Super;
    Keyboard.LSuper = Keyboard.Super;
    Keyboard.LWin = Keyboard.Super;
    Keyboard.LeftWin = Keyboard.Super;
    Keyboard.WindowsKey = Keyboard.Super;
    Keyboard.Windows = Keyboard.Super;
    Keyboard.LShift = Keyboard.Shift;
    Keyboard.Cmd = Keyboard.Super;
    Keyboard.LeftShift = Keyboard.Shift;


    -- ~ Keyboard Translation aliases
    local _translations = {};
    for k,v in next, Keyboard do
      local n = LinkedNames[v];
      _translations[n] = {en_us = n};
    end;
    local modlist = script:GetChildren();
    for i = 1, #modlist do
      local v = modlist[i];
      local tlist = require(v);
      local nom = v.Name;
      for n,v in next, tlist do
        _translations[n] = _translations[n] or {};
        _translations[n][nom] = v;
      end;
    end;
    for k,v in next, _translations do
      Translation:CreateNode("Keyboard."..k, v);
    end;
  end;
  do
    -- ~ Gamepad input aliases
    for i=1,4 do
      local Controller = InputSources["Controller"..tostring(i)];
      Controller.ButtonA = Controller.A;
      Controller.ButtonB = Controller.B;
      Controller.ButtonX = Controller.X;
      Controller.ButtonY = Controller.Y;
      Controller.ButtonL1 = Controller.L1;
      Controller.ButtonL2 = Controller.L2;
      Controller.ButtonR1 = Controller.R1;
      Controller.ButtonR2 = Controller.R2;
      Controller.ButtonL3 = Controller.L3;
      Controller.ButtonR3 = Controller.R3;
      Controller.ButtonStart = Controller.Start;
      Controller.ButtonSelect = Controller.Select;
      Controller.Thumbstick1 = Controller.Analogue1;
      Controller.Thumbstick2 = Controller.Analogue2;
      Controller.Analog1 = Controller.Analogue1;
      Controller.Analog2 = Controller.Analogue2;
      Controller.DPadLeft = Controller.Left;
      Controller.DPadRight = Controller.Right;
      Controller.DPadUp = Controller.Up;
      Controller.DPadDown = Controller.Down;
      Controller.ThumbStick1 = Controller.Analogue1;
      Controller.ThumbStick2 = Controller.Analogue2;
      InputSources["Gamepad"..tostring(i)] = Controller;
      InputSources["GamePad"..tostring(i)] = Controller;
    end;
  end;
  do
    local Touch = InputSources.TouchActions;
    InputSources.Touch = Touch;
    Touch.Tap = Touch.Tapped;
    Touch.LongPress = Touch.LongPressed;
    Touch.Move = Touch.Moved;
    Touch.Pan = Touch.Panned;
    for k,v in next, Touch do
      Touch["Touch"..k] = v;
    end;
  end
  for k,v in next, InputSources do
    local np = newproxy(true);
    local mt = getmetatable(np);
    mt.__index = v;
    mt.__tostring = function()return k end;
    mt.__metatable = "Locked metatable: Valkyrie";
    InputSources[k] = np;
  end;
  InputSources.Controller = InputSources.Controller1;
  InputSources.Gamepad = InputSources.Controller1;
  InputSources.GamePad = InputSources.Controller1;
  local ni = InputSources;
  InputSources = newproxy(true);
  local mt = getmetatable(InputSources);
  mt.__index = ni;
  mt.__metatable = "Locked metatable: Valkyrie";
  mt.__tostring = function() return "Valkyrie Input Sources" end;
end;
local InputDirections = {
  Up = newproxy(false);
  Down = newproxy(false);
  DownUp = newproxy(false);
  Change = newproxy(false);
  Action = newproxy(false);
};
InputDirections.Click = InputDirections.DownUp;
InputDirections.Tap = InputDirections.DownUp;
InputDirections.Start = InputDirections.Down;
InputDirections.Begin = InputDirections.Down;
InputDirections.Finish = InputDirections.Up;
InputDirections.End = InputDirections.Up;
InputDirections.Changed = InputDirections.Change;
InputDirections.Update = InputDirections.Change;
InputDirections.Updated = InputDirections.Change;
do
  local id = InputDirections;
  Controller.InputDirections = newproxy(true);
  local mt = getmetatable(Controller.InputDirections);
  mt.__index = id;
  mt.__metatable = "Locked metatable: Valkyrie";
  mt.__tostring = function() return "Valkyrie Input Directions" end;
end;

-- Make input objects and bind at the same time if the input is not already bound.
-- If the input is bound, then that's all fine.
local UIS = game:GetService("UserInputService");
local Mouse = game:GetService("Players").LocalPlayer:GetMouse();
local CAS = game:GetService("ContextActionService");
local InputTracker = {};
local InputCache = {};
local BoundUnique = {};
local CreateInputState, UISEdge, UISProxy;
local Edge = {
  TouchLongPress = function(a,i,p,m)
    -- The InputState for Touch is only for references :c
    local state = CreateInputState(InputSources.Touch.LongPressed, m);
    local source = InputTracker[state];
    source.TouchArray = a;
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchMoved = function(i,p,m)
    local state = CreateInputState(InputSources.Touch.Moved, m);
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchPan = function(a,t,v,i,p,m) -- Damn man
    local state = CreateInputState(InputSources.Touch.Pan, m);
    local source = InputTracker[state];
    source.TouchArray = a;
    source.Translation = t;
    source.Velocity = v;
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchPinch = function(a,s,v,i,p,m)
    local state = CreateInputState(InputSources.Touch.Pinch, m);
    local source = InputTracker[state];
    source.TouchArray = a;
    source.Scale = s;
    source.Velocity = v;
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchRotate = function(a,r,v,i,p,m)
    local state = CreateInputState(InputSources.Touch.Rotate, m);
    local source = InputTracker[state];
    source.TouchArray = a;
    source.Rotation = r;
    source.Velocity = v;
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchStarted = function(i,p,m)
    local state = CreateInputState(InputSources.Touch.Started, m);
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchEnded = function(i,p,m)
    local state = CreateInputState(InputSources.Touch.Ended, m);
    iBinds[state]:Fire(state, InputDirections.Action, p, i);
  end;
  TouchSwipe = function(d,i,p,m)
    local state = CreateInputState(InputSources.Touch.Swipe, m);
    local source = InputTracker[state];
    source.Direction = d;
    source.Amount = i;
    iBinds[state]:Fire(state, InputDirections.Action, p, {d,i});
  end;
  TouchTap = function(a,p,m)
    local state = CreateInputState(InputSources.Touch.Tap, m)
    local source = InputTracker[state];
    source.TouchArray = a;
    iBinds[state]:Fire(state, InputDirections.Action, p, {a,p});
  end;
};
CreateInputState = function(source, meta)
  -- Create a generic input object for the target Source
  if not source then return end;
  if not meta then
    if InputCache[source] then return InputCache[source] end;
  else
    if InputCache[meta] and InputCache[meta][source] then return InputCache[meta][source] end;
  end;
  local iType = LinkedTypes[source];
  local iName = LinkedNames[source];
  if not (iType or iName) then return end;
  local ni = newproxy(true);
  local mt = getmetatable(ni);
  local Props = {};
  mt.__index = Props;
  InputTracker[ni] = Props;
  mt.__tostring = function()
    return "Valkyrie Input: "..iName.." ("..iType..")";
  end;
  if iType == 'Keyboard' then
    Props.Key = iName;
    -- Bound already
  elseif iType == 'Mouse1' then
    Props.Key = "Mouse1";
    Props.Target = Mouse.Target;
  elseif iType == 'Mouse2' then
    Props.Target = Mouse.Target;
    Props.Key = "Mouse2";
  elseif iType == 'Mouse3' then
    Props.Target = Mouse.Target;
    Props.Key = "Mouse3"
  elseif iType == 'MouseMoved' then
    Props.Target = Mouse.Target;
  elseif iType == 'MouseScrolled' then
    Props.ScrollY = 0;
  elseif iType == 'ControllerButton' then
    Props.Key = iName;
    Props.Button = iName;
    for i=1,4 do
      if InputSources["Controller"..tostring(i)][iName] == source then
        Props.Controller = i;
        break;
      end;
    end;
  elseif iType == 'ControllerTrigger' then
    Props.Key = iName;
    Props.Button = iName;
    Props.Trigger = iName;
    for i=1,4 do
      if InputSources["Controller"..tostring(i)][iName] == source then
        Props.Controller = i;
        break;
      end;
    end;
    -- It's happening.
  elseif iType == 'ControllerAxis' then
    for i=1,4 do
      if InputSources["Controller"..tostring(i)][iName] == source then
        Props.Controller = i;
        break;
      end;
    end;
    Props.Key = iName;
    Props.Stick = iName;
    Props.Analogue = iName;
  elseif iType == 'TouchScreen' then
    -- No idea how to configure this one.
    -- Location::Position
  end;
  if meta and meta:IsA("GuiObject") then
    BoundUnique[meta] = true;
    meta.InputBegan:connect(UISProxy(meta));
    meta.InputEnded:connect(UISProxy(meta));
    meta.InputChanged:connect(UISProxy(meta));
    meta.TouchLongPress:connect(function(a,i,p)
      return Edge.TouchLongPress(a,i,p,meta);
    end);
    meta.TouchPan:connect(function(a,t,v,i,p)
      return Edge.TouchPan(a,t,v,i,p,meta);
    end);
    meta.TouchPinch:connect(function(a,s,v,i,p)
      return Edge.TouchPan(a,s,v,i,p,meta);
    end);
    meta.TouchRotate:connect(function(a,r,v,i,p)
      return Edge.TouchRotate(a,r,v,i,p,meta);
    end);
    meta.TouchSwipe:connect(function(d,i,p)
      return Edge.TouchSwipe(d,i,p,meta);
    end);
    meta.TouchTap:connect(function(a,p)
      return Edge.TouchTap(a,p,meta);
    end);
  end;
  local iBind = Event.new "InstantEvent"
  if not meta then
    InputCache[source] = ni;
  else
    InputCache[meta] = InputCache[meta] or {};
    InputCache[meta][source] = ni;
  end;
  iBinds[ni] = iBind;
  return ni;
end;
-- Bind UIS outside of the function because of how it works
UISEdge = function(i,p,m)
  local iType = i.UserInputType.Name;
  local sType = iType;
  local sName;
  if sType == 'Keyboard' then
    sName = i.KeyCode.Name;
  elseif sType == 'Touch' then
    sType = 'TouchInput';
    sName = 'Raw';
  elseif sType == 'MouseButton0' then
    sType = 'Mouse';
    sName = 'Mouse1';
  elseif sType == 'MouseButton1' then
    sType = 'Mouse';
    sName = 'Mouse2';
  elseif sType == 'MouseButton2' then
    sType = 'Mouse';
    sName = 'Mouse3';
  elseif sType == 'MouseMovement' then
    sType = 'Mouse';
    sName = 'Moved';
  elseif sType == 'MouseWheel' then
    sType = 'Mouse';
    sName = 'Scrolled';
  elseif sType:sub(1,-2) == 'Gamepad' then
    -- I think this should solve an issue with whose controller is whose
    sName = i.KeyCode.Name;
  elseif sType == 'Focus' then
    sType = 'Application';
    sName = 'Focus';
  end;
  local source = InputSources[sType][sName];
  if not source then return end;
  local vType = LinkedTypes[source];
  local dir = i.UserInputState == Enum.UserInputState.Begin and InputDirections.Down or InputDirections.Up;
  if i.UserInputState == Enum.UserInputState.Change then
    dir = InputDirections.Change;
  end;
  local iobj = CreateInputState(source, m);
  local iprops = InputTracker[iobj];
  iprops.InputName = sName;
  iprops.InputType = sType;
  if sType == 'Mouse' and iprops.Target ~= Mouse.Target then
    iprops.OldTarget = iprops.Target;
    iprops.Target = Mouse.Target;
    iprops.Hit = Mouse.Hit;
  end;
  if iType == 'MouseMovement' then
    iprops.Position = i.Position;
  elseif sType == 'MouseScrolled' then
    dir = i.Delta.Y > 0 and InputDirections.Up or InputDirections.Down;
    iprops.ScrollY = iprops.ScrollY + i.Delta.Y; -- Not sure about Pos
  elseif vType == 'ControllerTrigger' then
    iprops.Position = i.Position;
    iprops.Axis = i.Position.Y;
    iprops.Var = i.Position.Y;
  elseif vType == 'ControllerAxis' then
    iprops.Position = i.Position;
  elseif vType == 'ApplicationFocus' then
    iprops.Focused = dir == InputDirections.Down;
  else
    iprops.Down = dir == InputDirections.Down
  end;
  iBinds[iobj]:Fire(iobj, dir, p, i);
end;
UIS.InputBegan:connect(UISEdge);
UIS.InputEnded:connect(UISEdge);
UIS.InputChanged:connect(UISEdge);
UIS.TouchLongPress:connect(Edge.TouchLongPress);
UISProxy = function(m)
  return function(i,p)
    return UISEdge(i,p,m);
  end;
end;
Edge.UIS = UISEdge;

-- Create actions
function Controller.CreateAction(...)
  local actionname,defaultaction = extract(...);
  assert(
    type(actionname) == 'string',
    "[Error][Valkyrie Input] (in CreateAction): Supplied action name was not a string",
    2
  );
  assert(
    type(defaultaction) == 'function',
    "[Error][Valkyrie Input] (in CreateAction): Supplied action callback was not a function",
    2
  );
  if Actions[actionname] then
    return error(
      "[Error][Valkyrie Input] (in CreateAction): Supplied action name is already bound to an Action ("..actionname..")",
      2
    );
  end;
  local newAction = newproxy(true);
  local newContent = {
    Name = actionname;
    Action = defaultaction;
    self = newAction;
  };
  local newMt = getmetatable(newAction);
  for k,v in next, ActionMt do
    newMt[k] = v;
  end;
  Actions[actionname] = newAction;
  ActionLinks[newAction] = newContent;
  ActionBinds[newAction] = {};
  return newAction;
end;

function Controller.GetAction(...)
  local actionname = extract(...);
  assert(
    type(actionname) == 'string',
    "[Error][Valkyrie Input] (in GetAction): Supplied action name was not a string",
    2
  );
  return Actions[actionname];
end;

function Controller.EmulateInput(...)
  local source, dir, meta, data = extract(...);
  assert(source, "[Error][Valkyrie Input] (in Controller.EmulateInput()): You need to supply an Input source as #1", 2);
  local Type, Name = LinkedTypes[source],LinkedNames[source];
  assert(
    Type and Name,
    "[Error][Valkyrie Input] (in Controller.EmulateInput()): You need to supply a valid Valkyrie Input as #1, did you supply a string by accident?",
    2
  );
  assert(dir, "[Error][Valkyrie Input] (in Controller.EmulateInput()): You need to supply an Input direction as #2", 2);
  do local suc = false;
    for k,v in next, InputDirections do
      if v == dir then
        suc = true;
        break;
      end;
    end;
    if not suc then
      error("[Error][Valkyrie Input] (in Controller.EmulateInput()): You need to supply a valid Valkyrie Input direction object as #2", 2);
    end;
  end;
  local i = CreateInputState(source, meta);
  iBinds[i]:Fire(i, dir, true, data);
end;

Controller.Mouse = Mouse;
Controller.CAS = CAS;
Controller.UIS = UIS;

Controller.InputSources = InputSources;
Controller.GetInputState = CreateInputState;

Controller.UserActions = UserActions;

function ActionClass:UnbindAll()
  local binds = ActionBinds[self];
  for i=#binds,1,-1 do
    if binds[i] then
      binds[i]:disconnect();
      binds[i] = nil;
    end;
  end;
end;

function ActionClass:SetFlag(flag, value)
  if flag == 'User' then
    value = (not not value) or nil;
    IntentService:FireIntent("SetUserAction", self, value or false);
    UserActions[self] = value;
  else
    return error(
      "[Error][Valkyrie Input] (in Action:SetFlag()): "..flag.." is not a valid flag.",
      2
    );
  end;
end;
do
  local utilIsTouch = function(s)
    return LinkedTypes[s] == 'TouchAction'
  end
  local CustomConnection do
    -- Constructor for custom Connection objects
    local finishers = setmetatable({},{__mode = 'k'});
    local disconnectAction = function(self)
      if not self then
        error("[Error][Valkyrie Input] (in connection:disconnect()): No connection given. Did you forget to call this as a method?", 2);
      end;
      if finishers[self] then
        finishers[self](self);
        finishers[self] = nil;
      else
        warn("[Warn][Valkyrie Input] (in connection:disconnect()): Unable to disconnect disconnected action for ValkyrieInput");
      end;
    end;
    local cmt = {
      __index = function(t,k)
        if k == 'disconnect' then
          return disconnectAction;
        end;
      end;
      __metatable = "Locked metatable: Valkyrie";
      __tostring = function()
        return "Connection object for ValkyrieInput";
      end;
    };
    CustomConnection = function(disconnectFunc)
      local newConnection = newproxy(true);
      local newMt = getmetatable(newConnection);
      for e,m in next, cmt do
        newMt[e] = m;
      end;
      finishers[newConnection] = disconnectFunc;
      return newConnection;
    end;
  end;
  -- @source: Valkyrie Input type
  -- @dir: Input direction (Up, Down, /Click)
  function ActionClass:BindControl(source, dir)
    -- ~ UIS/Mouse style input sources to bind from
    assert(source, "[Error][Valkyrie Input] (in ActionClass:BindControl()): You need to supply an Input source as #1", 2);
    local Type, Name = LinkedTypes[source],LinkedNames[source];
    assert(
      Type and Name,
      "[Error][Valkyrie Input] (in ActionClass:BindControl()): You need to supply a valid Valkyrie Input as #1, did you supply a string by accident?",
      2
    );
    assert(dir, "[Error][Valkyrie Input] (in ActionClass:BindControl()): You need to supply an Input direction as #2", 2);
    do local suc = false;
      for k,v in next, InputDirections do
        if v == dir then
          suc = true;
          break;
        end;
      end;
      if not suc then
        error("[Error][Valkyrie Input] (in ActionClass:BindControl()): You need to supply a valid Valkyrie Input direction object as #2", 2);
      end;
    end;

    -- Grab the input object for the source
    local iobj = CreateInputState(source);

    -- Wrap the function in a binding
    local func,bfunc = self.Action
    if d == InputDirections.DownUp then
      local down = false;
      bfunc = function(i,d,p,r)
        if d == InputDirections.Up then
          if down then
            down = false;
            return func(i,p,r);
          end;
          down = false
        elseif d == InputDirections.Down then
          down = true;
        end;
      end;
    else
      bfunc = function(i,d,p,r)
        if d == dir then
          return func(i,p,r);
        end;
      end;
    end;

    --> Connection
    local bind = iBinds[iobj]:connect(bfunc);
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindSource(source, dir, object)
    -- ~ Binding actions for Instances with input sources
    -- ~ Similar to BindControl
    -- @object: Binding target
    assert(source, "[Error][Valkyrie Input] (in ActionClass:BindSource()): You need to supply an Input source as #1", 2);
    local Type, Name = LinkedTypes[source],LinkedNames[source];
    assert(
      Type and Name,
      "[Error][Valkyrie Input] (in ActionClass:BindSource()): You need to supply a valid Valkyrie Input as #1, did you supply a string by accident?",
      2
    );
    assert(dir, "[Error][Valkyrie Input] (in ActionClass:BindSource()): You need to supply an Input direction as #2", 2);
    do local suc = false;
      for k,v in next, InputDirections do
        if v == dir then
          suc = true;
          break;
        end;
      end;
      if not suc then
        error("[Error][Valkyrie Input] (in ActionClass:BindSource()): You need to supply a valid Valkyrie Input direction object as #2", 2);
      end;
    end;
    assert(object, "[Error][ValkyrieInput] (in ActionClass:BindSource()): You need to supply a valid source as #3", 2);

    -- Grab the input object for the source
    local iobj = CreateInputState(source, object);

    -- Wrap the function in a binding
    local func,bfunc = self.Action
    if d == InputDirections.DownUp then
      local down = false;
      bfunc = function(i,d,p,r)
        if d == InputDirections.Up then
          if down then
            down = false;
            return func(i,p,r);
          end;
          down = false
        elseif d == InputDirections.Down then
          down = true;
        end;
      end;
    else
      bfunc = function(i,d,p,r)
        if d == dir then
          return func(i,p,r);
        end;
      end;
    end;

    --> Connection
    local bind = iBinds[iobj]:connect(bfunc);
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindContext(makebutton, ...)
    -- ! Look at the CAS API and change the order of arguments around.
    -- ~ Extra content binding, CAS style
    -- @makebutton: Create an onscreen button for this input source?
    -- @[...]: Alternating source, dir
    local tempsources, sources = {...},{};
    local errmsg;
    for i=1,#tempsources,2 do
      -- Sanity check
      local v,d = tempsources[i], tempsources[i+1];
      if not (v and d) then
        errmsg = "Malformed array of inputs";
        break;
      end
      if not (LinkedTypes[v] and LinkedTypes[d]) then
        errmsg = "Bad input source at argument #"..tostring(i+1);
      end
      sources[math.ceil(i*0.5)] = {tempsources[i], tempsources[i+1]}
    end
    tempsources = nil;
    if errmsg then
      error("[Error][Valkyrie Input] (in ActionClass:BindContext()): "..errmsg, 2);
      return;
    end

    local Connections = {};

    for i=1,#sources do
      local v = sources[i];
      local state = CreateInputState(v[1]);
      local func,bfunc = self.Action
      local d = v[2];
      if d == InputDirections.DownUp then
        local down = false;
        bfunc = function(i,d,p,r)
          if d == InputDirections.Up then
            if down then
              down = false;
              return func(i,p,r);
            end;
            down = false
          elseif d == InputDirections.Down then
            down = true;
          end;
        end;
      else
        bfunc = function(i,d,p,r)
          if d == dir then
            return func(i,p,r);
          end;
        end;
      end;
      Connections[#Connections+1] = iBinds[state]:connect(bfunc);
    end;

    local Button;
    if makebutton then
      Button = Instance.new("ImageButton", game.Player.LocalPlayer.PlayerGui.ControlGui);
      Connections[#Connections+1] = self:BindButtonPress(newButton);
      Connections[#Connections+1] = CustomConnection(function() Button:Destroy() end);
    end

    --> Connection, ?Button
    local bind = CustomConnection(function()
      for i=1,#Connections do
        Connections[i]:disconnect();
      end
    end)
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind, Button
  end;
  function ActionClass:BindButtonPress(button)
    -- ~ Redirects a button press (From any input that can provide it) to the action

    local TouchState = CreateInputState(InputSources.Touch.TouchTap, button);
    local tBind = iBinds[TouchState]:connect(function(i,d,p,r) self.Action(i,p,r) end);
    local mBind = button.MouseButton1Click:connect(self.Action);
    -- Not sure how the Controller is supposed to select things?

    --> Connection
    local bind = CustomConnection(function()
      tBind:disconnect();
      mBind:disconnect();
    end)
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindCombo(sources)
    -- @sources: Table array of Valkyrie Input Sources
    -- | When they're all down, it fires. Once.

    local BindCollection = {};
    local Totals = {};
    local ilist = {};
    local errmsg;
    local func = self.Action;
    for i=1,#sources do
      local v = sources[i];
      if not v then
        errmsg = "The source table is not an array";
        break;
      end;
      local Type, Name = LinkedTypes[v],LinkedNames[v];
      if not (Type and Name) then
        errmsg = "The source table contains an invalid source at ["..tostring(i).."]";
        break;
      end;
      local iobj = CreateInputState(v);
      ilist[i] = iobj;
      Totals[i] = false;
      local Bind = iBinds[iobj]:connect(function(q,d,p,r)
        if d == InputDirections.Up then
          Totals[i] = false;
        elseif d == InputDirections.Down then
          local isDown = true;
          Totals[i] = true;
          for n=1,#Totals do
            if not Totals[i] then
              isDown = false;
              break;
            end;
          end;
          if isDown then
            return func(ilist,p);
          end;
        end;
      end);
      BindCollection[#BindCollection+1] = Bind;
    end;
    if errmsg then
      for i=1, #BindCollection do
        BindCollection[i]:disconnect();
      end;
      error("[Error][Valkyrie Input] (in ActionClass:BindCombo()): "..errmsg, 2);
    end;

    --> Connection
    -- Create a CustomConnection Object to disconnect all of the connections stored inside of BindCollection
    local bind = CustomConnection(function()
      for i=#BindCollection, 1, -1 do
        BindCollection[i]:disconnect();
        BindCollection[i] = nil;
      end;
    end);
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindSequence(sources)
    -- @sources: Table array of Valkyrie Input Sources
    -- | Sources are to be checked in order. No tree building here.
    local BindCollection = {};
    local curr = 1;
    for i=1,#sources do
      local state = CreateInputState(sources[i]);
      local down = false;
      local _func = self.Action;
      local func = function(...)
        if curr > #sources then
          return _func(...)
        end;
      end;
      BindCollection[#BindCollection+1] = iBinds[state]:connect(function(q,d,p,r)
        if curr ~= i then curr = 1 return end;
        if d == InputDirections.Up then
          if down then
            down = false;
            curr = curr + 1;
            return func(q,p,r);
          end;
          down = false
        elseif d == InputDirections.Down then
          down = true;
        elseif d == InputDirections.Action then
          curr = curr + 1;
          return func(q,p,r);
        end;
      end);
    end;

    --> Connection
    local bind = CustomConnection(function()
      for i=1,#BindCollection do
        BindCollection[i]:disconnect();
      end
    end);
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindTouchAction(source, object)
    -- ~ Specific touch events like tapping, pinching, scrolling etc
    assert(utilIsTouch(source), "[Error][Valkyrie Input] (in ActionClass:BindTouchAction()): Supplied input source was not a TouchAction", 2);
    local state = CreateInputState(source, object);

    --> Connection
    local bind = iBinds[state]:connect(function(i,d,p,r)
      return self.Action(i,p,r);
    end)
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
  function ActionClass:BindHold(source, time, interval)
    assert(source, "[Error][Valkyrie Input] (in ActionClass:BindHold()): You need to supply an Input source as #1", 2);
    local Type, Name = LinkedTypes[source],LinkedNames[source];
    assert(
      Type and Name,
      "[Error][Valkyrie Input] (in ActionClass:BindHold()): You need to supply a valid Valkyrie Input as #1, did you supply a string by accident?",
      2
    );
    assert(
      type(time) == 'number',
      "[Error][Valkyrie Input] (in ActionClass:BindHold()): You need to supply a hold time as #1",
      2
    );
    interval = interval or -1;
    assert(
      type(interval) == 'number',
      "[Error][Valkyrie Input] (in ActionClass:BindHold()): Supplied repeat interval was not a number",
      2
    )

    local state = CreateInputState(source);

    local afunc = self.Action;
    local bfunc = function(i,d,p,r)
      if d == InputDirections.Down then
        local alive = true;
        delay(time, function()
          if interval > 0 then
            local d = 0;
            while alive do
              afunc(i,p,r,d);
              d = 0; -- It is possible to adjust this loop so that it reduces
              -- the length of the next wait, but that fucks with the expected
              -- delta and we're supplying the delta for a reason.
              while d < interval do
                d = d + RenderStep:wait();
              end;
            end;
          elseif alive then
            return afunc(i,p,r,0);
          end;
        end);
        repeat
          local _,_d = iBinds[state]:wait();
        until _d == InputDirections.Up;
        alive = false;
      end;
    end;
    local bind = iBinds[state]:connect(bfunc);
    ActionBinds[self][#ActionBinds[self]+1] = bind;
    return bind;
  end;
end;


do
  local mt = getmetatable(this);
  mt.__index = Controller;

  mt.__tostring = function()
    return "Valkyrie Input controller";
  end;
  mt.__metatable = "Locked metatable: Valkyrie";
end;

return this;
