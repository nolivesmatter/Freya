local Hybrid;

pow2 = setmetatable({[-1] = 0, [0] = 1,2,4,8,16,32,64,128,256},{__index = function(t,k)
  local v = 2^k
  table.insert(t,k,v)
  return v
end}); -- -1 is not 0, but for ease...

function lsh(value,shift) -- Left Shift
	return (value*pow2[shift]) % 256
end

function rsh(value,shift) -- Right shift
	return math.floor(value/pow2[shift]) % 256
end

function bit(x,b) -- Select single bit
	return (x % pow2[b] - x % pow2[b-1] > 0)
end

-- logic OR for number values
function lor(x,y)
	result = 0
	for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and pow2[p-1] or 0) end
	return result
end

-- Credits to ZarsBranchkin
local function bitRange(str, beginBit, endBit)
    local byte_t = { 1, 2, 4, 8, 16, 32, 64, 128 }

    local beginChar = math.ceil( beginBit/8 )
    local endChar = math.ceil( endBit/8 )
    local range = str:sub( beginChar, endChar )

    local bits = {}
    local beginOffset = beginBit%8 - 1
    local endOffset = endBit - beginOffset + 1

    for num = 1,#range do
        local byte = str:sub(num, num):byte()
        local offset = (num-1)*8 - beginOffset

        for bit=8, 1, -1 do
            local sub = byte - byte_t[bit]
            local pos = offset + bit

            if sub >= 0 then
                if pos > 0 and pos < endOffset then
                    bits[pos] = true
                end
                byte = sub
            else
                if pos > 0 and pos < endOffset then
                    bits[pos] = false
                end
            end
        end
    end
    return bits
end

local function GetBits(integer, idx, n)
  return math.floor(integer / pow2[idx]) % pow2[n]
end

-- Credit to cntkillme
local function getRangeN(str, idxStart, idxEnd)
  idxStart = idxStart - 1;
  idxEnd = idxEnd - 1;
  local firstChar = math.floor(idxStart/8) + 1
  local lastChar = math.floor(idxEnd/8) + 1
  local relStartIdx = idxStart % 8
  local numBits = idxEnd - idxStart + 1

  local sum = 0
  for p = firstChar, lastChar do
    sum = sum * 2^8
    sum = sum + str:byte(p,p)
  end

  return GetBits(sum, (lastChar - firstChar + 1)*8 - numBits - relStartIdx, numBits)
end


-- 10010000
-- 12345678

