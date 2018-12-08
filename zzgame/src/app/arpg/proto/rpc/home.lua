-------------------------
-- 首页协议
-------------------------
module("proto",package.seeall)

--首页-首页彩种
function on_req_home_caizhong(recvdata)
	--ClsHomeMgr.GetInstance():SaveCaiZhongData(recvdata.data)
end

--首页-配置信息
function on_req_home_homedata(recvdata)
    ClsHomeMgr.GetInstance():SaveRewardInfo(recvdata.data.reward_day)
    clsActiveMgr.GetInstance():SaveGradeImg(recvdata.data.jinji_jiajiang[1].img_base64)
	ClsHomeMgr.GetInstance():SaveHomeConfigData(recvdata.data)
    ClsHomeMgr.GetInstance():SaveCaiZhongData(recvdata.data.cp_data.sc)
end

--首页-更多彩种
function on_req_home_more_caizhong(recvdata)
	
end

--首页-如何领奖
function on_req_home_tip_award_way(recvdata)
	
end

--规则
function on_req_get_game_article_content(recvdata, tArgs)
	local data = recvdata and recvdata.data
	if not data then return end
	
	if tArgs.id == "13" then
		local wnd = ClsUIManager.GetInstance():GetWindow("clsRechargeScan")
		if wnd then wnd:LoadUrlData(data[1] and data[1].content) end
	elseif tArgs.id == "68" then
		for _, info1 in ipairs(data) do
			ClsAdvertiseMgr.GetInstance():AddPushor(info1)
		end
	elseif tArgs.id == "38" then
		ClsRedbagMgr.GetInstance():SaveRedbagDesc(recvdata)
	end
end

--首页-如何提款
function on_req_home_tip_tikuan(recvdata)
	
end

function on_req_home_getnotice(recvdata)

end