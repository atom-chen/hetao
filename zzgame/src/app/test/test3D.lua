----------------------
-- test 3D
----------------------
local test = {}

function test.create3dSprite(fileName, parent, x, y)
    local spr3d = cc.Sprite3D:create(fileName)
    spr3d:setPosition( cc.p(x,y) )
    KE_SetParent(spr3d, parent)
    
    local animation = cc.Animation3D:create(fileName)
    if nil ~= animation then
        local animate = cc.Animate3D:create(animation)
        spr3d:runAction(cc.RepeatForever:create(animate))
    end
    
    return spr3d
end

function test.test_3D(parent)
	assert(parent)
	
	local xBegin, xInterval = 300, 200
	--1
    local spr3d = create3dSprite("tests/role_test/jiluo2006.c3t", parent, xBegin+xInterval*0, 400)
	spr3d:setRotation3D({x = -20, y = 90, z = 0})
    
    --2
    spr3d = create3dSprite("tests/Sprite3DTest/tortoise.c3b", parent, xBegin+xInterval*1, 400)
    spr3d:setScale(0.15)
    
    --3 
    spr3d = create3dSprite("tests/Sprite3DTest/orc.c3b", parent, xBegin+xInterval*2, 400)
    spr3d:setScale(5)
   	spr3d:setRotation3D({x = 0, y = 180, z = 0})
    
    --4
    local spr3d = create3dSprite("tests/Sprite3DTest/cylinder.c3b", parent, xBegin+xInterval*3, 400)
    spr3d:setScale(5.0)
    spr3d:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
    spr3d:setRotation3D({x = 90, y = 0, z = 0})
	
	--5
    spr3d = create3dSprite("tests/Sprite3DTest/ReskinGirl.c3b", parent, xBegin+xInterval*4, 400)
    spr3d:setScale(4)
    spr3d:setRotation3D({x = 0, y =0 ,z = 0})
    
    local info = {
    	_girlPants = {"Girl_LowerBody01", "Girl_LowerBody02"},
	    _girlUpperBody = {"Girl_UpperBody01", "Girl_UpperBody02"},
	    _girlShoes = {"Girl_Shoes01", "Girl_Shoes02"},
	    _girlHair = {"Girl_Hair01", "Girl_Hair02"},
	    _usePantsId = 0,
	    _useUpBodyId = 0,
	    _useShoesId =0,
	    _useHairId = 0,
    }
    
    local girlPants = spr3d:getMeshByName(info._girlPants[2])
    if girlPants then girlPants:setVisible(false) end

    local girlShoes = spr3d:getMeshByName(info._girlShoes[2])
    if girlShoes then girlShoes:setVisible(false) end

    local girlHair = spr3d:getMeshByName(info._girlHair[2])
    if girlHair then girlHair:setVisible(false) end

    local girlUpBody = spr3d:getMeshByName( info._girlUpperBody[2])
    if girlUpBody then girlUpBody:setVisible(false) end
end

return test
