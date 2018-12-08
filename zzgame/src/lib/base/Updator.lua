-------------------------
-- 游戏逻辑更新
-------------------------
ClsUpdator = class("ClsUpdator")
ClsUpdator.__is_singleton = true

local MINORDER = 1
ClsUpdator.ORDER_ROLE = 1
ClsUpdator.ORDER_BULLET = 2
ClsUpdator.ORDER_CAMERA = 3
ClsUpdator.ORDER_PHYSICS = 4
ClsUpdator.ORDER_UI = 5
local MAXORDER = 5

function ClsUpdator:ctor()
	self._isUpdating = false
	self._tAllUpdators = {
		[ClsUpdator.ORDER_ROLE] = {},
		[ClsUpdator.ORDER_BULLET] = {},
		[ClsUpdator.ORDER_CAMERA] = {},
		[ClsUpdator.ORDER_PHYSICS] = {},
		[ClsUpdator.ORDER_UI] = {},
	}
end

function ClsUpdator:dtor()
	self._tAllUpdators = nil
end

function ClsUpdator:HasUpdator(func, obj)
	for _, updates in pairs(self._tAllUpdators) do
		for i, data in ipairs(updates) do
			if func==data[1] and obj==data[2] then
				return true
			end
		end
	end
	return false
end

function ClsUpdator:RegisterUpdator(func, obj, order)
	assert(order>=MINORDER and order<=MAXORDER, "错误的优先级")
	if self:HasUpdator(func, obj) then return end
	table.insert(self._tAllUpdators[order], {func, obj})
end

function ClsUpdator:UnregisterUpdator(func, obj)
	for _, updates in pairs(self._tAllUpdators) do
		for i, data in ipairs(updates) do
			if func==data[1] and obj==data[2] then
				table.remove(updates, i)
				return
			end
		end
	end
end

--@每帧更新
function ClsUpdator:FrameUpdate(deltaTime)
	self._isUpdating = true
	local updators
	for i=1, 5 do
		updators = self._tAllUpdators[i]
		for _, data in ipairs(updators) do
			data[1](data[2], deltaTime)
		end
	end
	self._isUpdating = false
end
