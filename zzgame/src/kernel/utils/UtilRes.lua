-------------------------
-- 辅助库
-------------------------
module("utils", package.seeall)

is_lua_file = function(sPath) return string.find(sPath,"%.lua$") end
is_png_file = function(sPath) return string.find(sPath,"%.png$") end
is_jpg_file = function(sPath) return string.find(sPath,"%.jpg$") end

local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()

-- utils.CreateObject(parent, {sResType="particle",sResPath="res/effects/particles/SmallSun.plist",iPositionType=0x2})
-- utils.CreateObject(parent, {sResType="EffectSeq",sResPath="res/effects/effect_seq/bingpo.plist"})
-- utils.CreateObject(parent, {sResType="Sprite",sResPath="res/effects/effect_img/huoqiu.png"})
function CreateObject(parent, info)
	local obj 
	local sResType = info.sResType
	if sResType == "particle" then
		obj = utils.CreateParticleSystemQuad(parent, info.sResPath, info.iPositionType, info.callback)
	elseif sResType == "EffectSeq" then
		obj = utils.CreateEffectSeq(parent, info.sResPath, info.iLoopTimes, info.callback)
	elseif sResType == "Sprite" then
		obj = utils.CreateSprite(info.sResPath, parent)
	end
	assert(obj, string.format("创建对象失败：%s, %s",sResType,info.sResPath))
	return obj
end

function CreateCsbEffect(res_path, parent)
	local obj = cc.CSLoader:createNode(res_path)
	obj._ani_timeline = cc.CSLoader:createTimeline(res_path)
	obj:runAction(obj._ani_timeline)
	obj._ani_timeline:gotoFrameAndPlay(0, false)
	if parent then parent:addChild(obj) end
	KE_SetAbsTimeout(6, function()
		if tolua.isnull(obj) then return end
		obj:removeSelf()
	end)
	return obj
end

function CreateEffectSeq(parent, res_path, iLoopTimes, callback)
	return clsEffectSeq.new(nil, res_path, parent, iLoopTimes, callback)
end

-- 创建粒子特效
--@param    pos_type    cc.POSITION_TYPE_GROUPED,cc.POSITION_TYPE_RELATIVE,cc.POSITION_TYPE_FREE 
function CreateParticleSystemQuad(parent, res_path, pos_type, onPlayOver)
	local emitter = cc.ParticleSystemQuad:create(res_path)
	emitter:setPositionType(pos_type)
	emitter:setAutoRemoveOnFinish(true)
	emitter:registerScriptHandler(function(state)
		if state == "cleanup" then
			if onPlayOver then onPlayOver() end
		end
	end)
	if parent then KE_SetParent(emitter,parent) end
	return emitter
end



function CreateNode(parent)
	local obj = cc.Node:create()
	if parent then KE_SetParent(obj,parent) end
	return obj
end

function CreateLayer(parent)
	local obj = cc.Layer:create()
	if parent then KE_SetParent(obj,parent) end
	return obj
end

function CreateScene()
	return cc.Scene:create()
end

function CreateImageView(ResPath, parent)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(ResPath)
	local newobj 
	if sprFrame then
		newobj = ccui.ImageView:create(ResPath, ccui.TextureResType.plistType)
	else
		newobj = ccui.ImageView:create(ResPath)
	end
	if not newobj then
		error(string.format("创建ImageView失败：%s", ResPath))
		return nil 
	end
	if parent then KE_SetParent(newobj, parent) end 
	return newobj
end

function CreateSprite(ResPath, parent)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(ResPath)
	local newobj 
	if sprFrame then
		newobj = cc.Sprite:createWithSpriteFrameName(ResPath)
	else
		newobj = cc.Sprite:create(ResPath)
	end
	if not newobj then
		logger.error(string.format("创建Sprite失败：%s", ResPath))
		return nil 
	end
	if parent then KE_SetParent(newobj, parent) end 
	return newobj
end

function CreateScale9Sprite(ResPath, parent)
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(ResPath)
	local newobj 
	if sprFrame then
		newobj = cc.Scale9Sprite:createWithSpriteFrameName(ResPath)
	else
		newobj = cc.Scale9Sprite:create(ResPath)
	end
	if not newobj then
		error(string.format("创建Scale9Sprite失败：%s", ResPath))
		return nil
	end
	if parent then KE_SetParent(newobj, parent) end 
	return newobj
