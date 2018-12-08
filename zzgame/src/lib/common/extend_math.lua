-------------------------
-- 数学库扩展
-------------------------
local math_cos = math.cos
local math_sin = math.sin
local math_tan = math.tan
local math_acos = math.acos
local math_asin = math.asin
local math_atan = math.atan
local math_rad = math.rad		-- 角度转弧度
local math_deg = math.deg		-- 弧度转角度
local math_abs = math.abs
local math_ceil = math.ceil
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local math_pow = math.pow		-- math.pow(3,8) 3的8次幂
local math_sqrt = math.sqrt		-- 求平方根
local math_mod = math.mod		-- 求余
local math_modf = math.modf		-- 取整数和小数部分 20.334 ---> 20  0.334
local math_exp = math.exp		-- e的x次方 math.exp(4）
local math_log = math.log
local math_log10 = math.log10

local string_sub = string.sub
local string_format = string.format

local PI_DIV_8 = math.pi/8
local HALF_PI = math.pi/2
local ONE_PI = math.pi
local DOUBLE_PI = math.pi*2
local PI_DIV_8_TABLE = {}    for i=1,15,2 do PI_DIV_8_TABLE[i] = PI_DIV_8*i end

local CHAR2NUM = { ["0"]=1,["1"]=1,["2"]=2,["3"]=3,["4"]=4,["5"]=5,["6"]=6,["7"]=7,["8"]=8,["9"]=9, a=10, A=10, b=11, B=11, c=12, C=12, d=13, D=13, e=14, E=14, f=15, F=15 }
local NUM2CHAR = { [0]="0",[1]="1",[2]="2",[3]="3",[4]="4",[5]="5",[6]="6",[7]="7",[8]="8",[9]="9",[10]="a", [11]="b", [12]="c", [13]="d", [14]="e", [15]="f" }

--------------------------------------------------------------------------

function math.Round(v)
	return math_floor(v + 0.5)
end

function math.Limit(value, vMin, vMax)
	if vMin and value < vMin then value = vMin end 
	if vMax and value > vMax then value = vMax end 
	return value
end

function math.Num2Tbl(iValue)
	assert(iValue>=0, "参数不可为负数: "..iValue)
	local tblValue = {}
	while iValue >= 0 do
		local LastNum = iValue%10
		table.insert(tblValue, LastNum)
		iValue = math.floor(iValue/10)
		if iValue == 0 then break end
	end
	return tblValue
end

-- 向量转弧度
function math.Vector2Radian(X, Y)
	local L = math_sqrt(X*X+Y*Y)
	if L==0 then return nil end
	
	local hudu = math_acos(X/L)
	if Y<0 then hudu = DOUBLE_PI-hudu end
	assert(hudu>=0 and hudu<=DOUBLE_PI, "返回值不合法："..hudu)
	return hudu
end

--弧度转向量
function math.Radian2Vector(hudu)
--	assert(hudu>=0 and hudu<=DOUBLE_PI, "参数在0到2*math.pi之间")
	return math_cos(hudu), math_sin(hudu)
end

-- iDir为[0--2*pi]的弧度值
function math.EightDir(iDir)
--	iDir = iDir % DOUBLE_PI
	assert(iDir>=0 and iDir<=DOUBLE_PI, "弧度范围在[0,2*PI]之间: "..iDir)
	if iDir >= PI_DIV_8_TABLE[1] and iDir < PI_DIV_8_TABLE[3] then
		return const.DIRECTION8.RU
	elseif iDir >= PI_DIV_8_TABLE[3] and iDir < PI_DIV_8_TABLE[5] then
		return const.DIRECTION8.U
	elseif iDir >= PI_DIV_8_TABLE[5] and iDir < PI_DIV_8_TABLE[7] then
		return const.DIRECTION8.LU
	elseif iDir >= PI_DIV_8_TABLE[7] and iDir < PI_DIV_8_TABLE[9] then
		return const.DIRECTION8.L
	elseif iDir >= PI_DIV_8_TABLE[9] and iDir < PI_DIV_8_TABLE[11] then
		return const.DIRECTION8.LD
	elseif iDir >= PI_DIV_8_TABLE[11] and iDir < PI_DIV_8_TABLE[13] then
		return const.DIRECTION8.D
	elseif iDir >= PI_DIV_8_TABLE[13] and iDir < PI_DIV_8_TABLE[15] then
		return const.DIRECTION8.RD
	else
		return const.DIRECTION8.R
	end
end

function math.DistanceSquare(obj1, obj2)
	local x1,y1 = obj1:getPosition()
	local x2,y2 = obj2:getPosition()
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end

function math.Distance(x1,y1, x2,y2)
	return math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) )
