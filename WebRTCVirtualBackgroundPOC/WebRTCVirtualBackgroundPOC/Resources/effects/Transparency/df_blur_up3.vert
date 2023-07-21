#version 300 es

layout( location = 0 ) in vec3 attrib_pos;

layout(std140) uniform glfx_GLOBAL
{
    mat4 glfx_MVP;
    mat4 glfx_PROJ;
    mat4 glfx_MV;
    vec4 unused;
    vec4 js_data[16];
    vec4 js_radius;
};

out vec4 var_uv;
out float radius;

uniform sampler2D tex_df_blur_d3;

void main()
{	
	radius = js_radius.x;
	vec2 v = attrib_pos.xy;

	gl_Position = vec4( v, 1., 1. );
	var_uv.xy = v*0.5 + 0.5;
	var_uv.zw = var_uv.xy + 0.5/vec2(textureSize(tex_df_blur_d3,0));
}