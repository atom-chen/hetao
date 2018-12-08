-------------------------
-- 今日盈亏
-------------------------
module("ui", package.seeall)

clsTodayEarn = class("clsTodayEarn", clsBaseUI)

function clsTodayEarn:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/TodayEarn.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
	self:on_req_user_today_earn()
	
	proto.req_user_today_earn()
end

function clsTodayEarn:dtor()
	
end

--刷新界面
function clsTodayEarn:on_req_user_today_earn(recvdata)
	recvdata = recvdata or ClsTodayEarnMgr.GetInstance():GetData()
	local info = recvdata and recvdata.data or {}
    if info.valid_price and info.valid_price == math.floor(tonumber(info.valid_price)) then
        info.valid_price = info.valid_price..".00"
    end
    if info.lucky_price and info.lucky_price == math.floor(tonumber(info.lucky_price)) then
        info.lucky_price = info.lucky_price..".00"
    end
    if info.return_price and info.return_price == math.floor(tonumber(info.return_price)) then
        info.return_price = info.return_price..".00"
    end
    if info.activi_price and info.activi_price == math.floor(tonumber(info.activi_price)) then
        info.activi_price = info.activi_price..".00"
    end
    if info.inpour_price and info.inpour_price == math.floor(tonumber(info.inpour_price)) then
        info.inpour_price = info.inpour_price..".00"
    end
    if info.outflow_price and info.outflow_price == math.floor(tonumber(info.outflow_price)) then
        info.outflow_price = info.outflow_price..".00"
    end
    if  info.profit and info.profit == math.floor(tonumber(info.profit)) then
        info.profit = info.profit..".00"
    end
	self.lblTouzhu:setString(info.valid_price or "0.00")
	self.lblZhongjiang:setString(info.lucky_price or "0.00")
	self.lblFanshui:setString(info.return_price or "0.00")
	self.lblHuodong:setString(info.activi_price or "0.00")
	self.lblChongzhi:setString(info.inpour_price or "0.00")
	self.lblTixian:setString(info.outflow_price or "0.00")
	self.lblProfit:setString(info.profit or "0.00")
end

--注册控件事件
function clsTodayEarn:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
end

-- 注册全局事件
function clsTodayEarn:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_today_earn", self.on_req_user_today_earn, self)
end