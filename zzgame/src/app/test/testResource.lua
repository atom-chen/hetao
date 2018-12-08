----------------------
-- test 3D
----------------------
local test = {}

function test.TestRenderTex(par)
	local renderTexture = cc.RenderTexture:create(500,12,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	renderTexture:beginWithClear(0,0,0,0)
	--[[
	local drNode = cc.DrawNode:create()
	drNode:setLineWidth(2)
	local SPACE = 5
	local color
	local pt1 = cc.p(0,0)
	local pt2 = cc.p(0,0)
	local color = cc.c4f(1, 1, 1, 1)
	pt1.x = 3
	pt1.y = 3
	pt2.x = 61
	pt2.y = 61
	drNode:drawRect(pt1, pt2, color)
	drNode:visit()
	]]
	local drNode = utils.CreateScale9Sprite("launcher/progress_green.png")
	drNode:setScale9Enabled(true)
	drNode:setAnchorPoint(cc.p(0,0))
	drNode:setContentSize(500,10)
--	drNode:setCapInsets(cc.rect(50,50,680,112))
--	drNode:setColor(cc.c4b(222,3,3,255))
	drNode:visit()
	
	renderTexture:endToLua()
	renderTexture:saveToFile("progress_green.png", cc.IMAGE_FORMAT_PNG)
end

function test.TestParticle(parent)
	local res_path = "particles/SmallSun.plist"
	utils.CreateParticleSystemQuad(parent, res_path, cc.POSITION_TYPE_GROUPED, function()
		logger.normal("滴滴滴 销毁粒子", res_path)
	end)
	
	local res_path = "res/effects/effect_seq/bingpo.plist"
	utils.CreateSeqSprite(parent, res_path, 2, function()
		logger.normal("啊啊啊 销毁序列帧", res_path)
	end):setPosition(555,0)
end

-- 人物
-- 坐骑 1240001 --- 1240016    时装坐骑 5040001 --- 5040009
-- 翅膀 1230001 --- 1230016    时装翅膀 5050001 --- 5050008
-- 武器
function test.TestSeqSprite(parent, plistName, aniName, dir8)
	assert(const.ANINAME[sAniKey], "Error: 无效的动作名: "..sAniKey)
	assert(dir8>=0 and dir8<=7)
	--
	local spr2d = cc.Sprite:create()
	parent:addChild(spr2d)
	spr2d:setPosition(80,400)
	--
	for i=0, 2 do
		ClsResManager.GetInstance():AddSpriteFrames( string.format("res/role2d/%s%d.plist",plistName,i) )
	end
	--
	local dirKey = dir8 
	if (dir8 > 4) then dirKey = 8 - dir8 end
	local EffName = string.format("%s/%s_d%d_",plistName,aniName,dirKey)
	spr2d:setFlippedX(dir8>4)
	--
	local InstSprFrameCache = cc.SpriteFrameCache:getInstance()
	local aniFrames = {}
	for frameIdx=0, 5 do
		local frameName = string.format("%s%d.png", EffName, frameIdx)
	    local spriteFrame = InstSprFrameCache:getSpriteFrame(frameName)
	    if spriteFrame then
	    	aniFrames[#aniFrames+1] = spriteFrame
	    else
	    	aniFrames[#aniFrames+1] = aniFrames[#aniFrames]
	    end
	end
	assert(#aniFrames>0, "无效的特效：总帧数小于1")
	local animation = cc.Animation:createWithSpriteFrames(aniFrames, 0.12)
   	spr2d:runAction( cc.RepeatForever:create(cc.Animate:create(animation)) )
   	--
   	spr2d:registerScriptHandler(function(evtName)
		if evtName == "cleanup" then 
			for i=0,2 do
				ClsResManager.GetInstance():SubSpriteFrames(string.format("res/role2d/%s%d.plist",plistName,i))
			end
		end
	end)
end

return test 
