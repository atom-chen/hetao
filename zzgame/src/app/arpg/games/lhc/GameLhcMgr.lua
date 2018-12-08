-------------------------
-- lhc游戏管理器
-------------------------
ClsGameLhcMgr = class("ClsGameLhcMgr", clsGameInterface)
ClsGameLhcMgr.__is_singleton = true

function ClsGameLhcMgr:ctor()
	clsGameInterface.ctor(self)
end

function ClsGameLhcMgr:dtor()
	
end

local COMBINE_INF = {
	["5z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 5, maxCnt = 10 },
	["6z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 6, maxCnt = 10 },
	["7z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 7, maxCnt = 10 },
	["8z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 8, maxCnt = 11 },
	["9z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 9, maxCnt = 12 },
	["10z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 10, maxCnt = 13 },
	["11z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 11, maxCnt = 11 },
	["12z1"] = { billType = const.BILL_TYPE.MzN, onceCnt = 12, maxCnt = 12 },
	
	["5bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 5, maxCnt = -1 },
	["6bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 6, maxCnt = -1 },
	["7bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 7, maxCnt = -1 },
	["8bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 8, maxCnt = -1 },
	["9bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 9, maxCnt = -1 },
	["10bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 10, maxCnt = -1 },
	["11bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 11, maxCnt = -1 },
	["12bz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 12, maxCnt = -1 },
	
	["2xl"] = { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = 6 },
	["3xl"] = { billType = const.BILL_TYPE.MxN, onceCnt = 3, maxCnt = 7 },
	["4xl"] = { billType = const.BILL_TYPE.MxN, onceCnt = 4, maxCnt = 8 },
	["5xl"] = { billType = const.BILL_TYPE.MxN, onceCnt = 5, maxCnt = 9 },
	
	["4qz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 4, maxCnt = -1 },
	["3qz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 3, maxCnt = -1 },
	["2qz"] = { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = -1 },
	
	["3z2"] = { billType = const.BILL_TYPE.MzN, onceCnt = 3, maxCnt = 8 },
	["2zt"] = { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = -1 },
	
	["tc"] = { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = 2 },
	
	["zmgg"] = { billType = const.BILL_TYPE.MULTY_GRP, onceCnt = 1, maxCnt = 1, minGrpCnt = 2 },
	
	["z"] = { billType = const.BILL_TYPE.LHC_HX, onceCnt = 1, maxCnt = -1 },
	["bz"] = { billType = const.BILL_TYPE.LHC_HX, onceCnt = 1, maxCnt = -1 },
	
	["2wp"] = { billType = const.BILL_TYPE.MxN, onceCnt = 2, maxCnt = -1 },
	["3wp"] = { billType = const.BILL_TYPE.MxN, onceCnt = 3, maxCnt = -1 },
	["4wp"] = { billType = const.BILL_TYPE.MxN, onceCnt = 4, maxCnt = -1 },
	["5wp"] = { billType = const.BILL_TYPE.MxN, onceCnt = 5, maxCnt = -1 },
}
function ClsGameLhcMgr:GetBallCombineInfo(tid)
	local groupInfo = self:GetMenuOfGroup(nil, tid)
	if not groupInfo then return nil end
	local sname = groupInfo.sname
	if COMBINE_INF[sname] then
		return COMBINE_INF[sname]
	end
	return { billType = const.BILL_TYPE.SINGLE, onceCnt = 1, maxCnt = 1 }
end

function ClsGameLhcMgr:InitLhcSxData(recvdata)
	if recvdata and recvdata.data then
		self._lhcSxData = recvdata.data
	end
end

function ClsGameLhcMgr:ReqLhcSxData()
	if self._lhcSxData then return self._lhcSxData end
	proto.req_goucai_game_lhc_sx()
	return setting.T_lhc_sx
end

local CODE_FIX = { ["1"]="01", ["2"]="02", ["3"]="03", ["4"]="04", ["5"]="05", ["6"]="06", ["7"]="07", ["8"]="08", ["9"]="09" }
function ClsGameLhcMgr:GetBallColor(code)
	if not is_string(code) then code = tostring(code) end
	if CODE_FIX[code] then code = CODE_FIX[code] end
	return const.GAME_LHC_COLOR[ self._lhcSxData.sb[code] ]
end
function ClsGameLhcMgr:GetBallZodiac(code)
	if not is_string(code) then code = tostring(code) end
	if CODE_FIX[code] then code = CODE_FIX[code] end
	return self._lhcSxData.sx[code]
end
function ClsGameLhcMgr:GetShengXiaoCodes(sSxName)
	local codes = {}
	for code, name in pairs(self._lhcSxData.sx) do
		if name == sSxName then
			table.insert(codes, code)
		end
	end
	table.sort(codes)
	return table.concat(codes, " ")
end
