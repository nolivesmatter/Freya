--[[

Based on the BitBuffer module by Stravant
Author profile: https://www.roblox.com/users/80119/profile/
Module origin: https://www.roblox.com/library/174612085/BitBuffer-Module

Wrapped for BitStream in Freya. If there are issues with this, whine at Lunate:
https://www.roblox.com/users/65765854/profile

Modified to include extra serialization options, FieldEncode/Decode,
encapsulation, small performance tweaks, and metamethods.

==========================================================================
==                                  API                                 ==

Constructor: BitBuffer.Create()

Read/Write pairs for reading data from or writing data to the BitBuffer:
  BitBuffer:WriteUnsigned(bitWidth, value)
  BitBuffer:ReadUnsigned(bitWidth)
    Read / Write an unsigned value with a given number of bits. The
    value must be a positive integer. For instance, if bitWidth is
    4, then there will be 4 magnitude bits, for a value in the
    range [0, 2^4-1] = [0, 15]

  BitBuffer:WriteSigned(bitWidth, value)
  BitBuffer:ReadSigned(bitWidth)
    Read / Write a a signed value with a given number of bits. For
    instance, if bitWidth is 4 then there will be 1 sign bit and
    3 magnitude bits, a value in the range [-2^3+1, 2^3-1] = [-7, 7]

  BitBuffer:WriteFloat(mantissaBitWidth, exponentBitWidth, value)
  BitBuffer:ReadFloat(mantissaBitWidth, exponentBitWidth)
    Read / Write a floating point number with a given mantissa and
    exponent size in bits.

  BitBuffer:WriteFloat32(value)
  BitBuffer:ReadFloat32()
  BitBuffer:WriteFloat64(value)
  BitBuffer:ReadFloat64()
    Read and write the common types of floating point number that
    are used in code. If you want to 100% accurately save an
    arbitrary Lua number, then you should use the Float64 format. If
    your number is known to be smaller, or you want to save space
    and don't need super high precision, then a Float32 will often
    suffice. For instance, the Transparency of an object will do
    just fine as a Float32.

  BitBuffer:WriteBool(value)
  BitBuffer:ReadBool()
    Read / Write a boolean (true / false) value. Takes one bit worth
    of space to store.

  BitBuffer:WriteString(str)
  BitBuffer:ReadString()
    Read / Write a variable length string. The string may contain
    embedded nulls. Only 7 bits / character will be used if the
    string contains no non-printable characters (greater than 0x80).

  BitBuffer:WriteBrickColor(color)
  BitBuffer:ReadBrickColor()
    Read / Write a roblox BrickColor. Provided as an example of
    reading / writing a derived data type.

  BitBuffer:WriteRotation(cframe)
  BitBuffer:ReadRotation()
    Read / Write the rotation part of a given CFrame. Encodes the
    rotation in question into 64bits, which is a good size to get
    a pretty dense packing, but still while having errors well within
    the threshold that Roblox uses for stuff like MakeJoints()
    detecting adjacency. Will also perfectly reproduce rotations which
    are orthagonally aligned, or inverse-power-of-two rotated on only
    a single axix. For other rotations, the results may not be
    perfectly stable through read-write cycles (if you read/write an
    arbitrary rotation thousands of times there may be detectable
    "drift")


From/To pairs for dumping out the BitBuffer to another format:
  BitBuffer:ToString()
  BitBuffer:FromString(str)
    Will replace / dump out the contents of the buffer to / from
    a binary chunk encoded as a Lua string. This string is NOT
    suitable for storage in the Roblox DataStores, as they do
    not handle non-printable characters well.

  BitBuffer:ToBase64()
  BitBuffer:FromBase64(str)
    Will replace / dump out the contents of the buffer to / from
    a set of Base64 encoded data, as a Lua string. This string
    only consists of Base64 printable characters, so it is
    ideal for storage in Roblox DataStores.

Buffer / Position Manipulation
  BitBuffer:ResetPtr()
    Will Reset the point in the buffer that is being read / written
    to back to the start of the buffer.

  BitBuffer:Reset()
    Will reset the buffer to a clean state, with no contents.

--]]

