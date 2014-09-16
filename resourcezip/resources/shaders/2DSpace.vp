#version 330 core

layout (location = 0) in vec2 inPos;
layout (location = 1) in vec2 inUV;
out vec2 outUV;

void main ()
{
	vec2 inPos_normal = inPos - vec2 (0.5,0.5);
	inPos_normal /= vec2 (0.5,0.5);
	gl_Position =  vec4 (inPos_normal,0,1);
	
	outUV = inUV;
}
