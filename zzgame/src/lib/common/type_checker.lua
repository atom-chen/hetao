-------------------------
-- 数据类型检查
-------------------------
local TYPE_INT 		= "number" 		-- type(0)
local TYPE_STRING 	= "string"		-- type("")
local TYPE_BOOL 	= "boolean"		-- type(true)
local TYPE_TABLE 	= "table"		-- type({})
local TYPE_USERDATA = "userdata"	-- 
local TYPE_FUNCTION	= "function"	-- type(function() end)
local TYPE_NIL		= "nil"			-- type(nil)
local TYPE_THREAD	= "thread"		-- 

function is_number(obj) return type(obj) == TYPE_INT end
function is_string(obj) return type(obj) == TYPE_STRING end
function is_boolean(obj) return type(obj) == TYPE_BOOL end
function is_table(obj) return type(obj) == TYPE_TABLE end
function is_userdata(obj) return type(obj) == TYPE_USERDATA end
function is_function(obj) return type(obj) == TYPE_FUNCTION end
function is_nil(obj) return obj == nil end
function is_thread(obj) return type(obj) == TYPE_THREAD end

TYPE_CHECKER = {
	--
	INT = function(value) return type(value)==TYPE_INT, string.format("类型必须为【number】，当前为【%s】",type(value)) end,
	UINT = function(value) return value > 0, string.format("必须为【正数】，当前为【%s】",type(value)) end,
	STRING = function(value) return type(value)==TYPE_STRING, string.format("类型必须为：【string】，当前为【%s】",type(value)) end,
	BOOL = function(value) return type(value)==TYPE_BOOL, string.format("类型必须为：【boolean】，当前为【%s】",type(value)) end,
	TABLE = function(value) return type(value)==TYPE_TABLE, string.format("类型必须为：【table】，当前为【%s】",type(value)) end,
	USERDATA = function(value) return type(value)==TYPE_USERDATA, string.format("类型必须为：【userdata】，当前为【%s】",type(value)) end,
	FUNC = function(value) return type(value)==TYPE_FUNCTION, string.format("类型必须为：【function】，当前为【%s】",type(value)) end,
	--
	INT_NIL = function(value) return value==nil or type(value)==TYPE_INT, string.format("类型必须为：【number or nil】，当前为【%s】",type(value)) end,
	UINT_NIL = function(value) return value==nil or value>0, string.format("必须为【nil】或【正数】，当前为【%s】",type(value)) end,
	STRING_NIL = function(value) return value==nil or type(value)==TYPE_STRING, string.format("类型必须为：【string or nil】，当前为【%s】",type(value)) end,
	BOOL_NIL = function(value) return value==nil or type(value)==TYPE_BOOL, string.format("类型必须为：【boolean or nil】，当前为【%s】",type(value)) end,
	TABLE_NIL = function(value) return value==nil or type(value)==TYPE_TABLE, string.format("类型必须为：【table or nil】，当前为【%s】",type(value)) end,
	USERDATA_NIL = function(value) return value==nil or type(value)==TYPE_USERDATA, string.format("类型必须为：【userdata or nil】，当前为【%s】",type(value)) end,
	FUNC_NIL = function(value) return value==nil or type(value)==TYPE_FUNCTION, string.format("类型必须为：【function or nil】，当前为【%s】",type(value)) end,
	--
	ANY = function() return true end,
}
