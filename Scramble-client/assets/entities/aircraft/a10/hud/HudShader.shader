    shader_type spatial;
    render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx;
    
    uniform sampler2D texture_albedo : hint_albedo;
    uniform float tex_scale = 0.1;
    uniform float intensity_factor = 1.0;
    
    varying vec3 v_vertex;
    varying vec3 v_pos;
    varying vec3 v_normal;
    varying vec3 v_tangent;
    
    void vertex() {
        v_vertex = ((PROJECTION_MATRIX * MODELVIEW_MATRIX) * vec4(VERTEX, 1.0)).xyz;
        v_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
        v_normal = (transpose(inverse(MODELVIEW_MATRIX)) * vec4(NORMAL, 0.0)).xyz;
        v_tangent = (transpose(inverse(MODELVIEW_MATRIX)) * vec4(TANGENT, 0.0)).xyz;
    }
    
    void fragment() {
        vec3 normal = normalize(v_normal);
        vec3 tangent = normalize(v_tangent);
        vec3 cameraDir = normalize(v_pos);
        vec3 offset = cameraDir + normal;
        
        mat3 mat = mat3(
            -tangent,
            cross(-normal, -tangent),
            vec3(normal.x, -normal.y, normal.z)
        );
        
        offset = mat * offset;
        
        vec2 uv = (offset.xy / tex_scale) * vec2(1.0, -1.0);	// flip vertically
        
        ALBEDO = texture(texture_albedo, uv + vec2(0.5, 0.5)).xyz * intensity_factor;
        ALPHA = texture(texture_albedo, uv + vec2(0.5, 0.5)).a;
        ALPHA_SCISSOR = 0.1;
    }
