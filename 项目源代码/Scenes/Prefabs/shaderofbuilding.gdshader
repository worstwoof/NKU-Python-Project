shader_type spatial;

// --- 基础控制 ---
uniform vec3 building_color : source_color = vec3(0.01, 0.01, 0.03);
// [修改] 窗户亮度从 4.0 降至 2.5
uniform float emission_strength : hint_range(0.0, 10.0) = 2.5;

// --- 独立亮度控制 ---
// [修改] 霓虹灯条从 8.0 降至 5.0 (依然比窗户亮，但不再刺眼)
uniform float neon_strip_strength : hint_range(0.0, 20.0) = 5.0;
// [修改] 广告牌从 2.0 降至 1.2 (屏幕应该看清内容，而不是发光)
uniform float billboard_strength : hint_range(0.0, 10.0) = 1.2;

// --- 颜色调色板 ---
uniform vec3 window_color_hot : source_color = vec3(1.0, 0.2, 0.5);
uniform vec3 window_color_cool : source_color = vec3(0.0, 0.8, 1.0);
uniform vec3 window_color_rare : source_color = vec3(1.0, 0.9, 0.1);
uniform vec3 billboard_color  : source_color = vec3(0.0, 1.0, 0.8);

// --- 密度设置 ---
uniform vec2 tile_factor = vec2(10.0, 40.0);
uniform float window_density : hint_range(0.0, 1.0) = 0.35;
uniform float billboard_density : hint_range(0.0, 1.0) = 0.15;

// --- 随机函数 ---
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // 1. 基础窗户层
    vec2 grid_uv = UV * tile_factor;
    vec2 cell_id = floor(grid_uv);
    vec2 cell_uv = fract(grid_uv);

    float rnd_base = random(cell_id);
    float rnd_type = random(cell_id + 1.0);
    float rnd_color = random(cell_id + 3.0);

    float width, height;
    if (rnd_type < 0.4) { width = 0.95; height = 0.2; }
    else if (rnd_type < 0.7) { width = 0.2; height = 0.8; }
    else { width = 0.4 + 0.4*random(cell_id+7.0); height = 0.4 + 0.4*random(cell_id+8.0); }

    vec2 start = vec2((1.0-width)/2.0, (1.0-height)/2.0);
    float window_mask =
        smoothstep(start.x, start.x+0.02, cell_uv.x) * smoothstep(start.x+width, start.x+width-0.02, cell_uv.x) *
        smoothstep(start.y, start.y+0.02, cell_uv.y) * smoothstep(start.y+height, start.y+height-0.02, cell_uv.y);

    vec3 win_col = (rnd_color < 0.5) ? window_color_cool : ((rnd_color < 0.85) ? window_color_hot : window_color_rare);
    float is_lit = step(1.0 - window_density, rnd_base);
    is_lit *= step(0.2, random(vec2(cell_id.y, 0.0)));

    // 2. 垂直霓虹灯条
    float strip_id = floor(UV.x * tile_factor.x);
    float is_strip = step(0.95, random(vec2(strip_id, 99.0)));
    float strip_mask = smoothstep(0.4, 0.45, fract(UV.x * tile_factor.x)) * smoothstep(0.6, 0.55, fract(UV.x * tile_factor.x));
    float strip_glitch = step(0.1, random(vec2(strip_id, floor(UV.y * 10.0))));

    // 3. 巨型广告牌
    vec2 bb_grid_factor = vec2(3.0, 8.0);
    vec2 bb_id = floor(UV * bb_grid_factor);
    vec2 bb_uv = fract(UV * bb_grid_factor);
    float is_billboard = step(1.0 - billboard_density, random(bb_id + 55.5));

    // 广告牌细节
    float border = step(0.05, bb_uv.x) * step(bb_uv.x, 0.95) * step(0.05, bb_uv.y) * step(bb_uv.y, 0.95);
    float content_area = step(0.1, bb_uv.x) * step(bb_uv.x, 0.9) * step(0.15, bb_uv.y) * step(bb_uv.y, 0.85);
    float frame_mask = border - content_area;

    // 像素内容
    vec2 data_grid = floor(bb_uv * vec2(10.0, 5.0));
    float data_dots = step(0.5, random(data_grid + bb_id));
    data_dots *= step(0.3, random(vec2(0.0, data_grid.y)));

    // [修改] 扫描线变得更明显一点，压暗整体
    float scanline = 0.7 + 0.3 * sin(UV.y * 600.0);

    // [修改] 内部内容亮度进一步压低到 0.5，形成更好的对比度
    float inner_content = content_area * data_dots * 0.5;
    float billboard_pattern = (frame_mask + inner_content) * scanline;

    // 4. 最终合成
    vec3 final_emission = vec3(0.0);

    vec3 color_win = win_col * emission_strength * window_mask * is_lit;
    vec3 color_strip = vec3(0.6, 0.0, 1.0) * neon_strip_strength * strip_mask * is_strip * strip_glitch;
    vec3 color_bb = billboard_color * billboard_strength * billboard_pattern;

    if (is_billboard > 0.5) {
        final_emission = color_bb;
    } else {
        if (length(color_strip) > 0.1) {
            final_emission = color_strip;
        } else {
            final_emission = color_win;
        }
    }

    float tech_line = step(0.98, fract(UV.x * 20.0)) + step(0.98, fract(UV.y * 50.0));
    ALBEDO = building_color + vec3(tech_line * 0.05);
    EMISSION = final_emission;
}