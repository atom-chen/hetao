--------------------
-- 管理器
--------------------
clsFindMgr = class("clsFindMgr", clsCoreObject)

function clsFindMgr:ctor()
	clsCoreObject.ctor(self)
    self._tTodayReward = nil
    self._tYesterReward = nil
end

function clsFindMgr:dtor()

end

function clsFindMgr:SaveTodayRewardData(data)
    self._tTodayReward = data or {}
    self._timeout = os.clock()
end

function clsFindMgr:GetTodayRewardData()
	print("----------", os.clock() - (self._timeout or 0))
	if self._timeout then
		if os.clock() - self._timeout > 60 then
			self._tTodayReward = nil
		end
	end
	
    return self._tTodayReward
end

function clsFindMgr:ClearTodayRewardData()
	self._tTodayReward = nil
end

function clsFindMgr:SaveYesterRewardData(data)
    self._tYesterReward = data or {}
end

function clsFindMgr:GetYesterRewardData()
    return self._tYesterReward
end