--[[
String Encoding:
     Char 1   Char 2
str:  LSB--MSB LSB--MSB
Bit#  1,2,...8 9,...,16
--]]

local floor, ceil = math.floor, math.ceil
local insert, concat = table.insert, table.concat
local byte, char, sub = string.byte, string.char, string.sub

local NumberToBase64; local Base64ToNumber; do
  NumberToBase64 = {}
  Base64ToNumber = {}
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  for i = 1, #chars do
    local ch = sub(chars, i, i)
    NumberToBase64[i-1] = ch
    Base64ToNumber[ch] = i-1
  end
end

local PowerOfTwo; do
  PowerOfTwo = {[0] = 1} -- Small modification for performance
  for i = 1, 64 do
    insert(PowerOfTwo, i, 2^i) -- Force it to stay in the array part.
  end
end

local BrickColorToNumber; local NumberToBrickColor; do
  BrickColorToNumber = {}
  NumberToBrickColor = {}
  for i = 0, 63 do
    local color = BrickColor.palette(i)
    BrickColorToNumber[color.Number] = i
    NumberToBrickColor[i] = color
  end
end

local function ToBase(n, b)
    n = floor(n)
    if not b or b == 10 then return tostring(n) end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    local sign = ""
    if n < 0 then
        sign = "-"
        n = -n
    end
    repeat
        local d = (n % b) + 1
        n = floor(n / b)
        insert(t, 1, sub(digits, d, d))
    until n == 0
    return sign..concat(t, "")
end

local function round(n)
  return floor(n + 0.5)
end

