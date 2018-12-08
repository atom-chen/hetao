-------------------------
-- 日志
-------------------------
local _origin_print = release_print

local function simple_filename(name)
	local begPos, endPos = string.find(name, "%/%w*%.lua")
    if begPos then
        return string.sub(name, begPos + 1, endPos)
    else
        return ""
    end
end

local function print_ex(level, ...)
	local dbgInfo = debug.getinfo(level, "lS")
	if dbgInfo and dbgInfo.source then
		_origin_print( string.format("[%s:%d]", simple_filename(dbgInfo.source), dbgInfo.currentline or -1), ... )
	else
		_origin_print(...)
	end
end

local function null_print(...)
	
end

local function level_print(...) 
	print_ex(3, ...)
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

local function dumpvalue(value, description, nesting)
    if type(nesting) ~= "number" then nesting = 10 end

    local lookupTable = {}
    local result = {}

    local traceback = string.split(debug.traceback("", 2), "\n")
    _origin_print("dump from: " .. string.trim(traceback[3]))

    local function dump_(value, description, indent, nest, keylen)
        description = description or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value_(description)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(description), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF(%s)*", indent, dump_value_(description), spc, tostring(value))
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(description))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(description))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, description, "", 1)

    for i, line in ipairs(result) do
        _origin_print(line)
    end
end

local function printf(formatStr, ...)
	print_ex(3, string.format(formatStr, ...))
end

---------------------------------------------
logger = {}

function logger.EnablePrint(bEnable)
	if bEnable then
		print = level_print
		logger.printf = printf
		logger.dump = dumpvalue
		logger.normal = level_print 
		logger.warn = level_print 
		logger.error = level_print 
		--
		logger.net = level_print
		logger.ai = level_print
		logger.state = level_print
		logger.fight = level_print
		logger.drama = level_print
		logger.game = level_print
	else
		print = null_print
		logger.printf = null_print
		logger.dump = null_print
		logger.normal = null_print 
		logger.warn = null_print 
		logger.error = null_print 
		--
		logger.net = null_print
		logger.ai = null_print
		logger.state = null_print
		logger.fight = null_print
		logger.drama = null_print
		logger.game = null_print
	end 
end
