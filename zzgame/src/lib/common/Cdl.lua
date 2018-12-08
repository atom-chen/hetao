-------------------------
-- 数据类型定义
-------------------------
--[[
cdl basic value postfix
B = boolean
BY = byte_t
I = int
S = string
SH = short
DT = date
L64 = long
D = Double
--]]
module("Cdl", package.seeall)

Byte = {
	name = "Byte",
	__cdlbase__ = true,
	__minDataSize = 1,
	init = 0,
	write = function(ostream, i) ostream:writeByte(i) end,
	read = function(istream) return istream:readByte() end,
}

Bool = {
	name = "Bool",
	__cdlbase__ = true,
	__minDataSize = 2,
	init = true,
	write = function(ostream, i) ostream:writeBool(i) end,
	read = function(istream) return istream:readBool() end,
}

Short = {
	name = "Short",
	__cdlbase__ = true,
	__minDataSize = 2,
	init = 0,
	write = function(ostream, i) ostream:writeShort(i) end,
	read = function(istream) return istream:readShort() end,
}

Int = {
	name = "Int",
	__cdlbase__ = true,
	__minDataSize = 4,
	init = 0,
	write = function(ostream, i) ostream:writeInt(i) end,
	read = function(istream) return istream:readInt() end,
}

Long = {
	name = "Long",
	__cdlbase__ = true,
	__minDataSize = 4,
	init = 0,
	write = function(ostream, i) ostream:writeLong64(i) end,
	read = function(istream) return istream:readLong64() end,
}

Float = {
	name = "Float",
	__cdlbase__ = true,
	__minDataSize = 4,
	init = 0,
	write = function(ostream, i) ostream:writeFloat(i) end,
	read = function(istream) return istream:readFloat() end,
}

Double = {
	name = "Double",
	__cdlbase__ = true,
	__minDataSize = 8,
	init = 0,
	write = function(ostream, i) ostream:writeDouble(i) end,
	read = function(istream) return istream:readDouble() end,
}

String = {
	name = "String",
	__cdlbase__ = true,
	__minDataSize = 0,
	init = "",
	write = function(ostream, i) ostream:writeString(i) end,
	read = function(istream) return istream:readString() end,
}

Date = {
	name = "Date",
	__cdlbase__ = true,
	__minDataSize = 4,
	init = 0,
	write = function(ostream, i) ostream:writeDate(i) end,
	read = function(istream) return istream:readDate() end,
}


---------------

--比较两个对象类型是否相同
local function typeCompare( prototype, nowType )
	if nowType == false then
		return true
	end
	
	local pType = type( prototype )
	local nType = type( nowType )
	if pType ~= nType then
		error("CDL Error!Type not the same!")
		return false
	end

	if "table" == pType then
		if prototype.name ~= nowType.__cname then
			error(string.format("CDL Error! Class type not the same %s:%s", tostring(nowType.__cname), tostring(prototype.name)))
			return false
		end
	end
	return true
end



--不可读写元表
local UnreadwriteableMetaTable = {
	__newindex = function(t, k, v)
		error(string.format("CDL Error! Attempt to newindex a unwriteable table:%s k:%s v:%s", tostring(t), tostring(k), tostring(v)))
	end,
	__index = function(t, k)
		error(string.format("CDL Error! Attempt to index an undefined variable \"%s\"", tostring(k)))
	end
}

----字典---------------

--将字典的key转换成字符串
local function makeKey(key)
	local t = type(key)

	if "number" == t then
		return tostring(key)
	elseif "string" == t then	
		return "s"..key
	elseif "table" == t then
		local keyStr = ""
		for k, v in pairs(key) do
			local vType = type(v)
			if "function" ~= vType and "table" ~= vType then
				keyStr = keyStr..v..","
			end
		end
		return keyStr
	elseif "function" == t then
		error("CDL Error!key can not be a function.")
		return nil
	end
	error(string.format("CDL Error! Error Dictionary key type:%s, input type is:%s", t, tostring(key)))
	return nil
end

local Pair = class("Pair")
function Pair:ctor(key, value)
	self.key = key or false
	self.value = value or false
end

local DictBaseFunc = {}

function DictBaseFunc:getData()
	return rawget(self, "__pairs__")
