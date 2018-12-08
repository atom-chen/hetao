-------------------------
-- 等级协议
-------------------------
module("proto",package.seeall)

--等级机制列表
function on_req_grade_grade_rule_list(recvdata)
	
end

--领取晋级奖励
function on_req_grade_uplevel_award(recvdata)
	local bCan = true
	if recvdata and recvdata.code == 200 then bCan = false end
	clsActiveMgr.GetInstance():SetCanGradeAward(bCan)
end

--用户等级相关信息
function on_req_grade_grade_info(recvdata)
	clsActiveMgr.GetInstance():SaveGradeData(recvdata)
end

--优惠活动等级晋级图片地址
function on_req_grade_uplevel_img(recvdata)
	clsActiveMgr.GetInstance():SaveGradeImg(recvdata)
end

--获得活动列表
function on_req_activity_list(recvdata)
    clsActiveMgr.GetInstance():SaveAcitivtyList(recvdata and recvdata.data)
end
