pow2 = setmetatable({[0] = 1,2,4,8,16,32,64,128,256},{__index = function(t,k)
  local v = 2^k
  table.insert(t,k,v)
  return v
end});

function lsh(value,shift) -- Left Shift
	return (value*pow2[shift]) % 256
end

function rsh(value,shift) -- Right shift
	return math.floor(value/2^shift) % 256
end

function bit(x,b) -- Select single bit
	return (x % pow2[b] - x % pow2[b-1] > 0)
end

-- logic OR for number values
function lor(x,y)
	result = 0
	for p=1,8 do result = result + (((bit(x,p) or bit(y,p)) == true) and 2^(p-1) or 0) end
	return result
end

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

local base64chars = { [0] =
   'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
   'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
   'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
   'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/',
}

function enc64(data)
	local bytes = {}
	local result = ""
	for spos=0,string.len(data)-1,3 do
		for byte=1,3 do bytes[byte] = string.byte(string.sub(data,(spos+byte))) or 0 end
		result = string.format('%s%s%s%s%s',result,base64chars[rsh(bytes[1],2)],base64chars[lor(lsh((bytes[1] % 4),4), rsh(bytes[2],4))] or "=",((#data-spos) > 1) and base64chars[lor(lsh(bytes[2] % 16,2), rsh(bytes[3],6))] or "=",((#data-spos) > 2) and base64chars[(bytes[3] % 64)] or "=")
	end
	return result
end

local base64bytes = {['A']=0,['B']=1,['C']=2,['D']=3,['E']=4,['F']=5,['G']=6,['H']=7,['I']=8,['J']=9,['K']=10,['L']=11,['M']=12,['N']=13,['O']=14,['P']=15,['Q']=16,['R']=17,['S']=18,['T']=19,['U']=20,['V']=21,['W']=22,['X']=23,['Y']=24,['Z']=25,['a']=26,['b']=27,['c']=28,['d']=29,['e']=30,['f']=31,['g']=32,['h']=33,['i']=34,['j']=35,['k']=36,['l']=37,['m']=38,['n']=39,['o']=40,['p']=41,['q']=42,['r']=43,['s']=44,['t']=45,['u']=46,['v']=47,['w']=48,['x']=49,['y']=50,['z']=51,['0']=52,['1']=53,['2']=54,['3']=55,['4']=56,['5']=57,['6']=58,['7']=59,['8']=60,['9']=61,['-']=62,['_']=63,['=']=nil}

function dec64(data)
	local chars = {}
	local result=""
	for dpos=0,string.len(data)-1,4 do
		for char=1,4 do chars[char] = base64bytes[(string.sub(data,(dpos+char),(dpos+char)) or "=")] end
		result = string.format('%s%s%s%s',result,string.char(lor(lsh(chars[1],2), rsh(chars[2],4))),(chars[3] ~= nil) and string.char(lor(lsh(chars[2],4), rsh(chars[3],2))) or "",(chars[4] ~= nil) and string.char(lor(lsh(chars[3],6) % 192, (chars[4]))) or "")
	end
	return result
end

return {
  b64 = enc64;
  unb64 = dec64;
};
