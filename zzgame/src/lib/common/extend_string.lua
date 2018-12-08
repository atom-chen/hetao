-------------------------
-- 字符串库扩展
-------------------------
string.Split = function(str, pat)
	if not str then return {} end
	
	local t = {}  
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

-------------------------------------------------------------------

string.url_encode = function(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str 
end 

string.url_decode = function(str)
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)",
		function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end

-------------------------------------------------------------------

-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function base64_enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64_dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-------------------------------------------------------------------

local UTF8LenMap = 
{
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
	4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1,
};

-- 返回字符串Txt的第Start个字符
string.get_word = function (Txt, Start)
	local Var = string.byte(Txt, Start)
	local Len = UTF8LenMap[Var + 1]
	return string.sub(Txt, Start, Start+Len-1), Len
end

string.utf8_sub = function(Txt, iStart, iEnd)

end

string.utf8_length = function(Txt)
	local Count = 0
	local Len = string.len(Txt)
	local i = 1
	while(i <= Len) do
		local _, Num = string.get_word(Txt, i) 
		i = i + Num
		Count = Count + 1
	end
	return Count
end

string.get_word_list = function(Txt)
	local word_list = {}
	local len_list = {}
	local Count = 0
	
	local Len = string.len(Txt)
	local i = 1
	while(i <= Len) do
		local word, Num = string.get_word(Txt, i) 
		i = i + Num
		Count = Count + 1
		
		word_list[#word_list+1] = word 
		len_list[#len_list+1] = Num
	end
	return word_list, len_list
end

-------------------------------------------------------------------

-- 检查是否是GB2312编码
local tGB2312CheckInvalid = {
	[0xA1A1] = true, [0xA2AB] = true, [0xA2AC] = true, [0xA2AD] = true, [0xA2AE] = true, [0xA2AF] = true, 
	[0xA2B0] = true, [0xA2E3] = true, [0xA2E4] = true, [0xA2EF] = true, [0xA2F0] = true, [0xA2FD] = true, 
	[0xA2FE] = true, [0xA4F4] = true, [0xA4F5] = true, [0xA4F6] = true, [0xA4F7] = true, [0xA4F8] = true, 
	[0xA2F9] = true, [0xA4FA] = true, [0xA4FB] = true, [0xA4FC] = true, [0xA4FD] = true, [0xA4FE] = true, 
	[0xA5F7] = true, [0xA5F8] = true, [0xA5F9] = true, [0xA5FA] = true, [0xA5FB] = true, [0xA5FC] = true, 
	[0xA5FD] = true, [0xA5FE] = true, [0xA6B9] = true, [0xA6BA] = true, [0xA6BB] = true, [0xA6BC] = true,
	[0xA6BD] = true, [0xA6BE] = true, [0xA6BF] = true, [0xA6C0] = true, [0xA6D9] = true, [0xA6DA] = true,
	[0xA6DB] = true, [0xA6DC] = true, [0xA6DD] = true, [0xA6DE] = true, [0xA6DF] = true, [0xA6F6] = true,
	[0xA6F7] = true, [0xA6F8] = true, [0xA6F9] = true, [0xA6FA] = true, [0xA6FB] = true, [0xA6FC] = true,
	[0xA6FD] = true, [0xA6FE] = true, [0xA7C2] = true, [0xA7C3] = true, [0xA7C4] = true, [0xA7C5] = true,
	[0xA7C6] = true, [0xA7C7] = true, [0xA7C8] = true, [0xA7C9] = true, [0xA7CA] = true, [0xA7CB] = true,
	[0xA7CC] = true, [0xA7CD] = true, [0xA7CE] = true, [0xA7CF] = true, [0xA7D0] = true, [0xA7F2] = true,
	[0xA7F3] = true, [0xA7F4] = true, [0xA7F5] = true, [0xA7F5] = true, [0xA7F6] = true, [0xA7F7] = true,
	[0xA7F8] = true, [0xA7F9] = true, [0xA7FA] = true, [0xA7FB] = true, [0xA7FC] = true, [0xA7FD] = true,
	[0xA7FE] = true, [0xA8AB] = true, [0xA8AC] = true, [0xA8AD] = true, [0xA8AE] = true, [0xA8AF] = true,
	[0xA8C1] = true, [0xA8C2] = true, [0xA8C3] = true, [0xA8C4] = true, [0xA8EA] = true, [0xA8EB] = true,
	[0xA8EC] = true, [0xA8ED] = true, [0xA8EE] = true, [0xA8EF] = true, [0xA8F0] = true, [0xA8F1] = true,
	[0xA8F2] = true, [0xA8F3] = true, [0xA8F4] = true, [0xA8F5] = true, [0xA8F6] = true, [0xA8F7] = true,
	[0xA8F8] = true, [0xA8F9] = true, [0xA8FA] = true, [0xA8FB] = true, [0xA8FC] = true, [0xA8FD] = true,
	[0xA8FE] = true, [0xA9A1] = true, [0xA9A2] = true, [0xA9A3] = true

}

string.IsCodeGB2312 = function(str)
	if not str then return false end
	local codes = {string.byte(str, 1, string.len(str))}
	local codeNum, idx = #codes, 1
	while idx < codeNum do
		if codes[idx] > 128 then
			if not codes[idx + 1] or codes[idx] == 0xA0 or codes[idx + 1] == 0xFF or codes[idx + 1] < 0xA0 then
				return false
			end
			local charCode = codes[idx] * 256 + codes[idx + 1]
			if charCode <= 0xA1A0 or ( charCode >= 0xA9F0 and charCode <= 0xB0A0 ) or charCode > 0xF7FE or tGB2312CheckInvalid[charCode] then
				return false
			end			
			idx = idx + 2
		else
			idx = idx + 1
		end
	end
	return true
end

string.IsCodeGBK = function(str)
	if not str then return false end

	local codes = {string.byte(str, 1, string.len(str))}
	local codeNum, idx = #codes, 1
	local IsNotChina = ""
	while idx < codeNum do
		-- GBK汉字为两个字节，第一个字节0x81-0xFE（129-254，第二个字节0x40-0xFE（64-254）
		if codes[idx]>=0x81 and codes[idx]<=0xfe then
			if codes[idx+1]>=0x40 and codes[idx+1]<=0xfe then
				idx = idx + 2
			else
				return false
			end
		else
			IsNotChina = IsNotChina..string.char(codes[idx])
			idx = idx + 1
		end
	end
	return true, IsNotChina
end
