#version 320 es

precision mediump float;
layout (location = 0) in vec2 inPos;
layout (location = 1) in vec2 inUV;
out vec2 UV;

void main ()
{
    vec2 inPos_normal = inPos - vec2 (0.5,0.5);
    inPos_normal /= vec2 (0.5,0.5);
    gl_Position = vec4 (inPos_normal,0,1);
    
    UV = inUV;
}
