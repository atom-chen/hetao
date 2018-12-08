-------------------------
-- 近期开奖
-------------------------
module("ui", package.seeall)

clsRecentView = class("clsRecentView", clsBaseUI)

function clsRecentView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RecentView.csb")
	
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ListItem:getContentSize()
	self.listWnd = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+2)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
			
		curBtn:getChildByName("lblKjIssue"):setString( string.format("第%s期", info.kj_issue) )
		curBtn:getChildByName("lblTime"):setString( info.kj_time )
			
		local tColor = string.split(info.color, ",")
		local tNumber = string.split(info.number, ",")
		local tShengXiao = string.split(info.shengxiao, ",")
		local x0,y0 = 40,55
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
	
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnGouCai, function() self:removeSelf() end)
	
	g_EventMgr:AddListener(self, "on_req_bet_game_state", self.on_req_bet_game_state, self)
	g_EventMgr:AddListener(self, "on_req_bet_open_result", self.on_req_bet_open_result, self)
end

function clsRecentView:dtor()
	
end

function clsRecentView:SetGid(gameObj)
	local gid = gameObj.gameArg.gid
	proto.req_bet_game_state({gid=gid})
	local recvdata = ClsGameMgr.GetInstance():GetOpenResult(gid)
	if recvdata then
		self:on_req_bet_open_result(recvdata)
	else
		proto.req_bet_open_result({gid=gid})
	end
end

function clsRecentView:on_req_bet_open_result(recvdata)
	local rows = recvdata and recvdata.data and recvdata.data.rows or {}
	
	self.listWnd:RemoveAll()
	for i, info in ipairs(rows) do
		self.listWnd:Insert(info)
	end
	self.listWnd:ForceReLayout()
end

function clsRecentView:on_req_bet_game_state(recvdata)
	local data = recvdata and recvdata.data and recvdata.data[1]
	if not data then return end
	
	self.lblTitle:setString(data.name or "")
	self.lblGameName:setString(data.name or "")
	self.lblCdTip:setString(data.kithe.."期投注截止")
	self.ImgGameIcon:LoadTextureSync(data.img)
	
	local remainSec = data.kithe_time_stamp - data.current_time_stamp
	print("剩余时间：", remainSec, data.kithe_time_second)
	local clientTime = os.time()
	print("客户端时间-服务端时间 =", clientTime-data.current_time_stamp)
	self:OnRemainSec(remainSec)
	self:DestroyTimer("tmr_cd")
	self:DestroyTimer("tm_delay_state")
	if remainSec > 0 then
		self:CreateAbsTimerLoop("tmr_cd", 1, function()
			remainSec = remainSec - 1
			if remainSec < 0 then remainSec = 0 end
			self:OnRemainSec(remainSec)
			if remainSec <= 0 then 
				proto.req_bet_game_state({gid=data.gid})
				return true 
			end
		end)
	else
		self:CreateAbsTimerDelay("tm_delay_state", 1, function()
			proto.req_bet_game_state({gid=data.gid})
		end)
	end
end

function clsRecentView:OnRemainSec(remainSec)
	if remainSec < 0 then remainSec = 0 end
	local h,m,s = libtime.ChangeSToTbl(remainSec)
	self.lblHour:setString( string.format("%02d", h or 0) )
	self.lblMinit:setString( string.format("%02d", m or 0) )
	self.lblSecond:setString( string.format("%02d", s or 0) )
end