end

function DictBaseFunc:find( key )
	return self:getData()[makeKey(key)]
end

function DictBaseFunc:insert(pair, forceUpdate)
	if pair.__cname ~= "Pair" then
		error("Error! [Dictionary] insert data not a 'Pair' value!")
		return
	end

	if not (typeCompare(rawget(self, "__keyPrototype"), pair.key) and typeCompare(rawget(self, "__valuePrototype"), pair.value) ) then
		error("CDL Error! Type error!")
		return
	end

	local keyStr = makeKey(pair.key)
	local d = self:getData()
	if d[ keyStr ] then
		if forceUpdate == true then
			d[keyStr] = pair
		end
		return false
	end
	d[keyStr] = pair
	self.length = self.length + 1
	return true
end

function DictBaseFunc:erase( key )
	if not typeCompare(self.keyPrototype, key) then
		return false
	end
	local keyStr = makeKey(key)
	local d = self:getData()
	if d[keyStr] then
		d[keyStr] = nil
		self.length = self.length - 1
		assert(length >= 0, "length error")
	end
end

function DictBaseFunc:clear()
	rawset(self, "__pairs__", {})
	self.length = 0
end

function DictBaseFunc:size()
	return self.length
end

function DictBaseFunc:iter( )
	local d = self:getData()
	local rk
	return function (d, _)
		local rv 
		if rk then 	
			rk,rv = next(d,rk)
		else 
			rk,rv = next(d)
		end 
		if rv then
			return rv.key, rv.value
		else
			return nil, nil
		end
	end, d
end

function DictBaseFunc:__quickInsert(pair)
	local keyStr = makeKey(pair.key)
	self.__pairs__[keyStr] = pair
	self.length = self.length + 1
end

local DictMetatable = {
	__index = function(t, k)
			if type(k) == "string" then
				local func = DictBaseFunc[k]
				if func then
					-- setfenv(func, Cdl)
					return func
				end
			end
			if typeCompare(rawget(t, "__keyPrototype"), k) then
				local pair = t:find(k) -- t.__pairs__[ makeKey(k) ]
				if pair then
					return pair.value
				else
					return nil
				end
			end												
		end,
	__newindex = function (t, k, v)
			t:insert(Pair.new(k, v), true)
			if rawget(t, k) then--key的值类型为string时候有机会与DictBaseFunc的方法同名这时候会有问题
				error("CDL Error!string key has in DictBaseFunc, which is"..k)
			end
		end,
}


----数组---------------

local ArrayBaseFunc = {}

function ArrayBaseFunc:pushBack( value )
	if not typeCompare(rawget(self, "__valuePrototype"), value) then
		error("CDL Error! [Array] pushBack Error, type is not match.")
		return false
	end
	table.insert(self:getData(), value)
	return true
end

function ArrayBaseFunc:getSize()
	return #self:getData()
end

function ArrayBaseFunc:insert( pos, value )
	if not typeCompare(rawget(self, "__valuePrototype"), value) then
		error("CDL Error! [Array] type is not match,array type:", value)
		return false
	end
	table.insert(self:getData(), pos, value)
	return true
end

function ArrayBaseFunc:remove(pos)
	return table.remove(self:getData(), pos)
end

function ArrayBaseFunc:getData()
	return rawget(self, "__array__")
end

function ArrayBaseFunc:clear()
	rawset(self,"__array__",{})
end

function ArrayBaseFunc:iter()
	local a = self:getData()
	return function (a, k)
		local rk, rv 
		if k then 	
			rk,rv = next(a,k)
		else 
			rk,rv = next(a)
		end 
		return rk,rv
	end, a
end

function ArrayBaseFunc:__getValueBase()
	return rawget(self, "__valueBase")
end

local ArrayMetatable = {
	__index = function(t, k)
			if type(k) == "number" then
				local a = t:getData()
				local size = #a
				if k > size then
					error("Array bounds read, not size:"..size..", now indexing:"..k)
					return false
				end
				return a[k]
			else
				local func = ArrayBaseFunc[k]
				-- setfenv(func, Cdl)
				return func
			end
		end,
	__newindex = function (t, k, v)
			local a = t:getData()
			local size = #a
			if k > size then
				error("Array bounds read,not size:"..size..",now indexing:"..k)
				return false
			end
			if not typeCompare(rawget(t, "__valuePrototype"), v) then
				error("CDL Error!, [Array] type is not match,array type:", v)
				return false
			end
			a[k] = v
		end,
}



