shader_type spatial;

// --- 基础外观 ---
uniform vec3 building_color : source_color = vec3(0.01, 0.01, 0.01); // 纯黑哑光底色
uniform float emission_strength : hint_range(0.0, 5.0) = 2.0;        // 缝隙亮度

// --- 世界坐标缩放 ---
// 建议设小一点 (0.5 - 1.0)，让装甲板看起来很大
uniform float global_scale : hint_range(0.1, 5.0) = 0.6; 

// --- 颜色配置 ---
uniform vec3 energy_color_a : source_color = vec3(0.6, 0.0, 1.0); // 缝隙颜色：深紫
uniform vec3 energy_color_b : source_color = vec3(0.0, 0.8, 1.0); // 核心颜色：青蓝
uniform vec3 energy_color_c : source_color = vec3(1.0, 0.6, 0.0); // 警示颜色：橙

// --- 密度与细节 ---
uniform float plate_density : hint_range(0.0, 1.0) = 0.8; // 装甲板覆盖率
uniform float tech_detail : hint_range(0.0, 1.0) = 0.5;   // 表面纹理细节

varying vec3 world_pos;
varying vec3 world_normal;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    // --- 世界坐标映射 ---
    vec2 projected_uv;
    vec3 abs_normal = abs(world_normal);
    if (abs_normal.x > 0.5) projected_uv = world_pos.zy;
    else if (abs_normal.z > 0.5) projected_uv = world_pos.xy;
    else projected_uv = world_pos.xz;

    vec2 grid_uv = projected_uv * global_scale;
    vec2 cell_id = floor(grid_uv);
    vec2 cell_uv = fract(grid_uv);
    float rnd = random(cell_id);

    // ============================
    // 1. 装甲板缝隙 (Energy Seams)
    // ============================
    // 不再画窗户，而是画板子边缘的缝隙
    // distance_to_edge 计算像素距离格子边缘有多远
    vec2 dist_vec = min(cell_uv, 1.0 - cell_uv);
    float dist_to_edge = min(dist_vec.x, dist_vec.y);
    
    // 缝隙宽度：非常细的线条 (0.02)
    float seam_mask = 1.0 - smoothstep(0.0, 0.03, dist_to_edge);
    
    // 十字交叉点加亮：让缝隙交汇处有个亮斑，增加科技感
    float intersection = (1.0 - smoothstep(0.0, 0.1, dist_vec.x)) * (1.0 - smoothstep(0.0, 0.1, dist_vec.y));

    // ============================
    // 2. 核心模块 (Tech Core)
    // ============================
    // 偶尔有一些格子不是装甲，而是发光的“散热口”或“核心”
    // 概率很低 (10% 左右)
    float is_core = step(0.9, random(cell_id + 1.23)); 
    
    // 核心的形状：中间有个方块，周围有两圈线
    float core_shape = step(0.2, max(abs(cell_uv.x - 0.5), abs(cell_uv.y - 0.5)));
    core_shape = 1.0 - core_shape; // 反转，变成中间亮
    
    // 给核心加一点条纹细节
    float core_stripes = step(0.5, sin(cell_uv.y * 20.0));
    if (is_core > 0.5) {
        seam_mask = 0.0; // 如果是核心，就去掉缝隙，改显示核心图案
    }

    // ============================
    // 3. 表面微纹理 (Matte Texture)
    // ============================
    // 即使是黑色的板子，表面也不要死黑，加一点点噪点或划痕感
    float noise = random(grid_uv * 10.0);
    float plate_texture = 0.05 * noise; 

    // ============================
    // 4. 颜色合成
    // ============================
    vec3 final_emission = vec3(0.0);
    
    // A. 缝隙光 (深紫色，微弱)
    // 随机让某些缝隙断开 (看起来像电路板，而不是网格)
    float seam_break = step(0.3, random(cell_id + 5.0)); 
    vec3 seam_light = energy_color_a * seam_mask * seam_break * 0.8; // 0.8 是压暗系数
    
    // B. 核心光 (青色/橙色，稍亮)
    vec3 core_color = (rnd < 0.5) ? energy_color_b : energy_color_c;
    // 核心光是静止的，但有一点点强弱差异
    vec3 core_light = core_color * core_shape * core_stripes * 1.5; 

    // C. 交汇点光 (高亮小白点)
    vec3 cross_light = vec3(1.0) * intersection * seam_break * 0.5;

    if (is_core > 0.5) {
        final_emission = core_light * emission_strength;
    } else {
        final_emission = (seam_light + cross_light) * emission_strength;
    }

    // ============================
    // 5. 最终输出
    // ============================
    // Albedo 主要是黑色，带一点点纹理
    ALBEDO = building_color + vec3(plate_texture);
    
    // Roughness 设高一点，让黑色部分像橡胶或哑光金属
    ROUGHNESS = 0.8; 
    METALLIC = 0.5;
    
    EMISSION = final_emission;
}