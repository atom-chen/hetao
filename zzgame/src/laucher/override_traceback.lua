-------------------------
-- 日志
-------------------------

function __G__TRACKBACK__(e)
	local errStr = ""
	print("----------------------------------")
	
	local max_level = 0
	while true do
		local info = debug.getinfo(max_level + 1, "n")
		if not info then break end
		max_level = max_level + 1
	end
	
	local errinfo = {}
	table.insert(errinfo, tostring(e))
	for level = 2, max_level do
		local info = debug.getinfo(level, 'nfSlu')
		assert(info)
		if info.what == "C" then
			if info.name ~= nil then
				table.insert(errinfo, string.format('\t<%2d> [C] : in %s', level - 1, info.name))
			else
				table.insert(errinfo, string.format('\t<%2d> [C] :', level - 1))
			end
		else
			if info.name ~= nil then
				table.insert(errinfo , string.format('\t<%2d> %s:%d in %s', level - 1, info.source, info.currentline, info.name))
			else
				table.insert(errinfo, string.format('\t<%2d> %s:%d', level - 1, info.source, info.currentline))
			end
			
			if info.func then
				local i = 1
				while true do
					local name, value = debug.getupvalue(info.func, i)
					if not name then break end
					table.insert(errinfo, string.format("\t\t %s : %s",
						type(name) == "string" and string.format("\"%s\"",name) or tostring(name),
						type(value) == "string" and string.format("\"%s\"",value) or tostring(value)))
					i = i + 1
				end
			end
			
			local i = 1
			while true do
				local name, value = debug.getlocal(level, i)
				if not name then break end
				table.insert(errinfo, string.format("\t\t %s : %s",
					type(name) == "string" and string.format("\"%s\"",name) or tostring(name),
					type(value) == "string" and string.format("\"%s\"",value) or tostring(value)))
				i = i + 1
			end
		end
	end
	
	errStr = table.concat(errinfo, "\n")
	print(errStr)
	print("----------------------------------")
	
	local target = cc.Application:getInstance():getTargetPlatform()
	if target == cc.PLATFORM_OS_ANDROID or target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
		buglyReportLuaException(tostring(e), errStr)
	end
	
	--辅助调试，发布版会跳过下面的代码
	if device.platform == "windows" and FileHelper then
--		local filename = string.format( "errorlog/%s.lua", os.date("%Y-%m-%d_%H-%M-%S", os.time()) )
		local filename = string.format( "errorlog/%s.lua", os.date("%d_%H-%M-%S", os.time()) )
		FileHelper.SaveTable(errinfo, filename)
	end
	
	if IS_DEBUG_MODE then
--		cc.Director:getInstance():setAnimationInterval(0.5)
		local theScene = cc.Director:getInstance():getRunningScene()
		if ccui and theScene then
			theScene._err_tip_cnt = theScene._err_tip_cnt or 0
			if theScene._err_tip_cnt < 10 then
				theScene._err_tip_cnt = theScene._err_tip_cnt + 1 
				local designW = GAME_CONFIG and GAME_CONFIG.DESIGN_W or 720
				local designH = GAME_CONFIG and GAME_CONFIG.DESIGN_H or 1280
				local halfDesignW = designW / 2 
				local halfDesignH = designH / 2
				
				local btnclose = ccui.Layout:create()
				btnclose:setContentSize(designW, designH)
				btnclose:setBackGroundColorType(1)
				btnclose:setBackGroundColor({ r = 222, g = 222, b = 222 })
				btnclose:setTouchEnabled(true)
				btnclose:setAnchorPoint({ x = 0, y = 0 })
				btnclose:addTouchEventListener( function(sender, touchType)
					-- ccui.TouchEventType.ended = 2
					if touchType == 2 then btnclose:removeFromParent() end
				end )
				theScene:addChild(btnclose,99)
				
				local labTips = cc.Label:create()
				labTips:setSystemFontSize(28)
				labTips:setString("有BUG 截图给程序")
				labTips:setTextColor({ r=250, g=0, b=0 })
				btnclose:addChild(labTips)
				labTips:setPosition(halfDesignW, designH-30)
				
				local labErr = cc.Label:create()
				labErr:setSystemFontSize(24)
				labErr:setString(errStr)
				labErr:setTextColor({ r = 0, g = 0, b = 0 })
				labErr:setLineBreakWithoutSpace(true)
				labErr:setMaxLineWidth(720)
				labErr:setDimensions(720, 0)
				labErr:setLineBreakWithoutSpace(true)
				labErr:setAnchorPoint(cc.p(0,1))
				labErr:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
				
				local view = ccui.ScrollView:create()
				view:setDirection(ccui.ScrollViewDir.vertical)
				view:setBounceEnabled(true)
				view:setBackGroundColorType(1)
				view:setBackGroundColor({ r=111, g=111, b=111 })
				view:setContentSize({ width = designW, height = designH-100 })
				view:setPosition(0,0)
				btnclose:addChild(view,99)
				
				view:addChild(labErr)
				local sz = labErr:getContentSize()
				view:setInnerContainerSize(sz)
				labErr:setPosition(0,view:getInnerContainerSize().height)
			end
		end
	end 
end
