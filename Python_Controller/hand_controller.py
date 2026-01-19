import cv2
import mediapipe as mp
import socket

# --- 核心配置 ---
UDP_IP = "127.0.0.1"
UDP_PORT = 4242
camera_id = 0

# 灵敏度设置
JUMP_MOVE_THRESHOLD = 0.03  # 向上移动多少算跳跃 (越小越灵敏)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1, min_detection_confidence=0.7)
mp_draw = mp.solutions.drawing_utils
cap = cv2.VideoCapture(camera_id)

print("赛博义眼 v3.0 (握拳=攻击 / 张手向上=跳跃)")

# 状态记录
prev_y = 0
prev_state = "OPEN" # 记录上一帧的手势状态

def get_hand_state(landmarks):
    # 判断手指折叠状态
    # 比较指尖(TIP)和指关节(PIP)的Y坐标 (注意：画面上方Y是0，下方是1)
    # 如果 指尖Y > 关节Y，说明手指是折叠的
    
    fingers_folded = 0
    tips = [8, 12, 16, 20] # 食指、中指、无名指、小指
    pips = [6, 10, 14, 18]
    
    for i in range(4):
        if landmarks[tips[i]].y > landmarks[pips[i]].y:
            fingers_folded += 1
            
    # 大拇指单独判断 (比较X坐标，取决于左右手，这里简化处理，只看其他4指)
    
    if fingers_folded >= 3:
        return "FIST"
    else:
        return "OPEN"

while cap.isOpened():
    success, image = cap.read()
    if not success: continue

    image = cv2.flip(image, 1)
    img_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(img_rgb)
    
    move_cmd = "CENTER"
    action_cmd = "NO"

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_draw.draw_landmarks(image, hand_landmarks, mp_hands.HAND_CONNECTIONS)
            
            # 1. 获取坐标
            curr_x = hand_landmarks.landmark[9].x
            curr_y = hand_landmarks.landmark[9].y
            
            # 2. 获取当前手势状态 (FIST 或 OPEN)
            curr_state = get_hand_state(hand_landmarks.landmark)
            
            # --- 左右移动逻辑 ---
            if curr_x < 0.35: move_cmd = "LEFT"
            elif curr_x > 0.65: move_cmd = "RIGHT"
            else: move_cmd = "CENTER"

            # --- 动作逻辑 ---
            
            # 计算垂直位移 (负数代表向上)
            dy = curr_y - prev_y 
            
            # [逻辑 A] 跳跃：手必须是张开的 + 向上移动
            if curr_state == "OPEN" and dy < -JUMP_MOVE_THRESHOLD:
                action_cmd = "JUMP"
                cv2.putText(image, "JUMP (OPEN UP)", (50, 200), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 255, 0), 3)
            
            # [逻辑 B] 破墙/攻击：检测 "抓取" 动作 (从张开变握拳的瞬间)
            # 这相当于按了一次键
            elif curr_state == "FIST" and prev_state == "OPEN":
                action_cmd = "PUNCH"
                cv2.putText(image, "PUNCH (GRAB)", (50, 200), cv2.FONT_HERSHEY_SIMPLEX, 1.5, (0, 0, 255), 3)

            # 更新记录
            prev_y = curr_y
            prev_state = curr_state

    # 发送数据
    msg = f"{move_cmd},{action_cmd}"
    sock.sendto(msg.encode(), (UDP_IP, UDP_PORT))

    cv2.imshow('Cyber Controller V3', image)
    if cv2.waitKey(5) & 0xFF == ord('q'): break

cap.release()
cv2.destroyAllWindows()