-------------------------
-- HelpDoc协议
-------------------------
module("proto",package.seeall)

--网站信息文章内容
function on_req_helpdoc_site_info(recvdata)
	
end

--玩法规则
function on_req_helpdoc_play_rule(recvdata, tArgs)
    ClsHelpDocMgr.GetInstance():SaveContent(tArgs.type, recvdata)
end
