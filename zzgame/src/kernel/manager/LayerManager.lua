-------------------------
-- 层管理器
-------------------------
ClsLayerManager = class("ClsLayerManager")
ClsLayerManager.__is_singleton = true

function ClsLayerManager:ctor()
	self.tAllLayers = new_weak_table("v")
end

function ClsLayerManager:dtor()
	
end

function ClsLayerManager:InitLayer(iLayerId, parent)
	assert(TYPE_CHECKER.IsValidGameLayerId(iLayerId), "未定义层："..iLayerId)
	assert(not self.tAllLayers[iLayerId])
	self.tAllLayers[iLayerId] = clsLayer.new()
	parent:addChild(self.tAllLayers[iLayerId], iLayerId)
	self.tAllLayers[iLayerId]:AddScriptHandler(const.CORE_EVENT.cleanup, function()
		self.tAllLayers[iLayerId] = nil
	end)
end

function ClsLayerManager:SetKeyboardAniDelegate(objList, fixHeight)
	self._keyboardAniDelegates = objList
	self._keyboardFixHeight = fixHeight
end

function ClsLayerManager:StopFixLayer()
	local aniObjs = self._keyboardAniDelegates or self.tAllLayers
	for _, obj in pairs(aniObjs) do
		if not tolua.isnull(obj) then
			obj:stopAllActions()
		end
	end
end

local MAXKBDH = 0
function ClsLayerManager:FixLayerPos(Hei, duration)
	local aniObjs = self._keyboardAniDelegates or self.tAllLayers
	MAXKBDH = math.max(MAXKBDH or 0, SalmonUtils:getKeyboardHei() or 0)
	if Hei > 0 and self._keyboardAniDelegates and self._keyboardFixHeight then
		Hei = MAXKBDH + self._keyboardFixHeight
	elseif Hei > 0 and self._keyboardAniDelegates then
		Hei = MAXKBDH
	end
	duration = duration or 0
	
	for _, obj in pairs(aniObjs) do
		if not tolua.isnull(obj) then
			obj:stopAllActions()
		end
	end
	
	if duration <= 0 then 
	    for _, obj in pairs(aniObjs) do
	        if not tolua.isnull(obj) then
	            obj:setPositionY(Hei)
	        end
	    end
	else
		for _, obj in pairs(aniObjs) do
	        if not tolua.isnull(obj) then
	            obj:runAction(cc.MoveTo:create(duration, cc.p(obj:getPositionX(), Hei)))
	        end
	    end
	end
end

function ClsLayerManager:GetLayer(iLayerId)
	assert(TYPE_CHECKER.IsValidGameLayerId(iLayerId), "未定义层："..iLayerId)
	return self.tAllLayers[iLayerId]
end

function ClsLayerManager:ShowLayer(iLayerId, bShow)
	assert(TYPE_CHECKER.IsValidGameLayerId(iLayerId), "未定义层："..iLayerId)
	if bShow == nil then bShow = true end
	if self.tAllLayers[iLayerId] then
		self.tAllLayers[iLayerId]:setVisible(bShow)
	end
end

function ClsLayerManager:ShowAllLayer(bShow)
	if bShow == nil then bShow = true end
	local curScene = ClsSceneManager.GetInstance():GetCurScene()
	if not curScene then return end
	for _, layer in pairs(self.tAllLayers) do 
		layer:setVisible(bShow)
	end 
end
