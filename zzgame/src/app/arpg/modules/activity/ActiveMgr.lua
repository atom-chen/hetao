---------------------
-- 管理器
---------------------
clsActiveMgr = class("clsActiveMgr",clsCoreObject)

function clsActiveMgr:ctor()
	clsCoreObject.ctor(self)
    self._tActivityListData = nil
    --晋级奖励
    self._tGradeData = nil
    --每日嘉奖
    self._tRewardData = nil
    self._sGradeImg = nil
end

function clsActiveMgr:SaveAcitivtyList(data)
	if data then
    	self._tActivityListData = data
    	self._dataTime = VVDirector:GetServerTime()
    end
end

function clsActiveMgr:GetActivityList()
	return self._tActivityListData
end

function clsActiveMgr:SaveGradeData(data)
    self._tGradeData = data
end

function clsActiveMgr:GetGradeData()
    return self._tGradeData
end

function clsActiveMgr:SetCanGradeAward(bCan)
	if not self._tGradeData then return end
	self._tGradeData.data.is_reward = bCan
end

function clsActiveMgr:SaveRewardData(data)
    self._tRewardData = data
end

function clsActiveMgr:GetRewardData()
    return self._tRewardData
end

function clsActiveMgr:SetCanAward(bCan)
	if not self._tRewardData then return end
	self._tRewardData.data.is_reward = bCan and 1 or 0
end

function clsActiveMgr:SaveGradeImg(recvdata)
    self._sGradeImg = recvdata
end

function clsActiveMgr:GetGradeImg()
    return self._sGradeImg
end