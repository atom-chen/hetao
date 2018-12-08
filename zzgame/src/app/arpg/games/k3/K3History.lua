-------------------------
-- 界面
-------------------------
module("ui", package.seeall)

clsK3History = class("clsK3History", clsBaseUI)

function clsK3History:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/K3History.csb")
	
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ListItem:getContentSize()
	self.listWnd = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
		
		curBtn:getChildByName("lblKjIssue"):setString( string.format("第%s期", string.sub(info.kj_issue,-7,-1)) )
			
		local tbl = string.split(info.number, ",")
		local hezhi = 0
		for _, v in pairs(tbl) do
			hezhi = hezhi + (tonumber(v) or 0)
		end
			
		for idx, v in ipairs(tbl) do
			local sprDice = utils.CreateSprite(DICE_RES[v])
			sprDice:setScale(0.4)
			curBtn:addChild(sprDice)
			sprDice:setPosition( 356+ (sprDice:getContentSize().width*0.4+2)*(idx-(#tbl+1)/2), curBtn:getContentSize().height/2 )
		end
			
		curBtn:getChildByName("lblHezhi"):setString(hezhi)
		curBtn:getChildByName("lblDaxiao"):setString(hezhi >= 11 and "大" or "小")
		curBtn:getChildByName("lblDanshuang"):setString(hezhi%2 == 0 and "双" or "单")
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
	
	g_EventMgr:AddListener(self, "on_req_bet_open_result", self.on_req_bet_open_result, self)
end

function clsK3History:dtor()
	
end

function clsK3History:SetGid(gid)
	self.gid = gid
	local recvdata = ClsGameMgr.GetInstance():GetOpenResult(gid)
	if recvdata then
		self:on_req_bet_open_result(recvdata,{gid=gid})
	else
		proto.req_bet_open_result({gid=gid})
	end
end

function clsK3History:on_req_bet_open_result(recvdata, tArgs)
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
