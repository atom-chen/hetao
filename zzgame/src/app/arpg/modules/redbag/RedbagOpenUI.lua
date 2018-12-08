-------------------------
-- 公告信息
-------------------------
module("ui", package.seeall)

clsRedbagOpenUI = class("clsRedbagOpenUI", clsBaseUI)

function clsRedbagOpenUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RedbagOpenUI.csb")
	self.RootFrame:setPosition(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2)
	
	utils.RegClickEvent(self.BtnClose,function() 
		self:removeSelf() 
	end)
	utils.RegClickEvent(self.BtnOpen,function() 
		ClsRedbagMgr.GetInstance():Grap()
	end)
	utils.RegClickEvent(self.BtnRank,function() 
		ClsUIManager.GetInstance():ShowPopWnd("clsRedbagRankUI", nil, false, true)
	end)
	utils.RegClickEvent(self.BtnDesc,function() 
		ClsUIManager.GetInstance():ShowPopWnd("clsRedbagDescView")
	end)
	
	self:RefleshTip()
	
	self:InitGlbEvents()
	
	proto.req_redbag_detail({red_id=ClsRedbagMgr.GetInstance():GetRedbagId() or ""})
end

function clsRedbagOpenUI:dtor()
	
end

function clsRedbagOpenUI:RefleshTip()
	if ClsRedbagMgr.GetInstance():IsWillOpen() then
		self.lblTip1:setString("离活动开始时间")
		self.lblTip2:setString(libtime.ChangeSToH(ClsRedbagMgr.GetInstance():IsWillOpen()))
	elseif ClsRedbagMgr.GetInstance():IsOpen() then
		self.lblTip1:setString("活动已经开始了")
		self.lblTip2:setString("抢红包啦")
	end
end

-- 注册全局事件
function clsRedbagOpenUI:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_redbag_detail", function(this, recvdata, tArgs)
		local data = recvdata and recvdata.data or {}
		local money = data.total or "0"
		self.lblYestodayCharge:setString("您昨天充值金额"..money.."元")
		self.lblCanDrawCnt:setString(string.format("能抢%s次",data.count or 1))
	end)
	g_EventMgr:AddListener(self, "fail_req_redbag_grab", function(this, recvdata, tArgs)
		self:removeSelf()
	end)
	g_EventMgr:AddListener(self, "redbag_cd", function(this, remainSec)
		self:RefleshTip()
	end)
	g_EventMgr:AddListener(self, "on_req_redbag_grab", function(this, recvdata, tArgs)
		local info = recvdata and recvdata.data
		if info then
			self.lblCanDrawCnt:setString(string.format("能抢%s次",info.surplus_num or 1))
		end
	end)
end