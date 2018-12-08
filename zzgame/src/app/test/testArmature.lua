----------------------
-- tests: 2D骨骼动画
----------------------
local test = {}

-- 测试：异步加载
function test.arm_async_load(parent, x, y)
	x = x or 100 
	y = y or 300
	--[[
	local function imageLoaded(texture)
		logger.normal("---------- imageLoaded aaaaaaaaa")
			local tmpSprite = cc.Sprite:createWithTexture(texture)
	        -- tmpSprite:setTexture(texture)
			tmpSprite:setIgnoreAnchorPointForPosition(true)
			KE_SetParent(tmpSprite, parent, 99)
			tmpSprite:setPosition(300,400)
    end
	cc.Director:getInstance():getTextureCache():addImageAsync("map/1001/0_0.png", imageLoaded)
	cc.Director:getInstance():getTextureCache():unbindImageAsync("map/1001/0_0.png")
	]]
	---- 1 ---------------------
	local bearLoaded = function(percent)
		if percent >= 1 then
			logger.normal("------------ bearLoaded", percent)
			local arm2 = ccs.Armature:create("bear")
		    arm2:getAnimation():playWithIndex(0)
		    arm2:setPosition(x, y)
		    KE_SetParent(arm2, parent)
		    
		    --监听动画事件
		    local function onAnimationEvent(obj, evtName, aniName)
--		    	logger.normal("+++++++ onAnimationEvent:", evtName, aniName)
		    end
		    arm2:getAnimation():setMovementEventCallFunc(onAnimationEvent)
		    
		    -- 监听帧事件
		    local function onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex)
--		        logger.normal("++++ ++++ onFrameEvent", bone, evt, originFrameIndex, currentFrameIndex)
		    end
		    arm2:getAnimation():setFrameEventCallFunc(onFrameEvent)
		end
	end
	ClsResManager.GetInstance():AddArmatureFileInfo("tests/arm_test/bear.ExportJson")
	bearLoaded(1)
	
	---- 2 ---------------------
	local CowboyLoaded = function(percent)
		if percent >= 1 then
			logger.normal("------------ CowboyLoaded", percent)
			local arm2 = ccs.Armature:create("Cowboy")
		    arm2:setPosition(x+140, y+100)
		    arm2:setScale(0.1)
		    KE_SetParent(arm2, parent)
		    arm2:getAnimation():play("FireMax")
		    
		    --监听动画事件
		    local function onAnimationEvent(obj, evtName, aniName)
--		    	logger.normal("+++++++ onAnimationEvent:", evtName, aniName)
		    end
		    arm2:getAnimation():setMovementEventCallFunc(onAnimationEvent)
		    
		    -- 监听帧事件
		    local function onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex)
--		        logger.normal("++++ ++++ onFrameEvent", bone, evt, originFrameIndex, currentFrameIndex)
		    end
		    arm2:getAnimation():setFrameEventCallFunc(onFrameEvent)
		end
	end
	ClsResManager.GetInstance():AddArmatureFileInfo("tests/arm_test/Cowboy.ExportJson")
	CowboyLoaded(1)
	
	---- 3 ---------------------
	local robotLoaded = function(percent)
		logger.normal("---- percent", percent)
		if percent >= 1 then
			logger.normal("------------ robotLoaded", percent)
			
			-- 创建骨骼动画
			local arm2 = ccs.Armature:create("w10010")
		    arm2:setPosition(x+100, y)
		    arm2:setScale(0.4)
		    KE_SetParent(arm2, parent)
		    arm2:getAnimation():play(const.ANINAME.walk, 60*5, 1)
		    
		    -- 添加挂件
		    local sprTest = ccs.Armature:create("Cowboy")
		    sprTest:getAnimation():playWithIndex(0)
		    --local sprTest = cc.Sprite:create("tests/arm_test/bear0.png")
		    sprTest:setAnchorPoint(cc.p(0.5, 0.5))
		    sprTest:setIgnoreAnchorPointForPosition(true)
		    local bone = ccs.Bone:create("sprTest")
		    bone:addDisplay(sprTest, 0)
		    bone:changeDisplayWithIndex(0, true)
		    bone:setIgnoreMovementBoneData(true)
		    bone:setLocalZOrder(100)
		    bone:setScale(0.2)
		    arm2:addBone(bone, "bady-a3")
		    
		    --监听动画事件
		    local function onAnimationEvent(obj, evtName, aniName)
--		    	logger.normal("+++++++ onAnimationEvent:", evtName, aniName)
		    	if evtName == ccs.MovementEventType.loopComplete then
			    	if aniName == const.ANINAME.run then
			    		obj:getAnimation():play(const.ANINAME.walk)
			    	elseif aniName == const.ANINAME.walk then 
			    		obj:getAnimation():play(const.ANINAME.run)
			    	end
			    end
		    end
		    arm2:getAnimation():setMovementEventCallFunc(onAnimationEvent)
		    
		    -- 监听帧事件
		    local function onFrameEvent( bone, evt, originFrameIndex, currentFrameIndex)
--		        logger.normal("++++ ++++ onFrameEvent", bone, evt, originFrameIndex, currentFrameIndex)
		    end
		    arm2:getAnimation():setFrameEventCallFunc(onFrameEvent)
		end
	end
	ClsResManager.GetInstance():AddArmatureFileInfoAsync("tests/arm_test/w10010.png", "tests/arm_test/w10010.plist", "tests/arm_test/w10010.xml", robotLoaded)
end

-- 测试：同步加载
function test.arm_direct_load(parent)
	ClsResManager.GetInstance():AddArmatureFileInfo("tests/arm_test/bear.ExportJson")
	local armature = ccs.Armature:create("bear")
	armature:getAnimation():playWithIndex(0)
	armature:setPosition(100, 300)
	KE_SetParent(armature, parent)
end

return test