-- B64 from http://lua-users.org/wiki/BaseSixtyFour
-- Not the fastest, but it works.
local base64chars = { [0] =
   'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
   'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
   'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
   'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}

local function enc64(data)
	local bytes = {}
	local result = ""
	for spos=0,string.len(data)-1,3 do
		for byte=1,3 do bytes[byte] = string.byte(string.sub(data,(spos+byte))) or 0 end
		result = string.format('%s%s%s%s%s',result,base64chars[rsh(bytes[1],2)],base64chars[lor(lsh((bytes[1] % 4),4), rsh(bytes[2],4))] or "=",((#data-spos) > 1) and base64chars[lor(lsh(bytes[2] % 16,2), rsh(bytes[3],6))] or "=",((#data-spos) > 2) and base64chars[(bytes[3] % 64)] or "=")
	end
	return result
end

local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}

local function dec64(...)
	local data = Hybrid(...)
	local chars = {}
	local result=""
	for dpos=0,string.len(data)-1,4 do
		for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
		result = string.format('%s%s%s%s',result,string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),(chars[3] ~= nil) and string.char(lor(lsh(chars[2],4), rsh(chars[3],2))) or "",(chars[4] ~= nil) and string.char(lor(lsh(chars[3],6) % 192, (chars[4]))) or "")
	end
	return result
end

local function FieldEncode(...)
  local data = Hybrid(...)
  local tmp = {}
  local _byte = 1
  local _cnt = 1
  data = data:gsub('[\000\254]', function(s)
    if s == '\0' then
      _byte = _byte + pow2[_cnt]
    end;
    _cnt = _cnt + 1
    if _cnt == 8 then
      _cnt = 1
      _byte = 1;
      tmp[#tmp+1] = string.char(_byte)
    end;
    return '\254'
  end);
  if _cnt > 1 then
    tmp[#tmp+1] = string.char(_byte)
  end
  return table.concat(tmp,'') .. data
end;

local function FieldDecode(...)
  local data = Hybrid(...)
  local count = #data:gsub('[^\254]','');
  local bytecount = math.ceil(count/7); -- Yes, 7.
  local bits = bitRange(data, 1, bytecount);
  local _cnt = 1;
  data = data:gsub('\254', function(s)
    local ret = bits[_cnt] and '\0' or '\254'
    if _cnt % 8 == 7 then
      _cnt = _cnt + 2
    else
      _cnt = _cnt + 1
    end;
    return ret
  end);
  return data
end;


local data = setmetatable({},{__mode = 'k'});

local BitMt = {
  __index = {
    toB64 = function(t)
      if not data[t] then
        return error("toB64 was not called as a method!", 2);
      end;
      t = data[t];
      return enc64(t.data .. t.cache)
    end;
    toFieldEncoded = function(t)
      local data = data[t];
      if not data then
        return error("toFieldEncoded was not called as a method!", 2);
      end
      return FieldEncode(t.data .. t.cache);
    end;
  };
  __tostring = function(t)
    t = data[t];
    return t.data .. t.cached;
  end;
  __add = function(lhs, rhs) -- B|AND
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to add BitStream with incompatible type");
    end
  end;
  __unm = function(stream) -- B|NOT

  end;
  __sub = function(lhs, rhs) -- B|NAND
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to subtract BitStream from incompatible type");
    end
  end;
  __mul = function(lhs, rhs) -- B|OR
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to multiply BitStream with incompatible type");
    end
  end;
  __div = function(lhs, rhs) -- B|NOR
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to divide BitStream with incompatible type");
    end
  end;
  __mod = function(lhs, rhs) -- B|XOR
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to mod BitStream with incompatible type");
    end
  end;
  __concat = function(lhs, rhs) -- Concat data.
    if type(lhs) == 'string' then
      -- RHS is BitStream
    elseif type(rhs) == 'string' then
      -- LHS is BitStream
    elseif data[lhs] and data[rhs] then
      -- Both are BitStream
    else
      return error("Attempt to concatenate BitStream with incompatible type");
    end
  end;
  __len = function(t)
    t = data[t];
    return #(t.data)*8 + t.hanging
  end;
  __metatable = "Locked metatable: Freya bitstream"
};

local new = function(raw)
  if data[raw] then return raw end;
  if type(raw) ~= 'string' then
    return error("Invalid bit data", 3);
  end;
	local ni = newproxy(true);
  data[ni] = {
    data = raw;
    hanging = 0;
    cached = '';
  };
  local mt = getmetatable(ni);
  for e,m in next, BitMt do
    mt[e] = m;
  end;
  return ni;
end;

local Controller = {
  fromB64 = function(...) return new(dec64(...)) end; -- Wrap as a BitStream later
  new = function(...)
    return new(Hybrid(...));
  end;
  fromFieldEncoded = function(...)
    return new(FieldDecode(Hybrid(...)));
  end;
};
local ni = newproxy(true);
local mt = getmetatable(ni);
mt.__index = Controller;
mt.__tostring = function() return "Freya BitStream Controller" end
mt.__metatable = "Locked metatable: Freya";

Hybrid = function(...) if ... == ni then return select(2, ...) else return ... end end

return {
  b64 = enc64;
  unb64 = dec64;
  GetBit = bit;
  GetRangeField = bitRange;
  GetRange = bitRangeN;
};
