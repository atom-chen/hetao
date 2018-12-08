-------------------------
-- 支付协议
-------------------------
module("proto",package.seeall)

--支付-网站信息文章内容接口
function on_req_pay_siteinfo_article(recvdata)
	
end

--获取支付通道信息
function on_req_pay_get_pay_channel_info(recvdata)
	HttpUtil.g_pay_url = recvdata and recvdata.data and recvdata.data.pay_url
end

--提交支付
function on_req_pay_commit(recvdata, tArgs)	
	dump(tArgs)
--	utils.TellMe("充值申请提交成功",4)
	proto.req_user_balance()
	local data = recvdata and recvdata.data
	if data then
		if tArgs._client_jump == false then
			ClsUIManager.GetInstance():DestroyWindow("clsRechargeCommit2")
			ClsUIManager.GetInstance():ShowPanel("clsRechargeOver", tArgs)
		else
			if tArgs and tArgs._client_data then
				local info1 = tArgs._client_data.info1
				local info2 = tArgs._client_data.info2
				local money = tArgs._client_data.money
				
				local param = {}
				param.id = info2.id
				param.code = info2.code
				param.money = money
				param.from_way = const.FROMWAY
				
				if data.jump == 4 or data.jump == "4" then
					KE_SetTimeout(1, function()
						proto.req_get_game_article_content({id="13", param=param})
						local wnd = ClsUIManager.GetInstance():ShowPanel("clsRechargeScan", {
							info1 = info1,
							info2 = info2,
							name = info2.name,
							money = money,
						})
						wnd:RefleshQRCode(data.img)
						wnd:TellForbit()
					end)
				elseif data.jump == 3 or data.jump == "3" then
					KE_SetTimeout(1, function()
						proto.req_get_game_article_content({id="13", param=param})
						local wnd = ClsUIManager.GetInstance():ShowPanel("clsRechargeScan", {
							info1 = info1,
							info2 = info2,
							name = info2.name,
							money = money,
						})
						wnd:RefleshQRCode(data.img)
						wnd:TellForbit()
					end)
				else
					if data.url and data.url ~= "" then
						PlatformHelper.openURL(data.url or "") 
					end 
				end
			else
				if data.url and data.url ~= "" then
					PlatformHelper.openURL(data.url or "") 
				end 
			end
		end
	end
end

--快捷支付
function on_req_pay_quick_pay_step1(recvdata, param)
	logger.normal("开始快捷支付步骤2")
	logger.dump(recvdata)
	logger.dump(param)
	local param2 = {}
	param2.id = param.id
	param2.code = param.code
	param2.bank_type = param.bank_type
	param2.order_num = recvdata.data.order_num
	param2.pwd = recvdata.data.pwd
	param2.step = 2
	proto.req_pay_quick_pay_step2(param2)
end

function on_req_pay_quick_pay_step2(recvdata, tArgs)
	logger.normal("快捷支付成功")
	local data = recvdata and recvdata.data or {}
	
	local function callback(mnuId)
		PlatformHelper.openURL(data.url)
	end
	ClsUIManager.GetInstance():PopConfirmDlg(nil, "充值", "提交成功", callback)
			
	proto.req_user_balance()
end



--提现方式获取
function on_req_pay_withdraw_type(recvdata)
	
end
function fail_req_pay_withdraw_type(recvdata)
--	ClsUIManager.GetInstance():ShowPanel("clsSafeView")
end

--提现
function on_req_pay_withdraw(recvdata, tArgs)
	ClsUIManager.GetInstance():DestroyWindow("clsWithdrawView")
	ClsUIManager.GetInstance():ShowPopWnd("clsWithdrawOver", tArgs)
end
