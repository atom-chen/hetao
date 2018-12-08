-------------------------
-- 开奖历史(通用)
-------------------------
module("ui", package.seeall)

clsLotteryHistory = class("clsLotteryHistory", clsBaseUI)

function clsLotteryHistory:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/LotteryHistory.csb")
	
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ListItem:getContentSize()
	self.listWnd = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
		
		curBtn:getChildByName("lblKjIssue"):setString( string.format("第%s期", info.kj_issue) )
			
		local picLbl = ui.clsPicLabel.new()
		curBtn:addChild(picLbl)
		picLbl:setAnchorPoint(cc.p(0,0.5))
		picLbl:setPosition(curBtn:getChildByName("ImgLine"):getPositionX() + 25, curBtn:getContentSize().height/2)
		picLbl:setString(info.number, 12)
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
	
	g_EventMgr:AddListener(self, "on_req_bet_open_result", self.on_req_bet_open_result, self)
end

function clsLotteryHistory:dtor()
	
end

function clsLotteryHistory:SetGid(gid)
	self.gid = gid
	local recvdata = ClsGameMgr.GetInstance():GetOpenResult(gid)
	if recvdata then
		self:on_req_bet_open_result(recvdata,{gid=gid})
	else
		proto.req_bet_open_result({gid=gid})
	end
end

function clsLotteryHistory:on_req_bet_open_result(recvdata, tArgs)
	if not gameutil.IsSameGid(tArgs.gid, self.gid) then return end
	local rows = recvdata and recvdata.data and recvdata.data.rows or {}
	
	local preCnt = self.listWnd:GetCellCount()
	local prePos = self.listWnd:getInnerContainerPosition()
	self.listWnd:RemoveAll()
	for i, info in ipairs(rows) do
		self.listWnd:Insert(info)
	end
	self.listWnd:ForceReLayout()
	local curCnt = self.listWnd:GetCellCount()
	if preCnt == curCnt then
		self.listWnd:setInnerContainerPosition(prePos)
	end
end
