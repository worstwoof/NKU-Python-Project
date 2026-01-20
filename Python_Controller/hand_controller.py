import cv2
import mediapipe as mp
import socket
import tkinter as tk
# --- 核心配置 ---
UDP_IP = "127.0.0.1"
UDP_PORT = 4242
camera_id = 0

# 灵敏度设置
JUMP_MOVE_THRESHOLD = 0.03

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1, min_detection_confidence=0.7)
mp_draw = mp.solutions.drawing_utils
cap = cv2.VideoCapture(camera_id)

print("赛博义眼 v3.0 (握拳=攻击 / 张手向上=跳跃)")

window_name = 'Cyber Controller V3'
window_width = 320  # 定义窗口宽度
window_height = 240 # 定义窗口高度

# 1. 获取屏幕分辨率
try:
    root = tk.Tk()
    screen_width = root.winfo_screenwidth()
    screen_height = root.winfo_screenheight()
    root.destroy() # 获取完就销毁隐藏窗口
except:
    # 如果获取失败，默认按 1920x1080 算
    screen_width = 1920
    screen_height = 1080

# 2. 计算右下角坐标
# 减去窗口大小，再多减去 50 像素（为了避开 Windows底部的任务栏）
x_pos = screen_width - window_width
y_pos = screen_height - window_height - 50 

# 3. 创建并移动窗口
cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
cv2.resizeWindow(window_name, window_width, window_height)
cv2.moveWindow(window_name, x_pos, y_pos)

# 4. 置顶
try:
    cv2.setWindowProperty(window_name, cv2.WND_PROP_TOPMOST, 1)
except:
    pass

# 状态记录
prev_y = 0
prev_state = "OPEN"

def get_hand_state(landmarks):
    fingers_folded = 0
    tips = [8, 12, 16, 20]
    pips = [6, 10, 14, 18]
    for i in range(4):
        if landmarks[tips[i]].y > landmarks[pips[i]].y:
            fingers_folded += 1
    if fingers_folded >= 3:
        return "FIST"
    else:
        return "OPEN"

while cap.isOpened():
    success, image = cap.read()
    if not success: 
        # [修改] 读不到帧时等待一下，防止死循环卡死
        cv2.waitKey(10)
        continue

    image = cv2.flip(image, 1)
    img_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(img_rgb)
    
    move_cmd = "CENTER"
    action_cmd = "NO"

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_draw.draw_landmarks(image, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            
            curr_x = hand_landmarks.landmark[9].x
            curr_y = hand_landmarks.landmark[9].y
            curr_state = get_hand_state(hand_landmarks.landmark)
            
            # --- 左右移动 ---
            if curr_x < 0.35: move_cmd = "LEFT"
            elif curr_x > 0.65: move_cmd = "RIGHT"
            else: move_cmd = "CENTER"

            # --- 动作 ---
            dy = curr_y - prev_y 
            
            if curr_state == "OPEN" and dy < -JUMP_MOVE_THRESHOLD:
                action_cmd = "JUMP"
                cv2.putText(image, "JUMP", (50, 150), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 255, 0), 3)
            
            elif curr_state == "FIST" and prev_state == "OPEN":
                action_cmd = "PUNCH"
                cv2.putText(image, "PUNCH", (50, 150), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 255), 3)

            prev_y = curr_y
            prev_state = curr_state

    # 发送数据
    msg = f"{move_cmd},{action_cmd}"
    sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))

    # [修改] 使用统一的变量名 window_name
    cv2.imshow(window_name, image)
    
    # [修改] 改为 waitKey(1) 保证每帧都刷新UI，避免灰屏
    if cv2.waitKey(1) & 0xFF == ord('q'): break

cap.release()
cv2.destroyAllWindows()