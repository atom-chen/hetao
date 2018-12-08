-------------------------
-- 序列帧特效
-------------------------
clsEffectSeq = class("clsEffectSeq", function() return cc.Sprite:create() end)

function clsEffectSeq:ctor(effectID, res_path, parent, loop_times, cbPlayOver)
	self:EnableNodeEvents()
	self.Uid = effectID
	self.sResPath = res_path
	self.iLoopTimes = loop_times or 1
	self.bLoaded = false
	self.cbPlayOver = cbPlayOver
	if parent then KE_SetParent(self, parent) end
	self:_LoadBody()
end

function clsEffectSeq:dtor()
	self:_UnloadBody()
	self.cbPlayOver = nil
end

function clsEffectSeq:_LoadBody()
	if self.bLoaded then return end
	self.bLoaded = true
--	ClsResManager.GetInstance():AddSpriteFrames(self.sResPath)
	cc.SpriteFrameCache:getInstance():addSpriteFrames(self.sResPath)
	
	local EffName = string.sub(self.sResPath, 1, -7)
	local InstSprFrameCache = cc.SpriteFrameCache:getInstance()
	local aniFrames = {}
	local frameIdx = 1
	while true do
		local frameName = string.format("%s/t%d.png", EffName, frameIdx)
	    local spriteFrame = InstSprFrameCache:getSpriteFrame(frameName)
		if not spriteFrame then break end
		aniFrames[frameIdx] = spriteFrame
		frameIdx = frameIdx + 1
	end
	
	self.iTotalFrame = #aniFrames
	self.aniFrames = aniFrames
	if self.iTotalFrame > 0 then
		self:Play()
	else
		print(debug.traceback())
	end
end

function clsEffectSeq:_UnloadBody()
	if self.bLoaded then
	--	ClsResManager.GetInstance():SubSpriteFrames(self.sResPath)
		self.bLoaded = false
	end
end

function clsEffectSeq:Play()
	local animation = cc.Animation:createWithSpriteFrames(self.aniFrames, 0.1, self.iLoopTimes)
   	self:runAction(cc.Sequence:create(
   		cc.Animate:create(animation), 
   		cc.CallFunc:create(function()
   			if self.cbPlayOver then 
   				self.cbPlayOver() 
   				self.cbPlayOver = nil
   			end
   		end),
   		cc.RemoveSelf:create()
   	))
end

function clsEffectSeq:GetUid() return self.Uid end
function clsEffectSeq:GetResPath() return self.sResPath end
function clsEffectSeq:GetTotalFrame() return self.iTotalFrame end
