-------------------------
-- 首页协议
-------------------------
module("proto",package.seeall)

function on_req_redbag_openstate(recvdata)
	ClsRedbagMgr.GetInstance():InitState(recvdata and recvdata.data)
end

function on_req_redbag_grab(recvdata, tArgs)
	ClsUIManager.GetInstance():ShowPopWnd("clsRedbagRecvdUI", recvdata and recvdata.data)
end

function on_req_redbag_detail(recvdata)
	
end

function on_req_redbag_ranklist(recvdata)
	ClsRedbagMgr.GetInstance():SaveRankList(recvdata)
end
