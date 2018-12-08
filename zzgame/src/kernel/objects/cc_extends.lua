-----------------------------
-- cocos扩展
-----------------------------
KE_ExtendClass(cc.Node)
KE_ExtendClass(cc.Layer)
KE_ExtendClass(cc.Scene)

KE_ExtendClass(cc.Sprite)
KE_ExtendClass(cc.Scale9Sprite)
KE_ExtendClass(ccs.Armature)
KE_ExtendClass(sp.SkeletonAnimation)

KE_ExtendClass(cc.PUParticleSystem3D)
KE_ExtendClass(cc.Sprite3D)

KE_ExtendClass(cc.Label)
KE_ExtendClass(ccui.Button)
KE_ExtendClass(ccui.CheckBox)
KE_ExtendClass(ccui.EditBox)
KE_ExtendClass(ccui.ListView)
KE_ExtendClass(ccui.ScrollView)
KE_ExtendClass(ccui.Layout)
KE_ExtendClass(ccui.ImageView)
KE_ExtendClass(ccui.PageView)
KE_ExtendClass(ccui.LoadingBar)
KE_ExtendClass(ccui.RichText)

-- node layer scene particle
-- sprite scale9sprite seqSprite armSprite spineSprite
-- sprite3d effect3d 
-- label richtext window editor progressbar button checkbox(checkgroup) scrollview tableview listview
if GAME_CONFIG.VV_DISABLE_CCOBJECT_SPACE then
	cc.Node = nil
	cc.Layer = nil
	cc.Scene = nil
	cc.ParticleSystemQuad = nil
	
	cc.Sprite = nil
	cc.Scale9Sprite = nil
	cc.Sprite = nil
	ccs.Armature = nil
	cocos.spine = nil
	
	cc.Sprite3D = nil
	cc.Sprite3D = nil
	
	cc.Label = nil
	ccui.RichText = nil
	ccui.ImageView = nil
	ccui.EditBox = nil
	ccui.LoadingBar = nil
	ccui.Button = nil
	ccui.RadioButton = nil
	ccui.ScrollView = nil
	ccui.TableView = nil
	ccui.ListView = nil
end
