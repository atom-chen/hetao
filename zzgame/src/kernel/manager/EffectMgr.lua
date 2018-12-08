-------------------------
--特效管理器
-------------------------
ClsEffectMgr = class("ClsEffectMgr")
ClsEffectMgr.__is_singleton = true

function ClsEffectMgr:ctor()
	self.tAllEffects = {}
end

function ClsEffectMgr:dtor()
	for effID, Eff in pairs(self.tAllEffects) do
		KE_SafeDelete(Eff)
	end
	self.tAllEffects = nil
end

-- 创建序列帧特效
function ClsEffectMgr:CreateEffectSeq(effectID, res_path, parent, iLoopTimes)
	if self.tAllEffects[effectID] then
		logger.warn("effect is already exist", effectID)
		return self.tAllEffects[effectID]
	end
	self.tAllEffects[effectID] = clsEffectSeq.new(effectID, res_path, parent, iLoopTimes, function()
		self.tAllEffects[effectID] = nil
	end)
	return self.tAllEffects[effectID]
end

-- 创建粒子特效
function ClsEffectMgr:CreateParticle(effectID, res_path, parent)
	if self.tAllEffects[effectID] then
		logger.warn("effect is already exist", effectID)
		return self.tAllEffects[effectID]
	end
	
	self.tAllEffects[effectID] = utils.CreateParticleSystemQuad(parent, res_path, cc.POSITION_TYPE_GROUPED, function()
		self.tAllEffects[effectID] = nil
	end)
	return self.tAllEffects[effectID]
end

-- 销毁
function ClsEffectMgr:DestroyEffect(effectID)
	if self.tAllEffects[effectID] then
		KE_SafeDelete(self.tAllEffects[effectID])
		self.tAllEffects[effectID] = nil
	end
end

-- 获取
function ClsEffectMgr:GetEffect(effectID)
	return self.tAllEffects[effectID]
end
