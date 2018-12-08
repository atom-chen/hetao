-------------------------
-- XTree对象的上下文管理
-------------------------
module("smartor",package.seeall)

clsSmartContext = class("clsSmartContext")

function clsSmartContext:ctor()
	self.tAllAtoms = {}			--所有创建的元素，包括角色、特效、面板、子弹
	self.tPerformerTable = {}	--演员表
	self.tAtomIdTable = {}		--元素表，记录所有元素ID，方便决定哪个Atom由某对象来扮演
end

function clsSmartContext:dtor()
	local dellist = {}
	for atom_id, _ in pairs(self.tAllAtoms) do
		if not self.tPerformerTable[atom_id] then
			dellist[#dellist+1] = atom_id
		end
	end
	for _, delid in ipairs(dellist) do
		self:DestroyAtom(atom_id)
	end
	self.tAllAtoms = {}
	self.tPerformerTable = {}
	self.tAtomIdTable = {}
end


function clsSmartContext:checkCreate(atom_id)
	assert(not self.tAllAtoms[atom_id], "重复创建相同ID的元素: "..atom_id)
	local performer = self:GetPerFormer(atom_id)
	if performer then
		self.tAllAtoms[atom_id] = performer
		logger.warn("滴滴滴滴 演员就位", atom_id)
		return performer
	end
	return nil 
end 

------------------------------------------------------------
function clsSmartContext:CreateXRole(atom_id, TypeId)
	local obj = self:checkCreate(atom_id)
	if obj then return obj end 
	self.tAllAtoms[atom_id] = ClsRoleSprMgr.GetInstance():CreateTempRole(TypeId)
	return self.tAllAtoms[atom_id]
end

function clsSmartContext:CreateXEffect(atom_id, res_path)
	local obj = self:checkCreate(atom_id)
	if obj then return obj end 
	self.tAllAtoms[atom_id] = ClsEffectMgr.GetInstance():CreateEffectSeq(atom_id, res_path)
	return self.tAllAtoms[atom_id]
end

function clsSmartContext:CreateXPanel(atom_id, panel_clsname)
	local obj = self:checkCreate(atom_id)
	if obj then return obj end 
	self.tAllAtoms[atom_id] = ui[panel_clsname].new()
	KE_SetParent(self.tAllAtoms[atom_id], ClsLayerManager.GetInstance():GetLayer(const.LAYER_VIEW))
	return self.tAllAtoms[atom_id]
end

function clsSmartContext:CreateXSprite(atom_id, respath)
	local obj = self:checkCreate(atom_id)
	if obj then return obj end 
	self.tAllAtoms[atom_id] = utils.CreateSprite(respath)
	return self.tAllAtoms[atom_id]
end

------------------------------------------------------------
function clsSmartContext:DestroyAtom(atom_id)
	if self.tAllAtoms[atom_id] then
		KE_SafeDelete(self.tAllAtoms[atom_id])
		self.tAllAtoms[atom_id] = nil
	end
	self.tPerformerTable[atom_id] = nil 
end

function clsSmartContext:GetAtom(atom_id)
	if not self.tAtomIdTable[atom_id] then
		assert(false, "剧情文件中没有配置该atom_id: " .. atom_id .. ", 请检查配置是否正确")
		return nil
	end
	if self.tPerformerTable[atom_id] then 
		return self.tPerformerTable[atom_id]
	end
	return self.tAllAtoms[atom_id]
end

------------------------------------------------------------
function clsSmartContext:MarkAtomId(atom_id)
	if atom_id == nil then return end
	self.tAtomIdTable[atom_id] = atom_id
end

function clsSmartContext:HasAtomId(atom_id)
	return self.tAtomIdTable[atom_id] ~= nil
end

-- 由obj来演角色atom_id
-- 注意：在播放前设置演员
function clsSmartContext:SetPerformer(atom_id, obj)
	if not self.tAtomIdTable[atom_id] then
		assert(false, "剧情文件中没有配置该atom_id: " .. atom_id .. ", 请检查配置或参数是否正确")
		return false
	end
	assert(obj, "Invilid Performer")
	if self.tPerformerTable[atom_id] and self.tPerformerTable[atom_id]~=obj then
		assert(false, "已经有人来演："..atom_id)
		return false
	end
	
	self.tPerformerTable[atom_id] = obj
	return true
end

function clsSmartContext:KickPerformer(atom_id)
	if not self.tAtomIdTable[atom_id] then
		assert(false, "剧情文件中没有配置该atom_id: " .. atom_id .. ", 请检查配置或参数是否正确")
		return false
	end
	self.tPerformerTable[atom_id] = nil 
end 

function clsSmartContext:GetPerFormer(atom_id)
	return self.tPerformerTable[atom_id]
end

------------------------------------------------------------
function clsSmartContext:DumpDebugInfo()
	logger.warn("--------演员表 BEGIN---------")
	for atom_id, _ in pairs(self.tAtomIdTable) do
		logger.warn(atom_id, "----->", self.tPerformerTable[atom_id])
	end
	logger.warn("--------演员表 END---------")
end
