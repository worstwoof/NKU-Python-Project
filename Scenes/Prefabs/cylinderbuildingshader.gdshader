shader_type spatial;

// --- 基础控制 ---
uniform vec3 building_color : source_color = vec3(0.01, 0.01, 0.02);
// [修改] 亮度适中，保持清晰
uniform float emission_strength : hint_range(0.0, 5.0) = 1.8;        

// --- 纹理缩放 ---
// X 轴建议设为整数 (如 16.0, 24.0) 保证无缝环绕
uniform vec2 grid_scale = vec2(24.0, 12.0); 

// --- 颜色配置 ---
uniform vec3 color_main   : source_color = vec3(0.0, 0.6, 1.0); // 主窗户(蓝)
uniform vec3 color_rack   : source_color = vec3(0.0, 0.9, 0.4); // 服务器点阵(绿)
uniform vec3 color_pipe   : source_color = vec3(1.0, 0.5, 0.0); // 垂直管道(橙)
uniform vec3 rim_color    : source_color = vec3(0.0, 0.4, 0.8); // 边缘光

// --- 密度与细节 ---
uniform float light_density : hint_range(0.0, 1.0) = 0.5; // 发光区域占比
uniform float rim_power : hint_range(0.5, 8.0) = 4.0;
uniform float rim_strength : hint_range(0.0, 5.0) = 0.8;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 绘制矩形的辅助函数
float box(vec2 _uv, vec2 _size, float _smooth) {
    vec2 _uv_centered = _uv * 2.0 - 1.0;
    vec2 field = abs(_uv_centered) - _size;
    return 1.0 - smoothstep(0.0, _smooth, max(field.x, field.y));
}

void fragment() {
    vec2 uv = UV * grid_scale;
    vec2 cell_id = floor(uv);
    vec2 cell_uv = fract(uv);
    
    float rnd_base = random(cell_id);
    float rnd_type = random(cell_id + 1.23);

    // ============================
    // 1. 垂直导管 (Vertical Conduits) - 打破横向结构
    // ============================
    // 随机选中某一列，把它变成贯穿上下的管道
    // floor(uv.x) 获取列 ID
    float col_id = floor(uv.x);
    // 10% 的概率这一列是管道
    float is_pipe_col = step(0.9, random(vec2(col_id, 88.88))); 
    
    // ============================
    // 2. 形状生成逻辑
    // ============================
    float shape = 0.0;
    vec3 shape_color = vec3(0.0);
    
    if (is_pipe_col > 0.5) {
        // --- 逻辑分支 A: 垂直管道 ---
        // 在这一列里，画两条细长的竖线
        float pipe_line = step(0.4, fract(uv.x)) * step(fract(uv.x), 0.6); // 主管道
        
        // 管道上的节点 (每隔几格亮一下)
        float pipe_node = step(0.8, fract(uv.y * 0.5)); 
        
        shape = pipe_line * 0.5 + (pipe_line * pipe_node * 0.5); // 节点处更亮
        shape_color = color_pipe;
        
    } else {
        // --- 逻辑分支 B: 普通网格单元 ---
        
        // 根据随机数决定格子里画什么
        if (rnd_type < 0.4) {
            // 类型 1: 标准大窗户 (Block)
            shape = box(cell_uv, vec2(0.8, 0.4), 0.05);
            shape_color = color_main;
            
        } else if (rnd_type < 0.7) {
            // 类型 2: 数据插槽 (Slots) - 上下两条横杠
            float bar1 = box(cell_uv - vec2(0.0, 0.25), vec2(0.9, 0.1), 0.02);
            float bar2 = box(cell_uv + vec2(0.0, 0.25), vec2(0.9, 0.1), 0.02);
            shape = bar1 + bar2;
            shape_color = color_main;
            
        } else {
            // 类型 3: 服务器点阵 (Server Dots) - 3x3 小点
            vec2 sub_grid = fract(cell_uv * 3.0); // 分割成 3x3 子网格
            float dot = box(sub_grid, vec2(0.4, 0.4), 0.1);
            
            // 随机让某些点熄灭
            float sub_rnd = random(floor(uv * 3.0));
            float dot_lit = step(0.3, sub_rnd);
            
            shape = dot * dot_lit;
            shape_color = color_rack;
        }
        
        // 随机熄灭整格 (空置率)
        float cell_lit = step(1.0 - light_density, rnd_base);
        // 增加行空置 (让楼层感更强)
        cell_lit *= step(0.2, random(vec2(0.0, cell_id.y)));
        
        shape *= cell_lit;
    }

    // ============================
    // 3. 墙面电路暗纹 (Tech Detail)
    // ============================
    // 在不发光的黑色区域，画一点点极暗的线条，增加细节
    float tech_line_x = step(0.95, fract(uv.x * 2.0));
    float tech_line_y = step(0.95, fract(uv.y * 2.0));
    vec3 wall_detail = building_color + vec3(0.02) * (tech_line_x + tech_line_y);

    // ============================
    // 4. 菲涅尔边缘光 (Rim Light)
    // ============================
    float fresnel = pow(1.0 - dot(normalize(NORMAL), normalize(VIEW)), rim_power);
    vec3 rim_emission = rim_color * fresnel * rim_strength;

    // ============================
    // 5. 最终合成
    // ============================
    ALBEDO = wall_detail;
    ROUGHNESS = 0.4;
    METALLIC = 0.7;
    
    // 最终发光 = 形状光 + 边缘光
    EMISSION = shape * shape_color * emission_strength + rim_emission;
}