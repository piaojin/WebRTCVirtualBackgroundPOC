#version 300 es
precision lowp float;
layout( location = 0 ) out vec4 F;
uniform sampler2D tex_df_blur_d2;
in vec2 var_uv;
in float radius;

void main()
{
	vec3 sum = 
		0.5*texture(tex_df_blur_d2,var_uv).xyz + 
		0.125*(
			texture(tex_df_blur_d2,var_uv + vec2( radius, radius)/vec2(textureSize(tex_df_blur_d2,0))).xyz + 
			texture(tex_df_blur_d2,var_uv + vec2(-radius, radius)/vec2(textureSize(tex_df_blur_d2,0))).xyz + 
			texture(tex_df_blur_d2,var_uv + vec2(-radius,-radius)/vec2(textureSize(tex_df_blur_d2,0))).xyz + 
			texture(tex_df_blur_d2,var_uv + vec2( radius,-radius)/vec2(textureSize(tex_df_blur_d2,0))).xyz); 
	F = vec4(sum,1.);
}