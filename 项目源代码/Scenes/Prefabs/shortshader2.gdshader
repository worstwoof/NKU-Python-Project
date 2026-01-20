shader_type spatial;

// --- 基础控制 ---
uniform vec3 building_color : source_color = vec3(0.02, 0.02, 0.03);
uniform float emission_strength : hint_range(0.0, 5.0) = 1.5; 

// --- 世界坐标缩放 ---
uniform float global_scale : hint_range(0.1, 5.0) = 0.5; 

// --- 独立亮度控制 ---
uniform float billboard_strength : hint_range(0.0, 10.0) = 1.0;  

// --- 颜色调色板 ---
uniform vec3 window_color_hot : source_color = vec3(1.0, 0.3, 0.5);   
uniform vec3 window_color_cool : source_color = vec3(0.0, 0.5, 0.9);  
uniform vec3 billboard_color  : source_color = vec3(0.0, 0.9, 0.7);   

// --- 密度设置 ---
uniform vec2 tile_factor = vec2(4.0, 8.0); 
uniform float window_density : hint_range(0.0, 1.0) = 0.4; 
uniform float billboard_density : hint_range(0.0, 1.0) = 0.25; 

// --- 【新功能】速度控制 ---
// 数值越小越慢。0.5 是默认的慢速，你可以自己在检查器里拖动调整。
uniform float animation_speed : hint_range(0.0, 5.0) = 0.5;

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
    vec2 cell_id = floor(grid_uv * tile_factor); 
    vec2 cell_uv = fract(grid_uv * tile_factor);
    
    float rnd_base = random(cell_id);

    // ============================
    // 1. 基础窗户
    // ============================
    float width = 0.85; 
    float height = 0.4; 
    vec2 start = vec2((1.0 - width) / 2.0, (1.0 - height) / 2.0);
    
    float window_mask = 
        smoothstep(start.x, start.x+0.1, cell_uv.x) * smoothstep(start.x+width, start.x+width-0.1, cell_uv.x) *
        smoothstep(start.y, start.y+0.1, cell_uv.y) * smoothstep(start.y+height, start.y+height-0.1, cell_uv.y);

    vec3 win_col = (random(cell_id + 3.0) < 0.6) ? window_color_cool : window_color_hot;
    
    // [关键修改] 呼吸速度变慢
    // 这里的 TIME 乘以了 animation_speed。如果 animation_speed 是 0.5，速度就是原来的一半。
    float breath = 0.7 + 0.3 * sin(TIME * animation_speed + rnd_base * 10.0);
    
    float is_lit = step(1.0 - window_density, rnd_base);
    is_lit *= step(0.2, random(vec2(0.0, cell_id.y))); 

    // ============================
    // 2. 巨型广告牌
    // ============================
    vec2 bb_grid_factor = vec2(2.0, 1.0); 
    vec2 bb_id = floor(grid_uv * bb_grid_factor);
    vec2 bb_uv = fract(grid_uv * bb_grid_factor);
    
    float is_billboard = step(1.0 - billboard_density, random(bb_id + 77.7));

    float border = step(0.03, bb_uv.x) * step(bb_uv.x, 0.97) * step(0.05, bb_uv.y) * step(bb_uv.y, 0.95);
    float content_area = step(0.08, bb_uv.x) * step(bb_uv.x, 0.92) * step(0.15, bb_uv.y) * step(bb_uv.y, 0.85);
    float frame_mask = border - content_area; 

    // 像素内容
    vec2 data_grid = floor(bb_uv * vec2(8.0, 4.0)); 
    float data_dots = step(0.5, random(data_grid + bb_id)); 
    data_dots *= step(0.3, random(vec2(0.0, data_grid.y))); 
    
    // [关键修改] 扫描线速度变得极慢
    // 乘以 0.2 * animation_speed，这意味着它比窗户的呼吸还要慢很多，只是微微漂动。
    float scanline = 0.9 + 0.1 * sin(bb_uv.y * 100.0 + TIME * 0.2 * animation_speed); 

    float inner_content = content_area * data_dots * 0.5; 
    float billboard_pattern = (frame_mask + inner_content) * scanline;

    // ============================
    // 3. 最终合成
    // ============================
    vec3 final_emission = vec3(0.0);

    vec3 color_win = win_col * emission_strength * window_mask * is_lit * breath;
    vec3 color_bb = billboard_color * billboard_strength * billboard_pattern;

    if (is_billboard > 0.5) {
        final_emission = color_bb;
    } else {
        final_emission = color_win;
    }

    float tech_line = step(0.98, fract(grid_uv.x * 5.0)) + step(0.98, fract(grid_uv.y * 2.0));
    ALBEDO = building_color + vec3(tech_line * 0.02);
    EMISSION = final_emission;
}