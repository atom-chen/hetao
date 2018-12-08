-------------------------
-- 提现
-------------------------
module("ui", package.seeall)
local crypto = require("kernel.framework.crypto")
clsWithdrawView = class("clsWithdrawView", clsBaseUI)

function clsWithdrawView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/WithdrawView.csb")
	self.EditDrawMoney = utils.ReplaceTextField(self.EditDrawMoney,"","FF111111")
	self.EditDrawMoney:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
    self.EditMoneyWords = utils.ReplaceTextField(self.EditMoneyWords,"","FF111111")
    self.EditMoneyWords:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self:InitUiEvents()
	self:InitGlbEvents()
end

function clsWithdrawView:dtor()
	
end

--注册控件事件
function clsWithdrawView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_2,function () 
        ClsUIManager.GetInstance():ShowPanel("clsWithdrawRecord")
    end)
    utils.RegClickEvent(self.Button_1,function()
        PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
    end)
    utils.RegClickEvent(self.BtnNext,function () 
    	local cnt = self.EditDrawMoney:getString()
    	cnt = tonumber(cnt)
    	if not cnt or cnt <= 0 then
    		utils.TellMe("请输入提现金额")
    		return
    	end
    	if not self._data then
    		return 
    	end
    	if self._data and self._data.out_min then
    		local out_min = tonumber(self._data.out_min)
    		if out_min and cnt < out_min then
    			utils.TellMe("提现额度不可低于"..out_min.."元")
    			return
    		end
    	end
        local strSec = self.EditMoneyWords:getString()
		if string.len(strSec) < 6 then
			utils.TellMe("请输入六位密码")
			return
		end
    	local canWithdraw = tonumber(self._data.balance - self._data.all_fee)
    	if cnt > canWithdraw then
    		ClsUIManager.GetInstance():PopConfirmDlg("CFM_WITHDRAW", "提示", "可提现金额："..canWithdraw, function(mnuId)
				if mnuId == 1 then
					self.withdrawMoney = canWithdraw
					self.EditDrawMoney:setString(self.withdrawMoney)
					proto.req_pay_withdraw_type({money=tostring(self.withdrawMoney)})
				end
			end) 
			return
    	end
    	
--		ClsUIManager.GetInstance():ShowPopWnd("clsWithdrawTip"):RefleshUI(cnt, self._data)
		self.withdrawMoney = cnt
		proto.req_pay_withdraw_type({money=tostring(self.withdrawMoney)})
    end)
     self.EditDrawMoney:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "return" then
            local data = tonumber(self.EditDrawMoney:getString())
            if not data then
                --utils.TellMe("请输入正确的提现金额")
                self.EditDrawMoney:setString(null)
            end
        end
    end)
end

-- 注册全局事件
function clsWithdrawView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_tixian", self.RefleshUI, self)
	g_EventMgr:AddListener(self,"on_req_pay_withdraw_type", function(thisObj, recvdata)
        proto.req_pay_withdraw({ money=tostring(self.EditDrawMoney:getString()), bank_pwd=crypto.md5(self.EditMoneyWords:getString()), out_type="1" })
		--ClsUIManager.GetInstance():ShowPopWnd("clsWithdrawSecInput"):RefleshUI(self.withdrawMoney, self._data, recvdata)
	end)
end

function clsWithdrawView:RefleshUI(recvdata)
	local data = recvdata and recvdata.data
	if not data then return end
	self._data = data
    
    self.Image_1:LoadTextureSync(data.img)
    self.lblBankName:setString(data.bank_name)
    self.lblBankNum:setString(data.bank_num)

	self.lblBalance:setString((data.balance or 0) .. "元")
	self.lblCandraw:setString((data.out_balance or 0) .. "元")
	self.lblFreelines:setString((data.w_dml or 0) .. "元")
	self.lblShouxufei:setString(data.all_fee or 0)
	
    
    --布局调整
    if data.is_w_dml and data.is_w_dml == 1 or data.is_w_dml == "1" then
    	local tbTip = {
			"① 24小时无限次数提现。\n\n",
			"② 可提金额：入款金额一倍流水后的账户余额。\n\n",
			"③ 免费提款额度 = 累计派奖金额 - 已提现金额。\n\n",
			"④ 单笔提现最低"..data.out_min.."元，最高"..data.out_max.."元。\n\n",
			"⑤ 如有任何问题请及时联系24小时在线客服。",
		}
	    --self.Text_33:setString(table.concat(tbTip))
    else
    	local tbTip = {
			"① 24小时无限次数提现。\n\n",
			"② 可提金额：入款金额一倍流水后的账户余额。\n\n",
			"③ 单笔提现最低"..data.out_min.."元，最高"..data.out_max.."元。\n\n",
			"④ 如有任何问题请及时联系24小时在线客服。",
		}
	    --self.Text_33:setString(table.concat(tbTip))
	    
	    if utils.IsValidCCObject(self.Panel4) then
	    	self.AreaAuto:removeItem(self.AreaAuto:getIndex(self.Panel4))
	    end
    end
--	self.lblCunKuang:setString("存款：" .. data.total_price)
--	self.lblYouHui:setString("优惠：" .. data.discount_price)
--	self.lblDrawNeed:setString("提款需达标注量：" .. data.auth_dml)
--	self.lblYidabiao:setString("已达标注量：" .. data.dml)
--	self.lblXingZenFei:setString("行政费用：" .. data.total_ratio_price)
--	self.lblTotalMinus:setString("共扣除：" .. data.all_fee)
--	self.lblStartTime:setString("始于：" .. data.start_date)
--	self.lblEndTime:setString("结束：" .. data.end_date)
--	self.lblOnceMinOut:setString("单次最低出款额度：" .. data.out_min)
--	self.lblBankMaxOut:setString("银行卡单次出款上限：" .. data.out_max)
end