end

-- 创建序列帧动画
function CreateSeqSprite(parent, res_path, loop_times, onPlayOver)
	local EffName = FileHelper.GetFileName(res_path)
	assert(EffName, "解析特效名失败："..res_path)
	
	ClsResManager.GetInstance():AddSpriteFrames(res_path)
	
	local aniFrames = {}
	local frameIdx = 0
	while true do
		local frameName = string.format("%s_%d.png", EffName, frameIdx)
	    local spriteFrame = _InstSpriteFrameCache:getSpriteFrame(frameName)
		if not spriteFrame then break end
		aniFrames[#aniFrames+1] = spriteFrame
		frameIdx = frameIdx + 1
	end
	
	local iTotalFrame = #aniFrames
	assert(iTotalFrame>0, "无效的特效：总帧数小于1"..iTotalFrame)
	
	local obj = cc.Sprite:create()
	obj.iTotalFrame = iTotalFrame
	
	if parent then KE_SetParent(obj,parent) end
	
	obj:registerScriptHandler(function(state)
		if state == "cleanup" then
			ClsResManager.GetInstance():SubSpriteFrames(res_path)
		end
	end)
	
	local animation = cc.Animation:createWithSpriteFrames(aniFrames, 0.08, loop_times)
   	obj:runAction(cc.Sequence:create(
   		cc.Animate:create(animation), 
   		cc.CallFunc:create(function()
   			if onPlayOver then onPlayOver() end
   		end),
   		cc.RemoveSelf:create()
   	))
   	
   	return obj
end

function CreateArmSprite()
	assert(false,"尚未实现")
end

function CreateSpineSprite()
	assert(false,"尚未实现")
end

function CreateLayout(parent, ResPath)
	local newobj = ccui.Layout:create()
	if not newobj then
		error(string.format("加载图片失败：%s", ResPath))
		return 
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end 

function CreateButton(imgNormal, imgSelected, imgDisable, parent)
	local newobj = ccui.Button:create(imgNormal, imgSelected, imgDisable)
	if not newobj then
		error(string.format("创建按钮失败：%s, %s, %s", imgNormal, imgSelected, imgDisable))
		return nil
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end

function CreateRadioButton(parent, imgUnselected, imgSelected)
	local newobj = ccui.RadioButton:create(imgUnselected, imgSelected) 
	if not newobj then
		error(string.format("加载图片失败：%s, %s", imgUnselected, imgSelected))
		return 
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end 

function CreateLoadingBar(parent, ResPath, iPercentage)
	local newobj = ccui.LoadingBar:create(ResPath, iPercentage) 
	if not newobj then
		error(string.format("加载图片失败：%s", ResPath))
		return 
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end

function CreateEditor(parent, wid, hei, imgNormal)
	local newobj = ccui.EditBox:create(cc.size(wid,hei), imgNormal) 
	if not newobj then
		error(string.format("加载图片失败：%s", imgNormal))
		return 
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end 

function CreateRichText(parent, sContent)
	local newobj = utils.CreateLabel(sContent, 24)
	if not newobj then
		error(string.format("创建富文本失败：%s", sContent or ""))
		return 
	end
	if parent then KE_SetParent(newobj, parent) end
	return newobj
end

function CreateLabel(str, fontSize, fontColor, bForceSys)
	local font = const.FONT_CFG(fontSize)
	local label
	if not bForceSys and cc.FileUtils:getInstance():isFileExist(font.fontFilePath) then
		local scaleFactor = g_ContentScaleFactor
		font.fontSize = font.fontSize * scaleFactor
		
		label = cc.Label:createWithTTF(font, str or "")
		if label and fontColor then
			label:setColor(fontColor)
		end
		label:setScale(1/scaleFactor)
	else
		label = cc.Label:create()
		if fontSize then label:setSystemFontSize(fontSize) end
		if str then label:setString(str) end
		if fontColor then label:setTextColor(fontColor) end
	end
	return label
end

function CreateModel(parent, fileName)
	local newobj = cc.Sprite3D:create(fileName)
	if not newobj then
		error(string.format("加载模型失败：%s", fileName))
		return nil 
	end
	if parent then KE_SetParent(newobj, parent) end 
	newobj:setGlobalZOrder(1)
	return newobj
end
