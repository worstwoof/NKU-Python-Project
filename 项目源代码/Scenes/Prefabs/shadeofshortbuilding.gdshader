shader_type spatial;

// --- 基础控制 ---
uniform vec3 building_color : source_color = vec3(0.01, 0.01, 0.02);
uniform float emission_strength : hint_range(0.0, 8.0) = 3.0;        // 整体亮度可以稍微开高点了
uniform float activity_speed : hint_range(0.0, 10.0) = 3.0;

// --- 【关键】独立亮度修正 ---
// 这个参数专门用来压制那个“长条”的亮度。
// 0.3 表示它只有普通灯光 30% 的亮度。调小它，长条就暗；调大它，长条就亮。
uniform float stream_brightness_ratio : hint_range(0.0, 1.0) = 0.3; 

// --- 颜色调色板 (冷色系) ---
uniform vec3 light_primary : source_color = vec3(0.0, 0.6, 0.9);   // 深青
uniform vec3 light_secondary : source_color = vec3(0.0, 0.7, 0.3); // 深绿
uniform vec3 light_alert : source_color = vec3(0.8, 0.1, 0.1);     // 暗红

// --- 密度与形态 (已降低) ---
// 原来是 40.0, 40.0 -> 现在改为 15, 25。格子变大，数量变少。
uniform vec2 tile_factor = vec2(15.0, 25.0); 
// 原来是 0.3 -> 现在 0.2。意味着 80% 的地方是黑的，更稀疏。
uniform float light_density : hint_range(0.0, 1.0) = 0.2; 

// --- 随机函数 ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    vec2 grid_uv = UV * tile_factor;
    vec2 cell_id = floor(grid_uv);
    vec2 cell_uv = fract(grid_uv);
    
    float rnd_base = random(cell_id);
    
    // ============================
    // 1. 机柜指示灯 (小灯)
    // ============================
    float width = 0.5 + 0.3 * random(cell_id + 1.0); 
    float height = 0.1; // 稍微加厚一点点(0.08->0.1)，防止降低密度后看不见
    vec2 start = vec2((1.0 - width) / 2.0, (1.0 - height) / 2.0); 
    
    float light_shape = 
        step(start.x, cell_uv.x) * step(cell_uv.x, start.x + width) *
        step(start.y, cell_uv.y) * step(cell_uv.y, start.y + height);

    // 颜色
    vec3 final_color;
    float col_rnd = random(cell_id + 5.0);
    if (col_rnd < 0.6) final_color = light_primary;
    else if (col_rnd < 0.9) final_color = light_secondary;
    else final_color = light_alert;

    // 闪烁
    float flicker = 0.5 + 0.5 * sin(TIME * activity_speed + rnd_base * 40.0);
    
    // 稀疏逻辑
    float is_lit = step(1.0 - light_density, rnd_base);
    is_lit *= step(0.3, random(vec2(0.0, cell_id.y))); // 随机空置层

    // ============================
    // 2. 数据流长条 (The Stream) - 已削弱
    // ============================
    float stream_col_id = floor(UV.x * 4.0); // 降低流线条数，原来是6，现在4
    float is_stream_col = step(0.85, random(vec2(stream_col_id, 88.0))); 
    
    float flow = step(0.6, fract(UV.y * 2.0 + TIME * 0.3)); 
    // 让长条变细一点，两边留出空隙
    float stream_width_mask = step(0.35, fract(UV.x * 4.0)) * step(fract(UV.x * 4.0), 0.65);
    float stream_mask = is_stream_col * flow * stream_width_mask;
    
    // 颜色 (这里不乘强度，强度留给最后合成)
    vec3 stream_color = light_primary; 

    // ============================
    // 3. 最终合成
    // ============================
    vec3 final_emission = vec3(0.0);
    
    if (stream_mask > 0.5) {
        // 【核心修改】这里乘以了 stream_brightness_ratio
        // 这样长条的亮度就被单独压下去了，不会抢风头
        final_emission = stream_color * emission_strength * stream_brightness_ratio;
    } else {
        // 普通灯光保持原有力度的 emission_strength
        final_emission = final_color * emission_strength * light_shape * is_lit * flicker;
    }
    
    // 墙面网格细节
    float grid_line = step(0.98, fract(UV.y * tile_factor.y));
    ALBEDO = building_color + vec3(grid_line * 0.02);
    EMISSION = final_emission;
}