-------------------------
-- 公告信息
-------------------------
module("ui", package.seeall)

clsRedbagRankUI = class("clsRedbagRankUI", clsBaseUI)

function clsRedbagRankUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RedbagRankUI.csb")
	self.RootFrame:setPosition(GAME_CONFIG.DESIGN_W_2, GAME_CONFIG.DESIGN_H_2)
	
	utils.RegClickEvent(self.BtnClose,function() 
		self:removeSelf() 
	end)
	self:InitListView()
	
	self:InitGlbEvents()
	proto.req_redbag_ranklist()
end

function clsRedbagRankUI:dtor()
	
end

function clsRedbagRankUI:InitListView()
	self.listWnd = clsCompList.new(self.RootFrame, ccui.ScrollViewDir.vertical, 600, 540, 600, 61)
	self.listWnd:setScrollBarEnabled(false)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
		curBtn:getChildByName("lblName"):setString(info.username or "")
		curBtn:getChildByName("lbMoney"):setString( "喜中" .. info.total .. "元")
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
end

-- 注册全局事件
function clsRedbagRankUI:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_redbag_ranklist", function(this, recvdata, tArgs)
		local infolist = ClsRedbagMgr.GetInstance():GetRankList() or {}
		local listWnd = self.listWnd
	    listWnd:RemoveAll()
	    for i, info in ipairs(infolist) do
			listWnd:Insert(info)
		end
		listWnd:ForceReLayout()
		listWnd:StartAutoScroll()
	end, this, true)
end