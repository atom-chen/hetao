-------------------------
-- 购彩协议
-------------------------
module("proto",package.seeall)

--获取主页/购彩/开奖游戏列表
function on_req_goucai_gamelist(recvdata)
	
end

--获取购彩游戏列表
function on_req_goucai_all_games(recvdata)
	ClsGameMgr.GetInstance():InitAllGameInfo(recvdata.data)
end

function fail_req_goucai_all_games(recvdata)
	KE_SetAbsTimeout(3, function()
		if PlatformHelper.isNetworkConnected() and not ClsGameMgr.GetInstance():GetAllGameInfo() then
			proto.req_goucai_all_games({use="all"})
		end
	end)
end

function error_req_goucai_all_games(recvdata)
	KE_SetAbsTimeout(3, function()
		if PlatformHelper.isNetworkConnected() and not ClsGameMgr.GetInstance():GetAllGameInfo() then
			proto.req_goucai_all_games({use="all"})
		end
	end)
end

--获取游戏玩法列表
function on_req_goucai_game_wanfa_list(recvdata)
	local data = recvdata and recvdata.data 
	if data then
		ClsGameMgr.GetInstance():SaveWanFaData(data.id, data)
	end
end

--获取游戏球号和赔率列表
function on_req_goucai_game_qiuhao_peilv_list(recvdata, tArgs)
	local data = recvdata and recvdata.data 
	if data then
		local info = tArgs._tUrlParams
		ClsGameMgr.GetInstance():SavePeiLvData(data, info.gid, info.tid)
	end
end

--玩法赔率整和(按照大分类)
function on_req_goucai_bet_rate(recvdata)
	
end

--六合彩颜色
function on_req_goucai_game_lhc_sx(recvdata)
	ClsGameLhcMgr.GetInstance():InitLhcSxData(recvdata)
end

function on_req_goucai_game_trend_list(recvdata, tArgs)
	
end
