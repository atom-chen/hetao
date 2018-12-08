-------------------------
-- 战场
-------------------------
local SIZE = 60
local MAX_ROW = 12
local MAX_COL = 21

local GRID_TYPE = {
	ROAD = 1,
	EMPTY_OBSTACLE = 2,
	RAND_OBSTACLE = 3,
	PRESET_OBSTACLE = 4,
}

local COLOR_MAP = {
	[GRID_TYPE.ROAD] = cc.c4f(1,0,0,1),
	[GRID_TYPE.EMPTY_OBSTACLE] = cc.c4f(0,1,0,1),
	[GRID_TYPE.RAND_OBSTACLE] = cc.c4f(0,0,1,1),
	[GRID_TYPE.PRESET_OBSTACLE] = cc.c4f(1,1,1,1),
}

local ORDER_GROUND = 0
local ORDER_BUILDING = 1
local ORDER_FIGHTER = 2
local ORDER_BULLET = 3
local ORDER_EFFECT = 4


clsField = class("clsField", clsLayer)

function clsField:ctor(FieldId)
	clsLayer.ctor(self)
	
	self._field_id = FieldId
	self._row = 0
	self._col = 0
	self._grid_data = {}
	
	self:_Load()
	self:DrawGrid()
end

function clsField:dtor()
	
end

function clsField:_Load()
	self._row = 10
	self._col = 10
	self._grid_data = {}
	for r=1, self._row do
		self._grid_data[r] = {}
		for c=1, self._col do
			self._grid_data[r][c] = math.random(1,4)
		end
	end
end

function clsField:DrawGrid()
	if not self.gridDrawer then
		self.gridDrawer = cc.DrawNode:create()
		self:addChild(self.gridDrawer)
	else
		self.gridDrawer:clear()
	end
	
	local SPACE = 5
	local color
	local pt1 = cc.p(0,0)
	local pt2 = cc.p(0,0)
	for r=1, self._row do
		for c=1, self._col do
			color = COLOR_MAP[ self._grid_data[r][c] ]
			pt1.x = (c-1) * SIZE + SPACE
			pt1.y = (r-1) * SIZE + SPACE
			pt2.x = pt1.x + SIZE - SPACE
			pt2.y = pt1.y + SIZE - SPACE
			self.gridDrawer:drawRect(pt1, pt2, color)
		end
	end
end