----公开方法-----------------------------------------

--定义普通结构
function cdlStruct(className)
	return class(className)
end

--创建枚举
function createEnum( source, withReadWrite )
	if withReadWrite == nil then withReadWrite = true end

	local enumTable = {
		__enumSet__ = {}
	}

	local maxEnum = 0
	for k, v in pairs(source) do
		enumTable.__enumSet__[v] = k
		enumTable[k] = v
		if maxEnum < v then
			maxEnum = v
		end
	end

	local function checkIsEnum(v)
		if  enumTable.__enumSet__[v] == nil then
			error(string.format("CDL Error! The enum:%s, %s is not in this enum table!", tostring(enumTable.__enumSet__[v]) , tostring(v)))
		end
	end
	
	if withReadWrite then
		local write, read = "writeInt", "readInt"
		if maxEnum <= 0x7f then
			write = "writeByte"
			read = "readByte"
		elseif maxEnum <= 0x7fff then
			write = "writeShort"
			read = "readShort"
		end

		function enumTable:__write(__os, enum)
			checkIsEnum(enum)
			__os[write](__os, enum)
		end

		function enumTable:__read(__is)
			local enum = __is[read](__is)
			checkIsEnum(enum)
			return enum
		end
	end
	
	setmetatable(enumTable, UnreadwriteableMetaTable)
	return enumTable
end

--创建一般枚举
function createNormalEnum( source )
	return createEnum( source, false )
end

--定义字典结构
function declareDictionary( key, value )
	local Dictionary = { 
		__key__ = key,
		__value__ = value,
		name = "Dictionary"
	}
	local keyBase = nil
	if key.__cdlbase__ == true then
		keyBase = key
		Dictionary.__key__ = keyBase.init
	end
	
	local valueBase = nil
	if value.__cdlbase__ == true then
		valueBase = value
		Dictionary.__value__ = valueBase.init
	end
	
	function Dictionary.new()
		local dict = {
			__cname = Dictionary.name,
			__pairs__ = {},
			__keyPrototype = Dictionary.__key__,
			__keyBase = keyBase,
			__valuePrototype = Dictionary.__value__,
			__valueBase = valueBase,
			length = 0,
		}
		setmetatable( dict, DictMetatable )

		return dict
	end

	return Dictionary
end

--从字节流中读字典数据
function CdlReadDictionary( is, dictionary )
	local size = is:readSize()
	
	local keyPrototype = rawget(dictionary, "__keyPrototype")
	local keyBase = rawget(dictionary, "__keyBase")
	local valuePrototype = rawget(dictionary, "__valuePrototype")
	local valueBase = rawget(dictionary, "__valueBase")
	
	for k = 1, size do
		local p = Pair.new()
		if keyBase then
			p.key = keyBase.read(is)
		else
			p.key = keyPrototype.new()

			local cname = p.key.__cname
			if cname == "Array" then
				CdlReadArray( is, p.key )

			elseif cname == "Dictionary" then
				CdlReadDictionary( is, p.key )

			elseif cname ~= nil then				
				p.key:__read(is)

			end
		end

		if valueBase then
			p.value = valueBase.read(is)
		else
			p.value = valuePrototype.new()

			local cname = p.value.__cname
			if cname == "Array" then
				CdlReadArray( is, p.value )

			elseif cname == "Dictionary" then
				CdlReadDictionary( is, p.value )

			elseif cname ~= nil then			
				p.value:__read(is)	
			end
		end
		dictionary:__quickInsert(p)
	end
end

