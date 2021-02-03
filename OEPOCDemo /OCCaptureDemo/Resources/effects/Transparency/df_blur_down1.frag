#version 300 es
precision lowp float;
layout( location = 0 ) out vec4 F;
uniform sampler2D glfx_BACKGROUND;
in vec2 var_uv;

in float radius;

void main()
{	
	vec3 sum = 
		0.5*texture(glfx_BACKGROUND,var_uv).xyz + 
		0.125*(
			texture(glfx_BACKGROUND,var_uv + vec2( radius, radius)/vec2(textureSize(glfx_BACKGROUND,0))).xyz + 
			texture(glfx_BACKGROUND,var_uv + vec2(-radius, radius)/vec2(textureSize(glfx_BACKGROUND,0))).xyz + 
			texture(glfx_BACKGROUND,var_uv + vec2(-radius,-radius)/vec2(textureSize(glfx_BACKGROUND,0))).xyz + 
			texture(glfx_BACKGROUND,var_uv + vec2( radius,-radius)/vec2(textureSize(glfx_BACKGROUND,0))).xyz); 
	F = vec4(sum,1.);
}