#version 330 core  
out vec4 o_FragColor;

#include <etugl/phong_model.glsl>

#include <uniforms.glsl>
#include <utils.glsl>

void main(void) {  
    vec2 uv = ((v_UV * 2.0) - 1.0); // UV in clip space
    uv.x *= u_Resolution.x / u_Resolution.y;

    vec3 ray_origin = u_ViewPos;
    vec3 ray_direction = normalize(transpose(mat3(u_View)) * vec3(uv, -1.0));

    vec3 result = vec3(0.0);        // final color 
    float total_distance = 0.0;     // traveled distance

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 current_position = ray_origin + (ray_direction * total_distance);

        float min_scene_dist = MAXIMUM_TRACE_DISTANCE; 
        int candidate_idx = -1;

        for (int j = 0; j < NUM_PRIMITIVES; j++) {
            vec3 transformed_position = vec3(u_Primitives[j].inv_model * vec4(current_position, 1.0));

            float dist_local = calculate_distance(transformed_position, 
                                                  vec3(0.0), 1.0, 1.0, 
                                                  u_Primitives[j].type);

            vec3 sX = u_Primitives[j].inv_model[0].xyz;
            vec3 sY = u_Primitives[j].inv_model[1].xyz;
            vec3 sZ = u_Primitives[j].inv_model[2].xyz;            
            float max_axis = max(length(sX), max(length(sY), length(sZ)));

            dist_local *= (1.0/max_axis);

            if (dist_local < min_scene_dist) {
                min_scene_dist = dist_local;
                candidate_idx = j;
            }
        }

        if (min_scene_dist < MINIMUM_HIT_DISTANCE) {
            mat4 imtx = u_Primitives[candidate_idx].inv_model;

            vec3 transformed_position = vec3(imtx * vec4(current_position, 1.0));
            vec3 object_space_normal = calculate_normal(transformed_position, 
                                                        1.0, 1.0, 
                                                        u_Primitives[candidate_idx].type);

            mat3 normalMatrix = transpose(mat3(imtx));
            vec3 world_space_normal = normalize(normalMatrix * object_space_normal);

            vec3 light_dir = normalize(LIGHT_POS - current_position);
            vec3 diffuse = compute_diffuse(world_space_normal, light_dir, LIGHT_COLOR);

            result = (diffuse + 0.2) * u_Primitives[candidate_idx].color.xyz;
            break;
        }

        if (total_distance > MAXIMUM_TRACE_DISTANCE)
            break;

        total_distance += min_scene_dist;
    }
    
    o_FragColor = vec4(result, 1.0);
}