--将字典数据写入字节流中
function CdlWriteDictionary( os, dictionary )
	os:writeSize( dictionary:size() )

	local keyPrototype = rawget(dictionary, "__keyPrototype")
	local keyBase = rawget(dictionary, "__keyBase")
	local valuePrototype = rawget(dictionary, "__valuePrototype")
	local valueBase = rawget(dictionary, "__valueBase")

	for k, v in pairs(dictionary:getData()) do
		if keyBase then
			keyBase.write(os, v.key)
		else
			local cname = v.key.__cname
			if cname == "Array" then
				CdlWriteArray( os, v.key )

			elseif cname == "Dictionary" then
				CdlWriteDictionary(os, v.key )

			elseif cname ~= nil then
				v.key:__write(os)

			end
		end

		if valueBase then
			valueBase.write(os,v.value)
		else
			local cname = v.value.__cname
			if cname == "Array" then
				CdlWriteArray( os, v.value )

			elseif cname == "Dictionary" then
				CdlWriteDictionary(os, v.value )

			elseif cname ~= nil then
				v.value:__write(os)
				
			end
		end
	end
end

--定义数组结构
function declareArray( value )
	local Array = {
		__value__ = value,
		name = "Array"
	}
	local valueBase = nil
	if value.__cdlbase__ == true then
		valueBase = value
		Array.__value__ = valueBase.init
	end

	function Array.new()
		local arr = {
			__cname = Array.name,
			__array__ = {},
			__valuePrototype = Array.__value__,
			__valueBase = valueBase,
		}
		setmetatable( arr, ArrayMetatable )

		return arr
	end

	return Array
end

--从字节流中读取数组数据
function CdlReadArray( is, array )
	local size = is:readSize()
	
	local valuePrototype = rawget(array, "__valuePrototype")
	local valueBase = rawget(array, "__valueBase")
	
	if valueBase then
		if size > 0 then
			is:setUseBitMark(false)
		end
		for i = 1, size do
			local arrayValue = valueBase.read(is)
			array:pushBack(arrayValue)
		end
		if size > 0 then
			is:setUseBitMark(true)
		end
	else
		for i = 1, size do
			local arrayValue = valuePrototype.new()
			local cname = arrayValue.__cname
			if cname == "Array" then
				CdlReadArray( is, arrayValue )

			elseif cname == "Dictionary" then
				CdlReadDictionary( is, arrayValue )

			elseif cname ~= nil then				
				arrayValue:__read(is)
				array:pushBack(arrayValue)				
			end
		end
	end
end

--将数组数据写入字节流中
function CdlWriteArray( os, array )
	os:writeSize( array:getSize() )

	local valuePrototype = rawget(array, "__valuePrototype")
	local valueBase = rawget(array, "__valueBase")
	
	if valueBase then
		if array:getSize() > 0 then
			os:setUseBitMark(false)
		end
		for k,v in array:iter() do
			valueBase.write(os, v)
		end
		if array:getSize() > 0 then
			os:setUseBitMark(true)
		end
	else
		for k, v in array:iter() do
			local cname = v.__cname
			if cname == "Array" then
				CdlWriteArray(os, v)

			elseif cname == "Dictionary" then
				CdlWriteDictionary(os, v)

			elseif cname ~= nil then
				v:__write(os)
				
			end
		end
	end
end


