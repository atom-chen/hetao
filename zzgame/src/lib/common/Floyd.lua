-------------------------
-- 寻找最短路径
-------------------------
module("Floyd", package.seeall)

-- 地图数据
local MAXNUM = 999999
local dist = {}
local path = {}


function floyd(roadmap, vtxCount)
	-- 初始化dist和path
	for i=0,vtxCount-1 do 
		dist[i] = {}
		path[i] = {}
	end 
	for i=0, vtxCount-1 do 
		for j=0, vtxCount-1 do 
			path[i][j] = -1
			dist[i][j] = roadmap[i][j] or MAXNUM
		end 
	end 
	
	--
	for k=0, vtxCount-1 do 
		for i=0, vtxCount-1 do 
			for j=0, vtxCount-1 do 
				if dist[i][k] ~= MAXNUM and dist[k][j] ~= MAXNUM and dist[i][k]+dist[k][j] < dist[i][j] then
					dist[i][j] = dist[i][k] + dist[k][j]
					path[i][j] = k 
				end 
			end 
		end 
	end 
end 


function FindPath(result, i, j)
	if not path[i] or not path[i][j] then return false end 
	local k = path[i][j]
	if k == -1 then return false end 
	FindPath(result, i,k)
	table.insert(result, k)
	FindPath(result, k,j)
	return true
end 

function FindCheapestPath(from, to, roadmap, vtxCount)
	floyd(roadmap, vtxCount)
	
	print("========== 寻路结果：", from, to)
	
	local result = {}
	
	if FindPath(result, from,to) then
		table.insert(result, 1, from)
		table.insert(result, to)
	else 
		print("寻路失败")
	end 
	
	--打印结果
	for k,v in ipairs(result) do 
		print(k,v) 
	end
end 

function GetVertexCount(xmap)
	local cnt = 0
	for i, list in pairs(xmap) do 
		if i > cnt then cnt = i end 
		for j, witght in pairs(list) do 
			if j > cnt then cnt = j end 
		end 
	end 
	return cnt==0 and 0 or cnt+1
end 

----------------
-- 测试
----------------

--[[
local xmap = {}   for i=0, 12 do xmap[i] = {} end 
xmap[0][1] = 1
xmap[0][5] = 1
xmap[2][0] = 1
xmap[2][3] = 1
xmap[3][2] = 1
xmap[3][5] = 1
xmap[4][2] = 1
xmap[4][3] = 1
xmap[5][4] = 1
xmap[6][0] = 1
xmap[6][4] = 1
xmap[6][9] = 1
xmap[7][6] = 1
xmap[7][8] = 1
xmap[8][7] = 1
xmap[8][9] = 1
xmap[9][10] = 1
xmap[9][11] = 1
xmap[10][12] = 1
xmap[11][4] = 1
xmap[11][12] = 1
xmap[12][9] = 1

local cnt = GetVertexCount(xmap)

for i=0,cnt do 
	for j=0,cnt do 
		FindCheapestPath(i,j,xmap,cnt)
	end 
end 
]]
