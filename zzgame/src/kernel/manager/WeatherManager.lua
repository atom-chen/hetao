-------------------------
-- 天气系统
-------------------------
ClsWeatherManager = class("ClsWeatherManager")
ClsWeatherManager.__is_singleton = true

function ClsWeatherManager:ctor(Parent)
	self._bSnowing = false
	self._bRaining = false
	self._bFogging = false
end

function ClsWeatherManager:dtor()
	
end

function ClsWeatherManager:IsSnowing() return self._bSnowing end 
function ClsWeatherManager:IsRaining() return self._bRaining end 
function ClsWeatherManager:IsFogging() return self._bFogging end 

function ClsWeatherManager:StartSnow()
	local parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_TOPEST)
	if not parent then 
		self.mSnowEmitter = nil
		self._bSnowing = false 
		KE_SetTimeout(60, function() self:StartSnow() end)
		return false
	end
	
	if self.mSnowEmitter and tolua.isnull(self.mSnowEmitter) then
		self.mSnowEmitter = nil
	end
	
	if self.mSnowEmitter then return true end
	
	self._bSnowing = true
	self.mSnowEmitter = cc.ParticleSnow:createWithTotalParticles(500)
	local emitter = self.mSnowEmitter
	emitter:setPositionType(cc.POSITION_TYPE_GROUPED)
	local rain_batch = cc.ParticleBatchNode:createWithTexture(emitter:getTexture())
	KE_SetParent(emitter, rain_batch)
	KE_SetParent(rain_batch, parent)
	emitter:setPosition(GAME_CONFIG.DESIGN_W_2,GAME_CONFIG.DESIGN_H)
	return true
end

function ClsWeatherManager:StopSnow()
	if self.mSnowEmitter then
		KE_SafeDelete(self.mSnowEmitter)
		self.mSnowEmitter = nil 
	end
	self._bSnowing = false
end

function ClsWeatherManager:StartRain()
	
end

function ClsWeatherManager:StopRain()
	
end

function ClsWeatherManager:StartFog()

end

function ClsWeatherManager:StopFog()

end
