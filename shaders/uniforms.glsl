#ifndef UNIFORMS
#define UNIFORMS

#define LIGHT_POS   vec3(2.0, -5.0, 3.0)
#define LIGHT_COLOR vec3(1.0, 1.0, 1.0)

#define NUM_PRIMITIVES 50 
#define MAX_STEPS 200
#define MINIMUM_HIT_DISTANCE 0.001
#define MAXIMUM_TRACE_DISTANCE 1000.0

struct Primitives {
    float type; // 0: sphere, 1: cube, 2: cylinder
    vec4 color;
    mat4 model;
    mat4 inv_model;
};

in vec2 v_UV;
uniform vec2 u_Resolution;

// Camera uniform
uniform vec3 u_ViewPos;
uniform mat4 u_View;
uniform mat4 u_InvView;
uniform mat4 u_Projection;

uniform Primitives u_Primitives[NUM_PRIMITIVES];

#endif