--创建日期结构
function createDate( seconds )
	local DateTime = os.date('*t', seconds)
	
	function DateTime:init()
		return self
	end
	
	function DateTime:toSecond()
		return os.time(self)
	end
	
	function DateTime:toDate( second )
		local dateTime = os.date('*t',second)
		self.year = dateTime.year
		self.month = dateTime.month
		self.day = dateTime.day
		self.hour = dateTime.hour
		self.min = dateTime.min
		self.sec = dateTime.sec
		self.wday = dateTime.wday
		self.yday = dateTime.yday
		return self
	end

	function DateTime:toNextDate( second )
		local dateTime = os.date('*t',second)
		self.year = dateTime.year
		self.month = dateTime.month
		self.day = dateTime.day + 1
		self.hour = 0
		self.min = 0
		self.sec = 0
		self.wday = 0
		self.yday = 0
		return self
	end

	
	
	function DateTime:parseYMD( ch, value, startIndex, length, count )
		local endIndex = startIndex + count - 1
		if endIndex > length then
			return false
		end
		local buf
		if ch == 'Y' then
			if count ~= 2 and count ~= 4 then
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if count == 2 then
				buf = buf + 2000
				self.year = buf
			end
			if count == 4 then
				self.year = buf
			end
		elseif ch == 'M' then
			if count > 2 then 
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if buf > 12 or buf < 1 then
				return false
			end
			self.month = buf
		elseif ch == 'D' then
			if count > 2 then
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if buf > 31 or buf < 1 then
				return false
			end
			self.day = buf
		elseif ch == 'h' then
			if count > 2 then
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if buf > 23 or buf < 0 then
				return false
			end
			self.hour = buf
		elseif ch == 'm' then
			if count > 2 then
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if buf > 59 or buf < 0 then
				return false
			end
			self.min = buf
		elseif ch == 's' then
			if count > 2 then
				return false
			end
			buf = string.sub( value, startIndex, endIndex )
			buf = tonumber(buf)
			if buf > 59 or buf < 0 then
				return false
			end
			self.sec = buf
		else
			return false
		end
		return true
	end	

	function DateTime:parse( value, dateFormat )
		local format = dateFormat or "YYYY-MM-DD hh:mm:ss"
		local forlen = string.len(format)
		local vallen = string.len(value)
		local ch
		local index = 1
		while index <= forlen do
			local c = string.sub(format,index,index)
			if c ~= 'Y' and
				c ~= 'M' and
				c ~= 'D' and
				c ~= 'h' and
				c ~= 'm' and 
				c ~= 's' then
				index = index + 1
			else
				ch = string.sub(format,index,index)
				local count = 1
				local startIndex = index
				index = index + 1
				while string.sub(format,index,index) == ch do
					count = count + 1
					index = index + 1
				end
				flag = self:parseYMD(ch,value,startIndex,vallen,count)
				if flag == false then
					error("CDateTime Format Error!"..value)
				end 
			end
		end
		local tm = os.time(self)
		self = os.date('*t',tm)
	end

	function DateTime:asString( dateformat )
		local format = dateformat or "YYYY-MM-DD hh:mm:ss"
		local value = ""
		local length = string.len(format)
		local index = 1
		while index < length do
			local c = string.sub(format,index,index)
			if c ~= 'Y' and
				c ~= 'M' and
				c ~= 'D' and
				c ~= 'h' and
				c ~= 'm' and 
				c ~= 's' then
				index = index + 1
			else
				ch = string.sub(format,index,index)
				local count = 1
				local startindex = index
				index = index + 1
				while string.sub(format,index,index) == ch do
					count = count + 1
					index = index + 1
				end
				value,flag = self:asYMD( value, ch, format, index, count )
				if flag == false then
					error("CDateTime Format Error!"..value)
				end 
			end
		end
		return value
	end

	function DateTime:asYMD( value, ch, format, index, count )
		if index - 1 > string.len(format) then
			return value,false
		end 
		local addpart
		if ch == 'Y' then
			if count == 2 then
				addpart = math.mod(self.year,100)
				addpart = tostring(addpart)
			elseif count == 4 then
				addpart = tostring(self.year)
			else
				return value,false
			end
		elseif ch == 'M' then
			if count > 2 then
				return value,false
			end
			addpart = tostring(self.month)
		elseif ch == 'D' then
			if count > 2 then
				return value,false
			end
			addpart = tostring(self.day)
		elseif ch == 'h' then
			if count > 2 then
				return value,false
			end
			addpart = tostring(self.hour)
		elseif ch == 'm' then
			if count > 2 then
				return value,false
			end
			addpart = tostring(self.min)
		elseif ch == 's' then
			if count > 2 then
				return value,false
			end
			addpart = tostring(self.sec)
		else
			return value,false
		end
		
		if string.len(addpart) < 2 then
			addpart = '0'..addpart
		end
		value = value..addpart
		if index <= string.len(format) then
			local c = string.sub(format,index,index)
			value=value..c
		end 
		return value,true
	end

	function DateTime:ToDay()
		local tm = os.time(self)
		local totalDay = tm / ( 60 * 60 * 24 )
		return totalDay-totalDay%1
	end

	function DateTime:ToMin()
		local tm = os.time(self)
		local totalMinute = tm / 60
		return totalMinute-totalMinute%1
	end
	
	function DateTime:ToSec()
		return os.time(self)
	end

	setmetatable(DateTime, UnreadwriteableMetaTable)
	return DateTime
end

