-------------------------
-- 11x5游戏管理器
-------------------------
ClsGame11x5Mgr = class("ClsGame11x5Mgr", clsGameInterface)
ClsGame11x5Mgr.__is_singleton = true

function ClsGame11x5Mgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGame11x5Mgr:dtor()
	
end

function ClsGame11x5Mgr:GetBallCombineInfo(tid)
	local groupInfo = self:GetMenuOfGroup(nil, tid)
	if not groupInfo then return nil end
	if groupInfo.sname == "1z1" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 1, maxCnt = 1 }
	elseif groupInfo.sname == "2z2" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 2, maxCnt = 2 }
	elseif groupInfo.sname == "3z3" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 3, maxCnt = 3 }
	elseif groupInfo.sname == "4z4" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 4, maxCnt = 4 }
	elseif groupInfo.sname == "5z5" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 5, maxCnt = 5 }
	elseif groupInfo.sname == "6z5" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 6, maxCnt = 6 }
	elseif groupInfo.sname == "7z5" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 7, maxCnt = 7 }
	elseif groupInfo.sname == "8z5" then
		return { billType = const.BILL_TYPE.MzN, onceCnt = 8, maxCnt = 8 }
	end
	
	local isUnder_zhx = self:IsUnderMenu(nil, tid, "zhx")
	local isUnder_zx = self:IsUnderMenu(nil, tid, "zx")
	if groupInfo.sname == "q2" and isUnder_zhx then
		return { billType = const.BILL_TYPE.ZHIXUAN, onceCnt = 1, maxCnt = 1 }
	elseif groupInfo.sname == "q3" and isUnder_zhx then
		return { billType = const.BILL_TYPE.ZHIXUAN, onceCnt = 1, maxCnt = 1 }
	end
	if groupInfo.sname == "q2" and isUnder_zx then
		return { billType = const.BILL_TYPE.JustN, onceCnt = 2, maxCnt = 2 }
	elseif groupInfo.sname == "q3" and isUnder_zx then
		return { billType = const.BILL_TYPE.JustN, onceCnt = 3, maxCnt = 3 }
	end
	
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end