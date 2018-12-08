-------------------------
-- 开奖历史(通用)
-------------------------
module("ui", package.seeall)

clsLhcHistory = class("clsLhcHistory", clsBaseUI)

function clsLhcHistory:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/LotteryHistory.csb")
	
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ListItem:getContentSize()
	self.listWnd = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
			
		curBtn:getChildByName("lblKjIssue"):setString( string.format("第%s期", info.kj_issue) )
			
		local tColor = string.split(info.color, ",")
		local tNumber = string.split(info.number, ",")
		local tShengXiao = string.split(info.shengxiao, ",")
		local x0,y0 = curBtn:getChildByName("ImgLine"):getPositionX() + 45, curBtn:getContentSize().height/2+15
		local sz = 48
		local curX = 0
		local ballSprs = {}
		for i, vvv in ipairs(tColor) do
			local sprBall = utils.CreateSprite("uistu/common/gray_circle.png")
			curBtn:addChild(sprBall)
			sprBall:setPosition(x0+curX, y0)
			curX = curX + sz 
			sprBall:setColor(const.GAME_LHC_COLOR[vvv])
			if i == #tColor-1 then
				local sprAdd = utils.CreateSprite("uistu/common/add.png")
				sprAdd:setPosition(x0+curX-7.5, y0)
				curBtn:addChild(sprAdd)
				curX = curX + 30
			end
			ballSprs[i] = sprBall
		end
		for i, vvv in ipairs(tNumber) do
			local x, y = ballSprs[i]:getPosition()
			local lblName = utils.CreateLabel(vvv, 24)
			lblName:setTextColor(cc.c3b(250,250,250))
			curBtn:addChild(lblName)
			lblName:setPosition(x, y)
		end
		for i, vvv in ipairs(tShengXiao) do
			local x, y = ballSprs[i]:getPosition()
			local lblShx = utils.CreateLabel(vvv, 24)
			lblShx:setTextColor(cc.c3b(22,22,22))
			curBtn:addChild(lblShx)
			lblShx:setPosition(x, y-35)
		end
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
	
	g_EventMgr:AddListener(self, "on_req_bet_open_result", self.on_req_bet_open_result, self)
end

function clsLhcHistory:dtor()
	
end

function clsLhcHistory:SetGid(gid)
	self.gid = gid
	local recvdata = ClsGameMgr.GetInstance():GetOpenResult(gid)
	if recvdata then
		self:on_req_bet_open_result(recvdata,{gid=gid})
	else
		proto.req_bet_open_result({gid=gid})
	end
end

function clsLhcHistory:on_req_bet_open_result(recvdata, tArgs)
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
