-------------------------
-- 首页管理器
-------------------------
ClsHomeMgr = class("ClsHomeMgr", clsCoreObject)
ClsHomeMgr.__is_singleton = true

function ClsHomeMgr:ctor()
	clsCoreObject.ctor(self)
	self._tHomeCfgData = nil
	self._tCaiZhongData = nil
    self._tRewardInfo = nil
end

function ClsHomeMgr:dtor()

end

-------------------------------
-- 首页-配置信息
-------------------------------
function ClsHomeMgr:SaveHomeConfigData(data)
	assert(data==nil or type(data)=="table")
	self._tHomeCfgData = data 
	if self:NeedRefreshHomeConfigData() then
		logger.normal("该刷新主页了")
		self:CreateAbsTimerDelay("tmr_interval_1", 2, function() end)
	end
end
function ClsHomeMgr:GetHomeConfigData()
	return self._tHomeCfgData
end
function ClsHomeMgr:NeedRefreshHomeConfigData()
	return not self:HasTimer("tmr_interval_1")
end

-- Logo图标
function ClsHomeMgr:GetLogoImg()
	--return self._tHomeCfgData and self._tHomeCfgData.logo
    return self._tHomeCfgData and self._tHomeCfgData.wap_head_logo
end
--活动大厅是否开启
function ClsHomeMgr:GetHddt()
    return self._tHomeCfgData and self._tHomeCfgData.is_open_hddt or 0
end
-- Logo标题
function ClsHomeMgr:GetPcBannerImg()
	return self._tHomeCfgData and self._tHomeCfgData.pc_banner_img
end

--快速充值链接
function ClsHomeMgr:GetQuickPayUrl()
	local url = self._tHomeCfgData and self._tHomeCfgData.quick_recharge_url
	if url==0 or url == "0" or type(url) ~= "string" then
		return nil
	end
	if not string.find(url, "http") then return nil end
	return url
end

-- 公告信息
function ClsHomeMgr:GetNoticeData()
	return self._tHomeCfgData and self._tHomeCfgData.new_notice
end

-------------------------------
--首页-彩种信息
-------------------------------
function ClsHomeMgr:SaveCaiZhongData(data)
	assert(data==nil or type(data)=="table")
	self._tCaiZhongData = data
	if self:NeedRefreshCaiZhongData() then
		logger.normal("该刷新主页彩种了")
		self:CreateAbsTimerDelay("tmr_interval_2", 1.5, function() end)
	end
end
function ClsHomeMgr:GetCaiZhongData()
	return self._tCaiZhongData
end
function ClsHomeMgr:NeedRefreshCaiZhongData()
	return not self:HasTimer("tmr_interval_2")
end

-------------------------------
--活动-每日嘉奖阶梯
-------------------------------
function ClsHomeMgr:SaveRewardInfo(data)
    self._tRewardInfo = data
end

function ClsHomeMgr:GetRewardInfo()
    return self._tRewardInfo
end