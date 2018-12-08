-------------------------
-- 游戏辅助库
-------------------------
module("gameutil", package.seeall)

function MarkAllLoaded(listWnd)
	if not utils.IsValidCCObject(listWnd) then return end
	if not utils.IsValidCCObject(listWnd.markAllLoaded) then
		local sz = listWnd:getContentSize()
		listWnd.markAllLoaded = ccui.Layout:create()
		listWnd.markAllLoaded:setContentSize(sz.width, 66)
		listWnd.markAllLoaded:setBackGroundColorType(1)
		listWnd.markAllLoaded:setBackGroundColor(cc.c3b(255,255,255))
		local lblAllLoaded = utils.CreateLabel("已全部加载", 28, cc.c3b(122,122,122))
		listWnd.markAllLoaded:addChild(lblAllLoaded)
		lblAllLoaded:setPosition(sz.width/2, 33)
		listWnd:pushBackCustomItem(listWnd.markAllLoaded)
	end
end

function UnMarkAllLoaded(listWnd)
	if listWnd and utils.IsValidCCObject(listWnd.markAllLoaded) then
		listWnd:removeItem(listWnd:getIndex(listWnd.markAllLoaded))
	end
end

function RegCopyEvent(label, cpyStr)
	if cpyStr then cpyStr = tostring(cpyStr) end
	if not label or not label.getString then return end
	
	local btn = ccui.Button:create()
	btn:setScale9Enabled(true)
	local sz = label:getContentSize()
	btn:setContentSize(cc.size(sz.width*label:getScale(),sz.height*label:getScale()+12))
	btn:setAnchorPoint(label:getAnchorPoint())
	btn:setPosition(label:getPosition())
	label:getParent():addChild(btn)
	
	cpyStr = cpyStr or label:getString() or ""
	
	--[[
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.began then 
			if btn._tmrcopy then
				KE_KillTimer(btn._tmrcopy)
				btn._tmrcopy = nil
			end
			btn._tmrcopy = KE_SetAbsTimeout(1, function()
				SalmonUtils:copy(cpyStr)
				utils.TellMe("复制成功")
			end)
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			if btn._tmrcopy then
				KE_KillTimer(btn._tmrcopy)
				btn._tmrcopy = nil
			end
		end
	end
	btn:addTouchEventListener(touchEvent)
	]]--
	utils.RegClickEvent(btn, function()
		SalmonUtils:copy(cpyStr)
		utils.TellMe("复制成功")
	end)
	
	return btn
end

function GetOpenResultInterval(remainSec)
	if not remainSec then return 5 end
	if remainSec <= 5 then return 5 end
	if remainSec <= 60 then return 5 end
	if remainSec <= 120 then return 8 end
	return 10 
end

function GetRowColByIdx(COL, idx)
	local r = math.ceil(idx/COL)
	local c = idx%COL
	if c == 0 then c = COL end
	return r, c
end

function GetIdxByRowCol(COL, r, c)
	return (r-1)*COL + c
end

function GetBounding(obj)
	local x, y = obj:getPosition()
	local size = obj:getContentSize()
	local ap = obj:getAnchorPoint()
	-- left right bottom top
	return x-size.width*ap.x , x+size.width*(1-ap.x) , y-size.height*ap.y , y+size.height*(1-ap.y)
end

function ParseBounding(objList)
	local left, right, bottom, top = GetBounding(objList[1])
	
	for _, obj in ipairs(objList) do
		local v1, v2, v3, v4 = GetBounding(obj)
		if v1 < left then left = v1 end
		if v2 > right then right = v2 end
		if v3 < bottom then bottom = v3 end
		if v4 > top then top = v4 end
	end
	
	return left, right, bottom, top
end

function FormatNum(num)
	local absnum = math.abs(num)
	if absnum < 10000 then
		return tostring(num)
	elseif absnum < 1000000 then
		num = tostring(num)
		local int_part = string.sub(num,1,-5)
		local dot_part = string.sub(num,-4,-3)
		return string.format("%s.%s万", int_part, dot_part)
	elseif absnum < 10000000 then
		num = tostring(num)
		local int_part = string.sub(num,1,-5)
		local dot_part = string.sub(num,-6,-6)
		return string.format("%s.%s万", int_part, dot_part)
	elseif absnum < 100000000 then
		local int_part = string.sub(num,1,-5)
		return string.format("%s万", int_part)
	else
		local int_part = string.sub(num,1,-9)
		local dot_part = string.sub(num,-8,-7)
		return string.format("%s.%s亿", int_part, dot_part)
	end
end

---------------------------------------

local function SiSheWuRu(num, jinquedu)
	local strNum = tostring(num)
	local iStart, iEnd = string.find(strNum, "%.")
	if not iStart then return num end
	
	local nLen = string.len(strNum)
	if nLen <= iStart + jinquedu then return num end
	
	local v1 = string.sub(strNum, 1, iStart+jinquedu)
	local v2 = string.sub(strNum, iStart+jinquedu+1, iStart+jinquedu+1)
	if tonumber(v2) >= 5 then
		v1 = tonumber(v1) + 0.001
	else
		v1 = tonumber(v1)
	end
	return v1
--	return tonumber( string.format("%.3f",num) )
end

function CalPeiLv(maxRate, minRate, maxRebate, userRebate)
	local realRate = 0
	
--	logger.normal(string.format("maxRate=%s minRate=%s maxRebate=%s userRebate=%s",maxRate,minRate,maxRebate,userRebate))
	
	if maxRate == 0 or minRate == 0 or maxRebate == 0 or userRebate == 0 then
		realRate = maxRate
	--	logger.normal("---- 直接得到赔率：", realRate)
	else
		-- (最大赔率-最小赔率) / 最大返水 = 1%返水时减少的赔率
		local percent_one = (maxRate-minRate) / maxRebate
		-- 用户设置返水率实际应减少的赔率 = 1%返水时减少的赔率 * 用户自定义设置返水率
		local user_real_rebate_minus = percent_one * userRebate
		-- 用户设置反水率实际赔率 = 最大赔率 - 用户设置返水率实际应减少的赔率
		realRate = maxRate - user_real_rebate_minus
	--	local xxxx = realRate
		realRate = SiSheWuRu(realRate, 3)
	--	logger.normal("1%返水时减少的赔率：", percent_one)
	--	logger.normal("用户设置返水率实际应减少的赔率：", user_real_rebate_minus)
	--	logger.normal("---- 计算得到赔率：", xxxx, realRate)
	end
	
	return realRate
end

function CalCmn(m,n)
	local v =  0
	if m < n then return 0 end
	local a1 = 1
	local a2 = 1
	for i=1, n do
		a1 = a1 * (m-i+1)
		a2 = a2 * i
	end
	return a1/a2
end

function IsSameGid(gid1, gid2)
	return tonumber(gid1) == tonumber(gid2)	
end

function IsSameTid(tid1, tid2)
	return tonumber(tid1) == tonumber(tid2)	
end
