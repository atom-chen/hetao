-------------------------
-- table扩展
-------------------------
-- 创建弱表
function new_weak_table(mode)
	assert(mode=="k" or mode=="v" or mode=="kv")
	local t = {}
	setmetatable(t, {__mode = mode})
	return t
end

-- 是否空表
table.is_empty = function(tbl)
	for _, _ in pairs(tbl) do return false end
	return true
end

-- 是否是数组
table.is_array = function(tbl)
	if type(tbl)~="table" then return false end
	return table.size(tbl) == #tbl
end

-- 移除元素
table.remove_array_element = function(tbl, value)
	local n = #tbl
	for i=n,1,-1 do
		if tbl[i] == value then
			table.remove(tbl, i)
		end
	end
end

-- 洗牌
table.shuffle = function(tbl)
	for i = #tbl, 1, -1 do
		local j = math.random(1, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

-- 元素个数
table.size = function(t)
	local n = 0
	for k,v in pairs(t) do 
		n = n + 1 
	end
	return n
end

-- value是否是表t的元素
table.has_value = function(t, value)
	for _,v in pairs(t) do
		if v==value then return true end
	end
	return false
end

-- 是否拥有相同的键
function table.has_same_key(t1, t2)
	for k,_ in pairs(t1) do
		if nil == t2[k] then return false end
	end
	for k,_ in pairs(t2) do
		if nil == t1[k] then return false end
	end
	return true
end

-- 合并
table.merge = function(dest, src)
	if type(dest) ~= "table" or type(src) ~= "table" then
		return
	end
	for k,v in pairs(src) do
		dest[k] = v
	end
	return dest
end

-- 并集
table.union = function(tbl_list)
	assert(table.is_array(tbl_list))
	local ret = {}
	for _, tbl in ipairs(tbl_list) do
		for k,v in pairs(tbl) do
			ret[k] = v
		end
	end
	return ret 
end

-- 交集
table.intersection = function(t1, t2)
	local intersection = {}
	for k,v in pairs(t1) do
		if t2[k] then
			intersection[k] = v
		end
	end
	return intersection
end

-- 是否有交集
table.has_intersection = function(t1, t2)
	for k,v in pairs(t1) do
		if t2[k] then
			return true
		end
	end
	return false
end

-----------------------------------------------------

-- 二分法查找
table.binary_search = function(array, value)
	assert(table.is_array(array), "必须为数组")
	assert(value~=nil, "要搜索的目标值不可为：nil")
	local left, right = 1, #array
	local mid = math.ceil( (left+right)/2 )
	while left < right do
		if array[mid] < value then
			left = mid + 1
		elseif array[mid] > value then
			right = mid - 1
		else 
			return mid
		end
		mid = math.ceil( (left+right)/2 )
	end
	if array[mid] == value then
		return mid
	end
end

-- 二分法查找（通过匹配函数）
table.binary_search_ex = function(array, value, cmp_func)
	assert(table.is_array(array), "必须为数组")
	assert(value~=nil, "要搜索的目标值不可为：nil")
	assert(type(cmp_func)=="function", "cmp_func必须为函数")
	local left, right = 1, #array
	local mid = math.ceil( (left+right)/2 )
	while left < right do
		local flag = cmp_func(array[mid], value)
		if flag == "L" then
			left = mid + 1
		elseif flag == "B" then
			right = mid - 1
		else
			return mid
		end
		mid = math.ceil( (left+right)/2 )
	end
	if cmp_func(array[mid],value) == "E" then
		return mid
	end
end

-- 排序插入
table.quick_insert = function(array, value, cmp_func)
	assert(table.is_array(array), "必须为数组")
	assert(value~=nil, "不可插入nil值")
	assert(cmp_func==nil or type(cmp_func)=="function", "cmp_func必须为函数或nil")
	
	if not cmp_func then
		cmp_func = function(a,b)
			return a >= b	--表示array为升序排列
		end
	end
	
	local len = #array
	local pos = len + 1
	for i = len, 1, -1 do
		if cmp_func(value,array[i]) then
			break
		end
		pos = i
	end
	table.insert(array,pos,value)
	return pos
end

-- 快速排序算法
local QuickSort
QuickSort = function(array, cmp_func, left, right)
	if left >= right then return end
	
	local i, j = left, right
	local pivotKey = array[i]
	
	while i < j do
		while i < j and cmp_func(array[j], pivotKey) do
			j = j - 1
		end
		array[i] = array[j]
			
		while i < j and cmp_func(pivotKey, array[i]) do
			i = i + 1
		end
		array[j] = array[i]
	end
	
	array[i] = pivotKey
	
	QuickSort(array, cmp_func, left, i-1)
	QuickSort(array, cmp_func, i+1, right)
end
table.quick_sort = function(array, cmp_func, left, right)
--	assert(table.is_array(array),"必须为数组")
	cmp_func = cmp_func or function(a,b)
		return a >= b
	end
	left = left or 1
	right = right or #array
	QuickSort(array, cmp_func, left, right)
end

-------------------------------------------------------------------------

-- 浅复制
table.simple_copy = function(dst, src)
	if type(src) ~= "table" or type(dst) ~= "table" then
		return 
	end
	
	for k, v in pairs(src) do
		dst[k] = v
	end
end

-- 深复制
table.copy = function(dst, src)
	if type(src) ~= "table" or type(dst) ~= "table" then
		return 
	end
	
	local level = 0
	local function copy_value(dst, src)
		level = level + 1
		if level > 20 then
			error("table clone failed, source table is too deep!")
		end
		
		for k,v in pairs(src) do
			if type(v) == "table" then
				dst[k] = dst[k] or {}
				copy_value(dst[k], v)
			else 
				dst[k] = v
			end 
		end
		
		level = level - 1
	end
	
	copy_value(dst, src)
end

-- 浅克隆
table.simple_clone = function(src)
	if type(src) ~= "table" then return src end
	local ret = {}
	for k, v in pairs(src) do
		ret[k] = v
	end
	return ret
end

-- 深克隆
table.clone = function(src)
	if type(src) ~= "table" then return src end

	local table_already_clone = {}	-- 已经复制好的table，防止嵌套复制引起的死循环

	local level = 0
	local function clone_table(t)
		level = level + 1
		if level > 20 then
			error("table clone failed, source table is too deep!")
		end
		local k, v
		local rel = {}

		table_already_clone[tostring(t)] = rel

		for k, v in pairs(t) do
			if type(v) == "table" then
				rel[k] = table_already_clone[tostring(v)] or clone_table(v)
			else
				rel[k] = v
			end
		end
		level = level - 1
		return rel
	end
	 
	return clone_table(src)
end

-------------------------------------------------------------------------

table.to_online_string = function(tb, tb_deep)
	if type(tb) ~= "table" then return end

	tb_deep = tb_deep or 20
	local cur_deep = 1
	local tb_cache = {}
	
	local function save_table(tb_data)
		-- 存储当前层table
		if type(tb_data) ~= "table"  then
			print("Error", "存储类型必须为table:", tb, tb_deep)
			return
		end
		if tb_cache[tb_data] then
			print("Error", "无法继续存储，table中包含循环引用，", tb, tb_deep)
			return
		end
		tb_cache[tb_data] = true
		
		local k, v
		cur_deep = cur_deep + 1
		if cur_deep > tb_deep then
			print("Error", "待存储table超过可允许的table深度", tb, tb_deep)
			cur_deep = cur_deep -  1
			return
		end
		
		local dststr = { "{" }

		-- 调整table存储顺序，按照key排序
		local keys_num = {}
		local keys_str = {}
		for k, v in pairs(tb_data) do
			if type(k) == "number" then
				table.insert(keys_num, k)
			elseif type(k) == "string" then
				table.insert(keys_str, k)
			end
		end
		table.sort(keys_str)
		table.sort(keys_num)

		local keys = {}
		for i, k in ipairs(keys_num) do
			table.insert(keys, k)
		end
		for i, k in ipairs(keys_str) do
			table.insert(keys, k)
		end
		for k, v in pairs(tb_data) do
			if type(k) ~= "number" and type(k) ~= "string" then
				table.insert(keys, k)
			end
		end

		-- 保存调整后的table
		local i
		for i, k in ipairs(keys) do
			v = tb_data[k]
			local arg, value
			
			local typeK = type(k)
			if typeK == "number" then
				arg = string.format("[%d]", k)   --认为key一定是整数
			elseif typeK == "string" then
				arg = string.format("[\"%s\"]", string.gsub(k,"\\","\\\\"))
			elseif typeK == "boolean" then
				arg = string.format("[%s]", tostring(k))
			end
			
			local typeV = type(v)
			if typeV == "number" then
				--value = string.format("%f", v)
				value = tostring(v)
			elseif typeV == "string" then
				value = string.format("\"%s\"", string.gsub(v,"\\","\\\\"))
			elseif typeV == "table" then
				value = save_table(v)
			elseif typeV == "boolean" then
				value = tostring(v)
			end
			
			if arg and value then
				dststr[#dststr+1] = string.format("%s,", value)
			end
		end
		
		cur_deep = cur_deep -  1
		tb_cache[tb_data] = false
		
		return string.format("%s}", table.concat(dststr))
	end

	local tb_str = save_table(tb)
	return tb_str
end

-- 将table转换为格式化的字符串
table.to_string = function(tb, tb_deep)
	if type(tb) ~= "table" then return tostring(tb) end

	tb_deep = tb_deep or 20
	local cur_deep = 1
	local tb_cache = {}
	
	local function save_table(tb_data)
		-- 存储当前层table
		if type(tb_data) ~= "table"  then
			logger.error("Error", "存储类型必须为table:", tb, tb_deep)
			return
		end
		if tb_cache[tb_data] then
			logger.error("Error", "无法继续存储，table中包含循环引用，", tb, tb_deep)
			return
		end
		tb_cache[tb_data] = true
		
		local k, v
		cur_deep = cur_deep + 1
		if cur_deep > tb_deep then
			logger.error("Error", "待存储table超过可允许的table深度", tb, tb_deep)
			cur_deep = cur_deep -  1
			return
		end
		
		local tab = string.rep(" ", (cur_deep - 1)*4)
		local dststr = { "{\n" }

		-- 调整table存储顺序，按照key排序
		local keys_num = {}
		local keys_str = {}
		for k, v in pairs(tb_data) do
			if type(k) == "number" then
				table.insert(keys_num, k)
			elseif type(k) == "string" then
				table.insert(keys_str, k)
			end
		end
		table.sort(keys_str)
		table.sort(keys_num)

		local keys = {}
		for i, k in ipairs(keys_num) do
			table.insert(keys, k)
		end
		for i, k in ipairs(keys_str) do
			table.insert(keys, k)
		end
		for k, v in pairs(tb_data) do
			if type(k) ~= "number" and type(k) ~= "string" then
				table.insert(keys, k)
			end
		end

		-- 保存调整后的table
		local i
		for i, k in ipairs(keys) do
			v = tb_data[k]
			local arg, value
			
			local typeK = type(k)
			if typeK == "number" then
				arg = string.format("[%d]", k)   --认为key一定是整数
			elseif typeK == "string" then
				arg = string.format("[\"%s\"]", string.gsub(k,"\\","\\\\"))
			elseif typeK == "boolean" then
				arg = string.format("[%s]", tostring(k))
			end
			
			local typeV = type(v)
			if typeV == "number" then
				--value = string.format("%f", v)
				value = tostring(v)
			elseif typeV == "string" then
				value = string.format("\"%s\"", string.gsub(v,"\\","\\\\"))
			elseif typeV == "table" then
				value = save_table(v)
			elseif typeV == "boolean" then
				value = tostring(v)
			end
			
			if arg and value then
				dststr[#dststr+1] = string.format("%s%s = %s,\n", tab, arg, value)
			end
		end
		
		cur_deep = cur_deep -  1
		local tab = string.rep(" ", (cur_deep - 1) * 4)
		tb_cache[tb_data] = false
		
		return string.format("%s%s}", table.concat(dststr), tab)
	end

	local tb_str = save_table(tb)
	return tb_str
end

-----------------------------------------------------------------

-- 从文件读取table，文件不存在则抛错
table.load = function(filepath)
	local Chunk = loadfile(filepath)
	assert(Chunk, "table.load失败：" .. filepath) 
	local tbl = Chunk()
	assert(type(tbl) == "table")
	return tbl 
end

table.save = function(tb, filepath, prefix_str, is_compress, tb_deep)
	assert(prefix_str==nil or type(prefix_str)=="string", "prefix_str类型错误")
	assert(type(filepath)=="string", "not valid filepath")
	if type(tb) ~= "table" then return false end
		
	local mode = is_compress and "wb" or "w"
	local file = io.open(filepath, mode)
	
	if not file then
		print("table.save失败: "..filepath)
		return false
	end
	
	local tb_str = table.to_string(tb, tb_deep)
	if prefix_str then
		file:write(prefix_str..tb_str)
	else
		file:write("return \n"..tb_str)
	end
	file:close()
	
	return true
end
