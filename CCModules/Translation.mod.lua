-- Unified translation
-- Fetch the Valkyrie requirements
local Settings = _G.Valkyrie:GetSettings "Translation";

-- Create the controller
local Controller = newproxy(true);
local ControllerMt = getmetatable(Controller);
local ControllerClass = {};

-- Create the Translation Node class
local TranslationNodeClass = {};
local TranslationNodeMt = {};
local TranslationNodeLinks = setmetatable({},{__mode = 'k'});
local TranslationNodeBacklinks = setmetatable({},{__mode = 'v'});

-- Util
local function extract(...)
  if ... == Controller then
    return select(2,...);
  else
    return ...;
  end;
end;

-- Controller class
function ControllerClass.CreateNode(...)
  local name, translations = extract(...);
  if TranslationNodeBacklinks[name] then
    warn("[Warn][Translation] (in CreateNode): "..name.." already exists. Updating translations instead.");
    local tli = TranslationNodeLinks[TranslationNodeBacklinks[name]];
    for k,v in next, translations do
      tli[k:lower()] = v;
    end;
    return TranslationNodeBacklinks[name];
  else
    local newTranslationNode = newproxy(true);
    local newTranslationMt = getmetatable(newTranslationNode);
    for k,v in next,TranslationNodeMt do
      newTranslationMt[k] = v;
    end;
    local _translations = {};
    for k,v in next,translations do
      if type(k) ~= 'string' then
      	return error("[Error][Translation] (in CreateNode): All keys must be strings", 2);
    	end;
    	if #k == 2 then
      	-- We have no locale :S
      	-- Assume repeated
      	k = k..'_'..k;
    	end;
    	k = k:gsub('-','_');
    	if #k ~= 5 or k:sub(3,3) ~= "_" then
    	  return error("[Error][Translation] (in CreateNode): "..k.." doesn't appear to be a valid language format :(", 2);
    	else
    	  _translations[k:lower()] = v;
	    end;
    end;
    TranslationNodeBacklinks[name] = newTranslationNode;
    TranslationNodeLinks[newTranslationNode] = _translations;
    _translations.default = _translations.default
    or _translations.en_us
    or _translations.en_uk
    or _translations.en_en
    or select(2,next(_translations));
    return newTranslationNode;
  end;
end;

function ControllerClass.GetNode(...)
  local name = extract(...);
  local node = TranslationNodeBacklinks[name];
  if not node then
    warn("[Warn][Translation] (in GetNode): "..name.." doesn't yet exist. Creating a blank translation.");
    node = ControllerClass.CreateNode(name,{});
  end
  return node;
end;

-- Register settings
local TargetLanguage = "en_us"
Settings:RegisterSetting("Language", {
  get = function()
    return TargetLanguage;
  end;
  set = function(v)
    if type(v) ~= 'string' then
      return error("[Error][Translation] (in Settings.Language): A string was not supplied!", 2);
    end;
    if #v == 2 then
      -- We have no locale :S
      -- Assume repeated
      v = v..'_'..v;
    end;
    v = v:gsub('-','_');
    if #v ~= 5 or v:sub(3,3) ~= "_" then
      return error("[Error][Translation] (in Settings.Language): "..v.." doesn't appear to be a valid format :(", 2);
    else
      TargetLanguage = v:lower();
    end;
  end;
});

-- Make locale aliases; valid translation fallbacks
local aliases = {
  en_uk = {"en_en","en_us"};
  en_us = {"en_en","en_uk"};
  en_en = {"en_us","en_uk"};
}

-- Connect our Translation Node class
TranslationNodeMt.__tostring = function(this)
  local this = TranslationNodeLinks[this];
  return this[TargetLanguage] or this.default;
end;
TranslationNodeMt.__metatable = "Valkyrie Translation Node Metatable";
TranslationNodeMt.__index = function(this,k)
  local translations = TranslationNodeLinks[this];
  local translation = translations[k];
  if not translation then
    for k,v in ipairs(aliases[TargetLanguage]) do
      translation = translations[v];
      if translation then break end;
    end;
  end;
  if not translation then
    translation =  translations.default or "##INVALID TRANSLATION: REPORT TO GAME OWNER##";
  end;
  return translation;
end;

-- Connect our Translation Controller
ControllerMt.__index = ControllerClass;
ControllerMt.__tostring = function(this)
  return "Translation Controller";
end;
ControllerMt.__newindex = error;
ControllerMt.__metatable = "Locked Metatable: Valkyrie";

-- Return. Duhh.
return Controller;
