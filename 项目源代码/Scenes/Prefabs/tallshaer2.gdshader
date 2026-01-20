shader_type spatial;

// --- 基础控制 ---
uniform vec3 building_color : source_color = vec3(0.02, 0.02, 0.03);
uniform float emission_strength : hint_range(0.0, 8.0) = 2.5;

// --- 世界坐标缩放 ---
uniform float global_scale : hint_range(0.1, 10.0) = 0.8;

// --- 颜色配置 ---
uniform vec3 light_primary : source_color = vec3(0.0, 0.5, 0.9);
uniform vec3 light_secondary : source_color = vec3(0.6, 0.3, 1.0);
uniform vec3 light_alert : source_color = vec3(1.0, 0.2, 0.1);

// --- 密度控制 ---
uniform float light_density : hint_range(0.0, 1.0) = 0.25;

// 传递世界坐标
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

    float rnd_base = random(cell_id);

    // ============================
    // 1. 窗户形状
    // ============================
    float width = 0.7 + 0.2 * random(cell_id + 1.0);
    float height = 0.35;

    vec2 start = vec2((1.0 - width) / 2.0, (1.0 - height) / 2.0);

    float window_shape =
        smoothstep(start.x, start.x + 0.05, cell_uv.x) *
        smoothstep(start.x + width, start.x + width - 0.05, cell_uv.x) *
        smoothstep(start.y, start.y + 0.05, cell_uv.y) *
        smoothstep(start.y + height, start.y + height - 0.05, cell_uv.y);

    // ============================
    // 2. 颜色分配
    // ============================
    vec3 final_color;
    float col_rnd = random(cell_id + 5.0);

    if (col_rnd < 0.6) final_color = light_primary;
    else if (col_rnd < 0.85) final_color = light_secondary;
    else final_color = light_alert;

    // ============================
    // 3. 基础逻辑 (完全静止)
    // ============================
    // [修改] 之前这里有 sin(TIME)，现在直接设为 1.0，彻底不动。
    float breath = 1.0;

    float is_lit = step(1.0 - light_density, rnd_base);
    is_lit *= step(0.2, random(vec2(0.0, cell_id.y)));

    // ============================
    // 4. 最终合成
    // ============================
    vec3 final_emission = final_color * emission_strength * window_shape * is_lit * breath;

    float grid_line = step(0.98, fract(projected_uv.y * global_scale));
    ALBEDO = building_color + vec3(grid_line * 0.05);
    EMISSION = final_emission;
}