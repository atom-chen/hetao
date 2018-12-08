-------------------------
-- 公告信息
-------------------------
module("ui", package.seeall)

clsRedbagRecvdUI = class("clsRedbagRecvdUI", clsBaseUI)

function clsRedbagRecvdUI:ctor(parent, info)
	clsBaseUI.ctor(self, parent, "uistu/RedbagRecvdUI.csb")
	self.RootFrame:setPosition(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2)
	
	utils.RegClickEvent(self.BtnClose,function() 
		self:removeSelf() 
	end)
	utils.RegClickEvent(self.BtnGrab,function() 
		ClsRedbagMgr.GetInstance():Grap()
	end)
	
	self:InitGlbEvents()
	
	if info then
		self.lblMoney:setString(info.money.."元")
		self.BtnGrab:setTitleText("剩余"..info.surplus_num.."次")
	end
end

function clsRedbagRecvdUI:dtor()
	
end

-- 注册全局事件
function clsRedbagRecvdUI:InitGlbEvents()
	g_EventMgr:AddListener(self, "fail_req_redbag_grab", function(this, recvdata, tArgs)
		self:removeSelf()
	end)
	g_EventMgr:AddListener(self, "on_req_redbag_grab", function(this, recvdata, tArgs)
		local info = recvdata and recvdata.data
		if info then
			self.lblMoney:setString(info.money.."元")
			self.BtnGrab:setTitleText("剩余"..info.surplus_num.."次")
		end
	end)
end