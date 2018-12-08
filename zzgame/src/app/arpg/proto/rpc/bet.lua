-------------------------
-- 下注协议
-------------------------
module("proto",package.seeall)

--玩法下注
function on_req_bet_xiazhu(recvdata)
--	utils.TellMe("下注成功")
end

--玩法追号下注
function on_req_bet_zhuihao_xiazhu(recvdata)
--	utils.TellMe("下注成功")
end

--注单撤消
function on_req_bet_cancel_xiazhu(recvdata)
	utils.TellMe("撤销注单成功")
end

--游戏状态查询
function on_req_bet_game_state(recvdata, tArgs)
	ClsGameMgr.GetInstance():SaveGameSate(tArgs.gid, recvdata)
end

--开奖结果查询
function on_req_bet_open_result(recvdata, tArgs)
	ClsGameMgr.GetInstance():SaveOpenResult(tArgs.gid, recvdata)
end

function on_req_game_menu(recvdata)
	
end

function on_req_game_ballandrate(recvdata)
	
end