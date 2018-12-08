-------------------------
-- 用户协议
-------------------------
module("proto",package.seeall)

-- 设置-银行卡列表
function on_req_user_bankcard_list(recvdata)
	ClsBankMgr.GetInstance():SetBankList(recvdata.data.rows)
end

-- 设置-绑定银行卡
function on_req_user_bind_bankcard(recvdata)
	if type(recvdata) ~= "table" then return end
	utils.TellMe(recvdata and recvdata.data)
    proto.req_user_balance()
end

function on_req_user_bind_needinfo(recvdata, tArgs)
	
end

--余额
function on_req_user_balance(recvdata)
	UserEntity.GetInstance():BatchSetAttr(recvdata.data)
end

--设置-已绑定银行卡
function on_req_user_binded_banks(recvdata)
	
end

--设置-绑定微信支付宝银行
function on_req_user_bind_wx_zfb(recvdata)
	if type(recvdata) ~= "table" then return end
	utils.TellMe(recvdata and recvdata.data)
end

--提现数据
function on_req_user_tixian(recvdata)
	
end

--账户明细
function on_req_user_zhanghu_mingxi(recvdata)
	
end

--充值记录
function on_req_user_chongzhi_record(recvdata)
	ClsRechargeRecoMgr.GetInstance():SaveRechargeRecord(recvdata.data)
end

--充值记录-类型
function on_req_user_chongzhi_record_type(recvdata)
	
end

--今日盈亏
function on_req_user_today_earn(recvdata)
	ClsTodayEarnMgr.GetInstance():SaveData(recvdata)
end

-- 个人信息-个人资料
function on_req_user_info(recvdata)
	UserEntity.GetInstance():BatchSetAttr(recvdata.data)
end 

-- 个人信息-等级头衔
function on_req_user_nobility(recvdata)
    ClsTitleMgr.GetInstance():saveTitleData(recvdata.data)
end

-- 个人信息-修改资料
function on_req_user_update_info(recvdata)
	utils.TellMe("更新资料成功")
end 

--个人信息-上传头像
function on_req_user_upload_headimg(recvdata)
	utils.TellMe("头像上传成功")
end

--收款中心-绑卡列表
function on_req_user_shoukuan_binded_cards(recvdata)
	
end

--分享页面
function on_req_user_share(recvdata)
	
end

--我的收藏
function on_req_user_get_favorite(recvdata)
	ClsCollectMgr.GetInstance():SetCollectList(recvdata and recvdata.data)
end

--删除收藏
function on_req_user_set_favorite(recvdata, tArgs)
    if tArgs.status == "0" then
    	ClsCollectMgr.GetInstance():AddCollect(tArgs)
    	utils.TellMe("收藏成功！点击我的--我的收藏查看")
    else
    	ClsCollectMgr.GetInstance():DelCollect(tArgs.gid)
    	utils.TellMe("取消收藏成功！")
    end
end

function on_req_user_bet_record_get_list(recvdata)
    ClsBetHistoryMgr.GetInstance():SaveBetHistory(recvdata.data)
end

function on_req_user_Payout_record_get_payout_list(recvdata)
    ClsWithdrawMgr.GetInstance():SaveWithdrawData(recvdata.data)
end

function on_req_chang_login_pwd(recvdata)

end

function on_req_bank_pwd_chang(recvdata)

end

function on_req_refresh_token(recvdata)
    if recvdata and recvdata.data then
        HttpUtil.token = recvdata.data.token
		ClsLoginMgr.GetInstance():Set_token_private_key(recvdata.data.token)
	end
end