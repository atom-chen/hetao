#ifdef GL_ES
precision highp float;
#endif
varying vec2 v_texCoord;

uniform vec3  radiusInfo;
 
void main(void) {
	vec2 texCoordLB=v_texCoord;
	texCoordLB.y=1.0-texCoordLB.y;
	vec2 origin=vec2(radiusInfo.x,radiusInfo.y); 
	vec2 currentCoord=vec2(texCoordLB.x*radiusInfo.x*2.0,texCoordLB.y*radiusInfo.y*2.0);
	vec2 currentDeta=currentCoord-origin;
	float len=length(currentDeta);
	if(len<=radiusInfo.z)
	{
		gl_FragColor = texture2D(CC_Texture0, v_texCoord);
	}
	else
	{
		discard;
	}
}
