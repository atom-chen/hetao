-------------------------
-- 类定义
-------------------------
local setmetatableindex_
setmetatableindex_ = function(t, index)
    if type(t) == "userdata" then
        local peer = tolua.getpeer(t)
        if not peer then
            peer = {}
            tolua.setpeer(t, peer)
        end
        setmetatableindex_(peer, index)
    else
        local mt = getmetatable(t)
        if not mt then mt = {} end
        if not mt.__index then
            mt.__index = index
            setmetatable(t, mt)
        elseif mt.__index ~= index then
            setmetatableindex_(mt, index)
        end
    end
end
local setmetatableindex = setmetatableindex_

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

local ALL_CLASS = {}
function class(classname, ...)
	assert( classname, "no classname" )
	assert( not ALL_CLASS[classname], string.format("class is already exist: %s",classname) )
	ALL_CLASS[classname] = true
    local cls = {__cname = classname}

    local supers = {...}
    for _, super in ipairs(supers) do
        local superType = type(super)
        assert(superType == "nil" or superType == "table" or superType == "function",
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"",
                classname, superType))

        if superType == "function" then
            assert(cls.__create == nil,
                string.format("class() - create class \"%s\" with more than one creating function",
                    classname));
            -- if super is function, set it to __create
            cls.__create = super
        elseif superType == "table" then
            if super[".isclass"] then
                -- super is native class
                assert(cls.__create == nil,
                    string.format("class() - create class \"%s\" with more than one creating function or native class",
                        classname));
                cls.__create = function() return super:create() end
            else
                -- super is pure lua class
                cls.__supers = cls.__supers or {}
                cls.__supers[#cls.__supers + 1] = super
                if not cls.super then
                    -- set first super pure lua class as class.super
                    cls.super = super
                end
            end
        else
            error(string.format("class() - create class \"%s\" with invalid super type",
                        classname), 0)
        end
    end

    cls.__index = cls
    if not cls.__supers or #cls.__supers == 1 then
        setmetatable(cls, {__index = cls.super})
    else
        setmetatable(cls, {__index = function(_, key)
            local supers = cls.__supers
            for i = 1, #supers do
                local super = supers[i]
                if super[key] then return super[key] end
            end
        end})
    end

    if not cls.ctor then
        -- add default constructor
        cls.ctor = function() 
        	print("------ default constructor", classname)
        end
    end
    if not cls.dtor then
    	-- add default destructor
    	cls.dtor = function(this) 
    		print("------ default destructor", classname)
    	end
    end
    
    cls.new = function(...)
    	if cls.__inst_singleton then
        	assert(false, "ERROR: Creating Singleton Many times")
        	return cls.__inst_singleton
        end
        
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance.class = cls
        instance:ctor(...)
        
        if cls.__is_singleton then
    		cls.__inst_singleton = instance	
    	--	print("Yes Is Singleton: ", classname, cls.__inst_singleton)
    	end
    	
        return instance
    end
    cls.delete = function(cls)
    	local function _delete(obj)
			obj.dtor(cls)
			local supers = obj.__supers
			if supers then
            	for i=#supers, 1, -1 do
                	_delete(supers[i])
            	end
            end
		end
		_delete(cls)
		cls.__inst_singleton = nil
    end
    cls.create = function(_, ...)
        return cls.new(...)
    end
    
    function cls.GetInstance(...)
		if not cls.__inst_singleton then
			cls.__inst_singleton = cls.new(...)
		end
		return cls.__inst_singleton
	end
	function cls.DelInstance()
		if cls.__inst_singleton then
			cls.__inst_singleton:delete()
			cls.__inst_singleton = nil
		end
	end

    return cls
end

local iskindof_
iskindof_ = function(cls, name)
    local __index = rawget(cls, "__index")
    if type(__index) == "table" and rawget(__index, "__cname") == name then return true end

    if rawget(cls, "__cname") == name then return true end
    
    local __supers = rawget(__index, "__supers")
    if not __supers then return false end
    for _, super in ipairs(__supers) do
        if iskindof_(super, name) then return true end
    end
    
    return false
end

function iskindof(obj, classname)
    local t = type(obj)
    if t ~= "table" and t ~= "userdata" then return false end

    local mt
    if t == "userdata" then
        if tolua.iskindof(obj, classname) then return true end
        mt = tolua.getpeer(obj)
    else
        mt = getmetatable(obj)
    end
    if mt then
        return iskindof_(mt, classname)
    end
    return false
end

function GetAllClass() 
	return ALL_CLASS 
end

----------------------------------------------------

VV_NEW = function(cls, ...)
	return cls.new(...)
end

VV_DELETE = function(obj)
	
end