local function Create()
  -- Closures for performance.
  -- Flyweight pattern not observed due to buffers having specific use cases
  local this = {}

  local Reset, ResetPtr, FromString, ToString, FromBase64, ToBase64, Dump
  local writeBit, readBit, WriteUnsigned, ReadUnsigned, WriteSigned, ReadSigned
  local WriteString, ReadString, WriteBool, ReadBool
  local WriteFloat, WriteFloat32, WriteFloat64
  local ReadFloat, ReadFloat32, ReadFloat64
  local WriteBrickColor, ReadBrickColor, WriteColor3, ReadColor3
  local WriteRotation, ReadRotation, WriteVector3, ReadVector3
  local WriteRaw, ReadRaw, Seek, FieldEncode, FieldDecode

  -- Tracking
  local mBitPtr = 0
  local mBitBuffer = {}

  function ResetPtr()
    mBitPtr = 0
  end
  function Reset()
    mBitBuffer = {}
    mBitPtr = 0
  end

  -- Read / Write to a string
  function FromString(str)
    Reset()
    WriteRaw(#str*8, str);
    mBitPtr = 0
  end
  function ToString()
    local tmp = mBitPtr;
    mBitPtr = 0;
    local r = ReadRaw(#mBitBuffer);
    mBitPtr = tmp;
    return r;
  end

  -- Read / Write to base64
  function FromBase64(str)
    Reset()
    for i = 1, #str do
      local ch = Base64ToNumber[sub(str, i, i)]
      assert(ch, "Bad character: 0x"..ToBase(byte(str, i, i), 16))
      for i = 1, 6 do
        mBitPtr = mBitPtr + 1
        mBitBuffer[mBitPtr] = ch % 2
        ch = floor(ch / 2)
      end
      assert(ch == 0, "Character value 0x"..ToBase(Base64ToNumber[sub(str, i, i)], 16).." too large")
    end
    ResetPtr()
  end
  function ToBase64()
    local strtab = {}
    local accum = 0
    local pow = 0
    for i = 1, ceil((#mBitBuffer) / 6)*6 do
      accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
      pow = pow + 1
      if pow >= 6 then
        insert(strtab, NumberToBase64[accum])
        accum = 0
        pow = 0
      end
    end
    return concat(strtab)
  end

  -- Dump
  function Dump()
    local str = ""
    local str2 = ""
    local accum = 0
    local pow = 0
    for i = 1, ceil((#mBitBuffer) / 8)*8 do
      str2 = str2..(mBitBuffer[i] or 0)
      accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
      --print(pow..": +"..PowerOfTwo[pow].."*["..(mBitBuffer[i] or 0).."] -> "..accum)
      pow = pow + 1
      if pow >= 8 then
        str2 = str2.." "
        str = str.."0x"..ToBase(accum, 16).." "
        accum = 0
        pow = 0
      end
    end
    print("Bytes:", str)
    print("Bits:", str2)
  end

  -- Read / Write a bit
  function writeBit(v)
    mBitPtr = mBitPtr + 1
    mBitBuffer[mBitPtr] = v
  end
  function readBit()
    mBitPtr = mBitPtr + 1
    return mBitBuffer[mBitPtr]
  end

  -- Read / Write an unsigned number
  function WriteUnsigned(w, value)
    assert(w, "Bad arguments to BitBuffer::WriteUnsigned (Missing BitWidth)")
    assert(value, "Bad arguments to BitBuffer::WriteUnsigned (Missing Value)")
    assert(value >= 0, "Negative value to BitBuffer::WriteUnsigned")
    assert(math.floor(value) == value, "Non-integer value to BitBuffer::WriteUnsigned")

    -- Store LSB first
    for i = 1, w do
      writeBit(value % 2)
      value = floor(value / 2)
    end
    assert(value == 0, "Value "..tostring(value).." has width greater than "..w.."bits")
  end
  function ReadUnsigned(w)
    local value = 0
    for i = 1, w do
      value = value + readBit() * PowerOfTwo[i-1]
    end
    return value
  end

  -- Read / Write a signed number
  function WriteSigned(w, value)
    assert(w and value, "Bad arguments to BitBuffer::WriteSigned (Did you forget a bitWidth?)")
    assert(floor(value) == value, "Non-integer value to BitBuffer::WriteSigned")

    -- Write sign
    if value < 0 then
      writeBit(1)
      value = -value
    else
      writeBit(0)
    end
    -- Write value
    WriteUnsigned(w-1, value, true)
  end
  function ReadSigned(w)
    -- Read sign
    local sign = (-1)^readBit()
    -- Read value
    local value = ReadUnsigned(w-1, true)
    return sign*value
  end

  -- Read / Write a string. May contain embedded nulls (string.char(0))
  function WriteString(s)
    -- First check if it's a 7 or 8 bit width of string
    local bitWidth = 7
    for i = 1, #s do
      if byte(s, i, i) > 127 then
        bitWidth = 8
        break
      end
    end

    -- Write the bit width flag
    writeBit(bitWidth == 7 and 0 or 1);

    -- Now write out the string, terminated with "0x10, 0b0"
    -- 0x10 is encoded as "0x10, 0b1"
    for i = 1, #s do
      local ch = byte(s, i, i);
      if ch == 0x10 then
        WriteUnsigned(bitWidth, 0x10)
        writeBit(1);
      else
        WriteUnsigned(bitWidth, ch)
      end
    end

    -- Write terminator
    WriteUnsigned(bitWidth, 0x10)
    writeBit(0);
  end
  function ReadString()
    -- Get bit width
    local bitWidth = 7 + readBit();

    -- Loop
    local buffer = {}
    local i = 0;
    while true do
      i = i+1;
      local ch = ReadUnsigned(bitWidth)
      if ch == 0x10 and readBit() == 0 then
        break
      else
        buffer[i] = char(ch)
      end
    end
    return concat(buffer);
  end

  -- Read / Write a bool
  function WriteBool(v)
    writeBit(v and 1 or 0)
  end
  function ReadBool()
    return readBit() == 1
  end

  -- Read / Write a floating point number with |wfrac| fraction part
  -- bits, |wexp| exponent part bits, and one sign bit.
  function WriteFloat(wfrac, wexp, f)
    assert(wfrac and wexp and f)

    -- Sign
    local sign = 1
    if f < 0 then
      f = -f
      sign = -1
    end

    -- Decompose
    local mantissa, exponent = math.frexp(f)
    if exponent == 0 and mantissa == 0 then
      WriteUnsigned(wfrac + wexp + 1, 0)
      return
    else
      mantissa = ((mantissa - 0.5) * PowerOfTwo[wfrac+1])
    end

    -- Write sign
    if sign == -1 then
      writeBit(1)
    else
      writeBit(0)
    end

    -- Write mantissa
    mantissa = floor(mantissa + 0.5) -- Not really correct, should round up/down based on the parity of |wexp|
    WriteUnsigned(wfrac, mantissa)

    -- Write exponent
    local maxExp = PowerOfTwo[wexp-1]-1
    if exponent > maxExp then
      exponent = maxExp
    end
    if exponent < -maxExp then
      exponent = -maxExp
    end
    WriteSigned(wexp, exponent)
  end
  function ReadFloat(wfrac, wexp)
    assert(wfrac and wexp)

    -- Read sign
    local sign = 1
    if ReadBool() then
      sign = -1
    end

    -- Read mantissa
    local mantissa = ReadUnsigned(wfrac)

    -- Read exponent
    local exponent = ReadSigned(wexp)
    if exponent == 0 and mantissa == 0 then
      return 0
    end

    -- Convert mantissa
    mantissa = mantissa / PowerOfTwo[wfrac+1] + 0.5

    -- Output
    return sign * math.ldexp(mantissa, exponent)
  end

  -- Read / Write single precision floating point
  function WriteFloat32(f)
    WriteFloat(23, 8, f)
  end
  function ReadFloat32()
    return ReadFloat(23, 8)
  end

  -- Read / Write double precision floating point
  function WriteFloat64(f)
    WriteFloat(52, 11, f)
  end
  function ReadFloat64()
    return ReadFloat(52, 11)
  end

  -- Read / Write a BrickColor
  function WriteBrickColor(b)
    local pnum = BrickColorToNumber[b.Number]
    if not pnum then
      warn("Attempt to serialize non-pallete BrickColor `"..tostring(b).."` (#"..b.Number.."), using Light Stone Grey instead.")
      pnum = BrickColorToNumber[BrickColor.new(1032).Number]
    end
    WriteUnsigned(6, pnum)
  end
  function ReadBrickColor()
    return NumberToBrickColor[ReadUnsigned(6)]
  end

  -- Read / Write a rotation as a 64bit value.
  function WriteRotation(cf)
    local lookVector = cf.lookVector
    local azumith = math.atan2(-lookVector.X, -lookVector.Z)
    local ybase = (lookVector.X^2 + lookVector.Z^2)^0.5
    local elevation = math.atan2(lookVector.Y, ybase)
    local withoutRoll = CFrame.new(cf.p) * CFrame.Angles(0, azumith, 0) * CFrame.Angles(elevation, 0, 0)
    local x, y, z = (withoutRoll:inverse()*cf):toEulerAnglesXYZ()
    local roll = z
    -- Atan2 -> in the range [-pi, pi]
    azumith   = round((azumith   /  math.pi   ) * (2^21-1))
    roll      = round((roll      /  math.pi   ) * (2^20-1))
    elevation = round((elevation / (math.pi/2)) * (2^20-1))
    --
    WriteSigned(22, azumith)
    WriteSigned(21, roll)
    WriteSigned(21, elevation)
  end
  function ReadRotation()
    local azumith   = ReadSigned(22)
    local roll      = ReadSigned(21)
    local elevation = ReadSigned(21)
    --
    azumith =    math.pi    * (azumith / (2^21-1))
    roll =       math.pi    * (roll    / (2^20-1))
    elevation = (math.pi/2) * (elevation / (2^20-1))
    --
    local rot = CFrame.Angles(0, azumith, 0)
    * CFrame.Angles(elevation, 0, 0)
    * CFrame.Angles(0, 0, roll)
    --
    return rot
  end

  -- Color3 as 24-bit
  function WriteColor3(c3)
    local r = round(c3.r*255);
    local g = round(c3.g*255);
    local b = round(c3.b*255);
    WriteUnsigned(8, r);
    WriteUnsigned(8, g);
    WriteUnsigned(8, b);
  end
  function ReadColor3()
    local r = ReadUnsigned(8);
    local g = ReadUnsigned(8);
    local b = ReadUnsigned(8);
    return Color3.fromRGB(r,g,b);
  end

  -- Vector3 as 64-bit
  function WriteVector3(v3)
    WriteFloat(15, 5, v3.x);
    WriteFloat(15, 6, v3.y);
    WriteFloat(15, 5, v3.z);
  end
  function ReadVector3()
    return Vector3.new(
      ReadFloat(15, 5),
      ReadFloat(15, 6),
      ReadFloat(15, 5)
    );
  end

  -- Raw stream
  function WriteRaw(length, data)
    for i = 1, floor(length/8) do
      local ch = byte(data, i, i)
      for i = 1, 8 do
        mBitPtr = mBitPtr + 1
        mBitBuffer[mBitPtr] = ch % 2
        ch = floor(ch / 2)
      end
    end
    local _i = ceil(length/8);
    local ch = byte(data, _i, _i);
    for i = 1, length % 8 do
      mBitPtr = mBitPtr + 1;
      mBitBuffer[mBitPtr] = ch % 2;
      ch = floor(ch / 2);
    end
  end
  function ReadRaw(length)
    local buffer = {}
    local accum = 0
    local pow = 0
    local rot = 0
    for i = mBitPtr+1, mBitPtr+length do
      mBitPtr = i;
      accum = accum + PowerOfTwo[pow]*(mBitBuffer[i] or 0)
      pow = pow + 1
      if pow >= 8 then
        rot = rot + 1
        buffer[rot] = char(accum)
        accum = 0
        pow = 0
      end
    end
    if pow > 0 then
      buffer[rot+1] = char(accum);
    end
    return concat(buffer)
  end

  -- FieldEncode/Decode for networking
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

  function FieldEncode()
    local data = ToString();
    local tmp = {};
    local _byte = 1;
    local _cnt = 1;
    --[[data = data:gsub('[\000\254]', function(s)
      if s == '\0' then
        _byte = _byte + PowerOfTwo[_cnt];
      end
      _cnt = _cnt + 1;
      if _cnt == 8 then
        tmp[#tmp+1] = char(_byte);
        _cnt = 1;
        _byte = 1;
      end
      return '\254';
    end);]]
    local buffer = {};
    local last = 1;
    for i=1, #data do
      local b = byte(data, i, i);
      if b == 0 then
        _byte = _byte + PowerOfTwo[_cnt];
        _cnt = _cnt + 1;
        if i ~= 1 then
          buffer[#buffer+1] = sub(data,last,i-1);
          buffer[#buffer+1] = '\254'
          last = i+1;
        end
      elseif b == 254 then
        _cnt = _cnt + 1;
      end
      if _cnt == 8 then
        tmp[#tmp+1] = char(_byte);
        _cnt = 1;
        _byte = 1;
      end
    end
    if _cnt > 1 then
      tmp[#tmp+1] = char(_byte);
    end
    if last <= #data then
      buffer[#buffer+1] = sub(data, last, #data);
    end
    return concat(tmp) .. concat(buffer);
  end;

  function FieldDecode(data)
    local count = #data:gsub('[^\254]','');
    local bytecount = ceil(count/7); -- Yes, 7.
    local bits = bitRange(data, 1, bytecount);
    local _cnt = 1;
    data = data:gsub('\254', function(s)
      local r = bits[_cnt] and '\0' or '\254';
      if _cnt % 8 == 7 then
        _cnt = _cnt + 2;
      else
        _cnt = _cnt + 1;
      end
      return r;
    end);
    FromString(data);
  end

  -- Seek
  function Seek(Where, Offset)
    Where = Where or 'cur';
    Offset = Offset or 0;
    if Where == 'set' then
      mBitPtr = Offset;
    elseif Where == 'cur' then
      mBitPtr = mBitPtr + Offset;
    elseif Where == 'end' then
      mBitPtr = #mBitBuffer - Offset;
    end
    if mBitPtr > #mBitBuffer then
      mBitPtr = #mBitBuffer;
    elseif mBitPtr < 0 then
      mBitPtr = 1;
    end
    return mBitPtr;
  end

  -- Apparently there's a ton of these.
  this.Reset = Reset;
  this.ResetPtr = ResetPtr;
  this.FromString = FromString;
  this.ToString = ToString;
  this.FromBase64 = FromBase64;
  this.ToBase64 = ToBase64;
  this.Dump = Dump;
  this.writeBit = writeBit;
  this.readBit = readBit;
  this.WriteUnsigned = WriteUnsigned;
  this.ReadUnsigned = ReadUnsigned;
  this.WriteSigned = WriteSigned;
  this.ReadSigned = ReadSigned;
  this.WriteString = WriteString;
  this.ReadString = ReadString;
  this.WriteBool = WriteBool;
  this.ReadBool = ReadBool;
  this.WriteFloat = WriteFloat;
  this.WriteFloat32 = WriteFloat32;
  this.WriteFloat32 = WriteFloat32;
  this.ReadFloat = ReadFloat;
  this.ReadFloat32 = ReadFloat32;
  this.ReadFloat64 = ReadFloat64;
  this.WriteBrickColor = WriteBrickColor;
  this.ReadBrickColor = ReadBrickColor;
  this.WriteColor3 = WriteColor3;
  this.ReadColor3 = ReadColor3;
  this.WriteRotation = WriteRotation;
  this.ReadRotation = ReadRotation;
  this.WriteVector3 = WriteVector3;
  this.ReadVector3 = ReadVector3;
  this.WriteRaw = WriteRaw;
  this.ReadRaw = ReadRaw;
  this.Seek = Seek;
  this.FieldEncode = FieldEncode;
  this.FieldDecode = FieldDecode;

  -- Create object
  local ni = newproxy(true);
  local mt = getmetatable(ni);
  mt.__index = function(_, k)
    return this[k] or mBitBuffer[k]
  end
  mt.__len = function()
    return #mBitBuffer;
  end
  mt.__tostring = ToString;
  mt.__metatable = "Locked metatable: Freya BitStream"
  -- No other methods because mutator behaviour would be *heavy*

  -- Convert to hybrids
  for k,v in next, this do
    this[k] = function(...)
      if ... == ni then
        return v(select(2, ...));
      else
        return v(...);
      end
    end
  end;

  -- Create aliases
  this.Clear = this.Reset;
  this.ResetPointer = this.ResetPtr;
  this.WriteBit = this.writeBit;
  this.ReadBit = this.readBit;
  this.FromFieldEncoded = this.FieldDecode;
  this.ToFieldEncoded = this.FieldEncode;

  return ni
end;

local ni = newproxy(true);
local mt = getmetatable(ni);
local Controller =  {
  Create = Create;
  fromB64 = function(B64)
    local n = Create();
    n:FromBase64(B64);
    return n;
  end;
  fromFieldEncoded = function(data)
    local n = Create();
    n:FieldDecode(data);
    return n;
  end;
}
for k,v in next, Controller do
  Controller[k] = function(...)
    if ... == ni then
      return v(select(2, ...));
    else
      return v(...);
    end
  end
end;
Controller.new = Controller.Create;
Controller.FromFieldEncoded = Controller.FromFieldEncoded;
Controller.FromBase64 = Controller.fromB64;
Controller.fromBase64 = Controller.fromB64;
Controller.FromB64 = Controller.fromB64;
mt.__index = Controller;
mt.__tostring = function()
  return "Freya BitStream module"
end;
mt.__metatable = "Locked Metatable: Freya";

return ni
