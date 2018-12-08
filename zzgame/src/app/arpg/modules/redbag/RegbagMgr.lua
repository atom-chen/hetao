---------------------
-- 管理器
---------------------
ClsRedbagMgr = class("ClsRedbagMgr",clsCoreObject)

function ClsRedbagMgr:ctor()
	clsCoreObject.ctor(self)
end

function ClsRedbagMgr:InitState(data)
	self:DestroyTimer("tmr_cd")
	self._stateInfo = data
	if data then
		data.start_time = tonumber(data.start_time)
		data.end_time = tonumber(data.end_time)
		data.server_time = tonumber(data.server_time)
		print("红包已经开始多久：", data.server_time-data.start_time)
		print("红包结束剩余时间：", data.end_time-data.server_time)
		print("红包离活动开始还有多久：", self:IsWillOpen())
		local remainSec = self:IsWillOpen()
		if remainSec then
			g_EventMgr:FireEvent("redbag_cd", remainSec)
			self:CreateAbsTimerLoop("tmr_cd", 1, function()
				self._stateInfo.server_time = self._stateInfo.server_time + 1
				local remainSec = self._stateInfo.start_time - self._stateInfo.server_time
				g_EventMgr:FireEvent("redbag_cd", remainSec)
				if remainSec <= 5 then
					proto.req_redbag_openstate()
				end
				if remainSec <= 0 then
					return true
				end
			end)
		end 
	end
end

function ClsRedbagMgr:GetRedbagId()
	return self._stateInfo and self._stateInfo.id 
end

function ClsRedbagMgr:IsOpen()
	if not self._stateInfo then return false end
	local data = self._stateInfo
	print("============= IsOpen", data.server_time >= data.start_time and data.server_time <= data.end_time)
	return data.server_time >= data.start_time and data.server_time <= data.end_time
end

function ClsRedbagMgr:IsWillOpen()
	if not self._stateInfo then return nil end
	local data = self._stateInfo
	local cd = data.start_time - data.server_time 
	if cd > 0 then
		print("============ IsWillOpen", cd)
		return cd 
	end
	print("============ IsWillOpen nil", cd)
	return nil
end

function ClsRedbagMgr:Grap()
--	if not self:IsOpen() then
--		utils.TellMe("红包活动尚未开启")
--		return
--	end
	if self._stateInfo then 
		proto.req_redbag_grab({id=self._stateInfo.id})
	end
end

function ClsRedbagMgr:SaveRedbagDesc(recvdata)
	self._redbagDesc = recvdata
end

function ClsRedbagMgr:GetRedbagDesc()
	return self._redbagDesc
end

function ClsRedbagMgr:SaveRankList(recvdata)
	self._rankList = recvdata and recvdata.data 
end

function ClsRedbagMgr:GetRankList()
	return self._rankList
end
