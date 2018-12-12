-------------------------
-- 长龙相关协议
-------------------------
module("proto",package.seeall)

local ClsChatMgr = require("dragon.model.ChatMgr")

function on_req_interactive_chat_index(recvdata)
    local data = recvdata and recvdata.data
    ClsChatMgr.GetInstance():SaveChatRecord(data)
end

function on_req_interactive_chat_get_ws_url(recvdata)

end

function on_req_interactive_chat_share_standings(recvdata)

end

function on_req_interactive_chat_share_bets(recvdata)

end

function on_req_orders_bet3_gid(recvdata)

end

function on_req_interactive_chat_get_last_plan(recvdata)

end

function on_req_dragon_plays(recvdata)

end

function on_req_dragon_data(recvdata)
    local data = recvdata and recvdata.data
    ClsChatMgr.GetInstance():SaveBetData(data)
end

function on_req_home_yesterday_win(recvdata)
    local data = recvdata and recvdata.data
    ClsChatMgr.GetInstance():SaveYesterWin(data)
end

function on_req_home_now_stamp(recvdata)
    print("-------------------------------------站点时间")
    dump(recvdata)
end

function on_req_home_game_plan(recvdata)
    print("-----------------------------------所有倒计时")
    dump(recvdata)
end

function on_req_home_kithe_plan(recvdata)
    print("----------------------------------------期号")
    dump(recvdata)
end