end 

function math.SquareDistance(x1,y1, x2,y2)
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end 

-----------------------------
--
-----------------------------
local function ParseFF(str)
	local high, low = string_sub(str,1,1), string_sub(str,2,2)
	high = high and CHAR2NUM[high] or tonumber(high) or 0
	low = low and CHAR2NUM[low] or tonumber(low) or 0
	return high * 16 + low
end

function math.ARGB2Hex(a,r,g,b)
	if type(a) == "table" then
		local tbl = a
		a,r,g,b = tbl.a or 255, tbl.r or 255, tbl.g or 255, tbl.b or 255
	end
	
	return string_format("%s%s%s%s%s%s%s%s", 
		NUM2CHAR[math_floor(a/16)], NUM2CHAR[a%16],
		NUM2CHAR[math_floor(r/16)], NUM2CHAR[r%16],
		NUM2CHAR[math_floor(g/16)], NUM2CHAR[g%16],
		NUM2CHAR[math_floor(b/16)], NUM2CHAR[b%16])
end

function math.Hex2ARGB(hex)
	local a = ParseFF( string_sub(hex, 1, 2) )
	local r = ParseFF( string_sub(hex, 3, 4) )
	local g = ParseFF( string_sub(hex, 5, 6) )
	local b = ParseFF( string_sub(hex, 7, 8) )
	return r,g,b,a
end

-----------------------------
-- Rect = { x=, y=, width=, height= }
-- Circle = { x=, y=, radius= }
-- Sector = { x=, y=, radius=, dir=ONE_PI/4, angle=ONE_PI/6 }
-----------------------------

function math.RectAndRect(rect1, rect2)
	return math_abs(rect1.x-rect2.x)<=rect1.width/2+rect2.width/2 and math_abs(rect1.y-rect2.y)<=rect1.height/2+rect2.height/2
end

function math.RectAndCircle(rect1, circle2)
	local rect2 = {
		x = circle2.x,
		y = circle2.y,
		width = circle2.radius*0.95,
		height = circle2.radius*0.95,
	}
	return math.RectAndRect(rect1, rect2)
end

function math.RectAndSector(rect1, sector1)
	assert(false,"尚未实现该方法")
end

function math.CircleAndRect(circle1, rect2)
	return math.RectAndCircle(rect2, circle1)
end

function math.CircleAndCircle(circle1, circle2)
	local x1,y1 = circle1.x, circle1.y 
	local x2,y2 = circle2.x, circle2.y 
	local minDis = circle1.radius + circle2.radius
	return (x1-x2)*(x1-x2)+(y1-y2)*(y1-y2) <= minDis*minDis
end

function math.CircleAndSector(circle1, sector1)
	local x1,y1 = circle1.x, circle1.y 
	local x2,y2 = sector1.x, sector1.y 
	local minDis = circle1.radius + sector1.radius
	local vecX,vecY = x1-x2, y1-y2
	if vecX*vecX+vecY*vecY > minDis*minDis then return false end
	local Angle = math.Vector2Radian(vecX,vecY)
	return math_abs(Angle-sector1.dir) <= sector1.angle 
end

function math.IsPointInRect(rect, Pt)
	local half_wid,half_hei = rect.width/2, rect.height/2
	return Pt.x >= rect.x-half_wid and Pt.x <= rect.x+half_wid and Pt.y >= rect.y-half_hei and Pt.y <= rect.y+half_hei
end

function math.IsPointInCircle(circle, Pt)
	return (Pt.x-circle.x)*(Pt.x-circle.x)+(Pt.y-circle.y)*(Pt.y-circle.y) <= circle.radius*circle.radius
end

function math.IsPointInSector(Sector, Pt)
--	local x0,y0 = Sector.x, Sector.y	--扇形原点坐标
	local SectorDir = Sector.dir		--扇形正前方方向
	local SectorAngle = Sector.angle	--扇形弧度
	local SectorRadius = Sector.radius	--扇形半径
	
	local X1,Y1 = Pt.x-Sector.x, Pt.y-Sector.y	--向量1
	if X1==0 and Y1==0 then return true end
	local X2,Y2 = math.Radian2Vector(SectorDir)	--向量2
	local square1 = X1*X1+Y1*Y1
	local cosValue = (X1*X2+Y1*Y2)/(math_sqrt(square1)*math_sqrt(X2*X2+Y2*Y2))
	local angle = math_acos(cosValue)

	return angle<=SectorAngle/2 and square1<=SectorRadius*SectorRadius
end
