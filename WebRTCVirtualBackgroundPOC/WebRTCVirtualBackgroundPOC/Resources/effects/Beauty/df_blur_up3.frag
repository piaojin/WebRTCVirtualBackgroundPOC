#version 300 es
precision lowp float;
layout( location = 0 ) out vec4 F;
uniform sampler2D tex_df_blur_u2;
in vec4 var_uv;
in float radius;
void main(){
	vec3 sum = 
		(1./6.)*(
			texture      (tex_df_blur_u2,var_uv.zw             ).xyz + 
			texture(tex_df_blur_u2,var_uv.zw + vec2(-radius, 0)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
			texture(tex_df_blur_u2,var_uv.zw + vec2( 0,-radius)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
			texture(tex_df_blur_u2,var_uv.zw + vec2(-radius,-radius)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
		(1./12.)*(
			texture(tex_df_blur_u2,var_uv.xy + vec2( radius, 0)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
			texture(tex_df_blur_u2,var_uv.xy + vec2(-radius, 0)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
			texture(tex_df_blur_u2,var_uv.xy + vec2( 0, radius)/vec2(textureSize(tex_df_blur_u2,0))).xyz + 
			texture(tex_df_blur_u2,var_uv.xy + vec2( 0,-radius)/vec2(textureSize(tex_df_blur_u2,0))).xyz));
	F = vec4(sum,1.);
}