#!/bin/bash
# 生成高清绘画过程视频（60 帧，更流畅）

OUTPUT_DIR="/home/ubuntu/.openclaw/workspace/video-project/hd-frames"
mkdir -p "$OUTPUT_DIR"

# 颜色定义
BODY_COLOR="#8B4513"
MANE_COLOR="#2F1B0C"
GROUND_COLOR="#8B4513"
GRASS_COLOR="#228B22"
SKY_COLOR="#87CEEB"
SUN_COLOR="#FFD700"

# 生成 60 帧绘画过程
echo "生成 60 帧高清绘画动画..."

for i in $(seq 1 60); do
    frame_num=$(printf "%03d" $i)
    
    # 计算当前应该显示的部分
    body_progress=$((i > 5 ? 1 : 0))
    neck_progress=$((i > 10 ? 1 : 0))
    head_progress=$((i > 15 ? 1 : 0))
    face_progress=$((i > 20 ? 1 : 0))
    ears_progress=$((i > 25 ? 1 : 0))
    mane_progress=$((i > 30 ? 1 : 0))
    front_legs_progress=$((i > 35 ? 1 : 0))
    back_legs_progress=$((i > 40 ? 1 : 0))
    hooves_progress=$((i > 45 ? 1 : 0))
    tail_progress=$((i > 50 ? 1 : 0))
    complete_progress=$((i > 55 ? 1 : 0))
    
    # 计算进度百分比
    progress=$((i * 100 / 60))
    
    # 确定当前步骤文字
    if [ $i -le 5 ]; then
        step_text="准备画布..."
        step_color="#FF6347"
    elif [ $i -le 10 ]; then
        step_text="步骤 1: 绘制身体轮廓"
        step_color="#4169E1"
    elif [ $i -le 15 ]; then
        step_text="步骤 2: 绘制脖子"
        step_color="#32CD32"
    elif [ $i -le 20 ]; then
        step_text="步骤 3: 绘制头部"
        step_color="#FFD700"
    elif [ $i -le 25 ]; then
        step_text="步骤 4: 绘制五官"
        step_color="#FF1493"
    elif [ $i -le 30 ]; then
        step_text="步骤 5: 绘制耳朵"
        step_color="#00CED1"
    elif [ $i -le 35 ]; then
        step_text="步骤 6: 绘制鬃毛"
        step_color="#FF4500"
    elif [ $i -le 40 ]; then
        step_text="步骤 7: 绘制前腿"
        step_color="#9370DB"
    elif [ $i -le 45 ]; then
        step_text="步骤 8: 绘制后腿"
        step_color="#FF6347"
    elif [ $i -le 50 ]; then
        step_text="步骤 9: 绘制马蹄"
        step_color="#4169E1"
    elif [ $i -le 55 ]; then
        step_text="步骤 10: 绘制尾巴"
        step_color="#32CD32"
    else
        step_text="✨ 完成！奔跑的骏马 ✨"
        step_color="#FFD700"
    fi
    
    cat > "$OUTPUT_DIR/frame_${frame_num}.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <linearGradient id="skyGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#4A90E2"/>
      <stop offset="100%" style="stop-color:#87CEEB"/>
    </linearGradient>
    <linearGradient id="bodyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#A0522D"/>
      <stop offset="100%" style="stop-color:#8B4513"/>
    </linearGradient>
  </defs>
  
  <!-- 背景 -->
  <rect width="1920" height="1080" fill="url(#skyGrad)"/>
  
  <!-- 太阳 -->
  <circle cx="1600" cy="150" r="80" fill="${SUN_COLOR}"/>
  <g stroke="${SUN_COLOR}" stroke-width="4" opacity="0.6">
    <line x1="1600" y1="50" x2="1600" y2="20"/>
    <line x1="1600" y1="250" x2="1600" y2="280"/>
    <line x1="1500" y1="150" x2="1470" y2="150"/>
    <line x1="1700" y1="150" x2="1730" y2="150"/>
  </g>
  
  <!-- 云朵 -->
  <g fill="#FFFFFF" opacity="0.8">
    <ellipse cx="300" cy="180" rx="120" ry="50"/>
    <ellipse cx="380" cy="200" rx="100" ry="45"/>
    <ellipse cx="800" cy="150" rx="140" ry="60"/>
    <ellipse cx="1200" cy="180" rx="100" ry="45"/>
  </g>
  
  <!-- 地面 -->
  <rect x="0" y="850" width="1920" height="230" fill="${GROUND_COLOR}"/>
  
  <!-- 草地 -->
  <rect x="0" y="820" width="1920" height="60" fill="${GRASS_COLOR}"/>
  
  <!-- 标题 -->
  <text x="960" y="80" font-family="Arial, Microsoft YaHei" font-size="42" font-weight="bold" fill="#2F4F4F" text-anchor="middle">🎨 绘画过程：奔跑的骏马</text>
  
  <!-- 进度条背景 -->
  <rect x="460" y="100" width="1000" height="20" fill="#E0E0E0" rx="10"/>
  <!-- 进度条 -->
  <rect x="460" y="100" width="${progress}*10" height="20" fill="#4CAF50" rx="10"/>
  <text x="960" y="115" font-family="Arial" font-size="16" fill="#333" text-anchor="middle">${progress}%</text>
  
  <!-- 步骤提示 -->
  <text x="960" y="145" font-family="Arial, Microsoft YaHei" font-size="24" fill="${step_color}" text-anchor="middle" font-weight="bold">${step_text}</text>
  
  <!-- 骏马绘制区域 -->
  <g transform="translate(200, 150) scale(1.2)">
EOF

    # 根据进度添加马的不同部分
    if [ $body_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 身体 -->
    <ellipse cx="400" cy="350" rx="120" ry="60" fill="url(#bodyGrad)" stroke="#654321" stroke-width="3"/>
EOF
    fi
    
    if [ $neck_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 脖子 -->
    <path d="M 480 320 Q 520 280 540 240 L 560 250 Q 540 300 500 340 Z" fill="url(#bodyGrad)" stroke="#654321" stroke-width="3"/>
EOF
    fi
    
    if [ $head_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 头部 -->
    <ellipse cx="560" cy="230" rx="50" ry="35" fill="#8B4513" stroke="#654521" stroke-width="3"/>
EOF
    fi
    
    if [ $face_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 马嘴 -->
    <ellipse cx="590" cy="240" rx="25" ry="15" fill="#654321"/>
    <!-- 眼睛 -->
    <circle cx="570" cy="220" r="8" fill="#000000"/>
    <circle cx="572" cy="218" r="3" fill="#FFFFFF"/>
EOF
    fi
    
    if [ $ears_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 耳朵 -->
    <polygon points="540,210 550,180 560,210" fill="#8B4513" stroke="#654321" stroke-width="2"/>
    <polygon points="555,210 565,180 575,210" fill="#8B4513" stroke="#654321" stroke-width="2"/>
EOF
    fi
    
    if [ $mane_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 鬃毛 -->
    <path d="M 520 250 Q 500 220 510 200 Q 530 210 540 240" fill="none" stroke="#2F1B0C" stroke-width="10" stroke-linecap="round"/>
    <path d="M 510 260 Q 490 230 500 210 Q 520 220 530 250" fill="none" stroke="#2F1B0C" stroke-width="10" stroke-linecap="round"/>
    <path d="M 500 270 Q 480 240 490 220 Q 510 230 520 260" fill="none" stroke="#2F1B0C" stroke-width="10" stroke-linecap="round"/>
EOF
    fi
    
    if [ $front_legs_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 前腿 -->
    <path d="M 450 380 L 440 460 L 430 500" fill="none" stroke="#8B4513" stroke-width="14" stroke-linecap="round"/>
    <path d="M 470 380 L 480 470 L 490 510" fill="none" stroke="#8B4513" stroke-width="14" stroke-linecap="round"/>
EOF
    fi
    
    if [ $back_legs_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 后腿 -->
    <path d="M 320 380 L 300 460 L 280 500" fill="none" stroke="#8B4513" stroke-width="14" stroke-linecap="round"/>
    <path d="M 340 380 L 350 470 L 360 510" fill="none" stroke="#8B4513" stroke-width="14" stroke-linecap="round"/>
EOF
    fi
    
    if [ $hooves_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 马蹄 -->
    <ellipse cx="430" cy="505" rx="15" ry="10" fill="#2F1B0C"/>
    <ellipse cx="490" cy="515" rx="15" ry="10" fill="#2F1B0C"/>
    <ellipse cx="280" cy="505" rx="15" ry="10" fill="#2F1B0C"/>
    <ellipse cx="360" cy="515" rx="15" ry="10" fill="#2F1B0C"/>
EOF
    fi
    
    if [ $tail_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 尾巴 -->
    <path d="M 280 360 Q 240 380 220 430 Q 200 410 180 460" fill="none" stroke="#2F1B0C" stroke-width="12" stroke-linecap="round"/>
EOF
    fi
    
    if [ $complete_progress -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 完成效果 -->
    <text x="400" y="200" font-family="Arial" font-size="64" font-weight="bold" fill="#FFD700" text-anchor="middle" stroke="#2F4F4F" stroke-width="3">✨ 完成！✨</text>
    <!-- 速度线 -->
    <g stroke="#FFFFFF" stroke-width="3" opacity="0.6">
      <line x1="100" y1="350" x2="250" y2="350">
        <animate attributeName="x1" from="50" to="300" dur="0.5s" repeatCount="indefinite"/>
        <animate attributeName="x2" from="200" to="450" dur="0.5s" repeatCount="indefinite"/>
      </line>
      <line x1="80" y1="400" x2="230" y2="400">
        <animate attributeName="x1" from="30" to="280" dur="0.7s" repeatCount="indefinite"/>
        <animate attributeName="x2" from="180" to="430" dur="0.7s" repeatCount="indefinite"/>
      </line>
    </g>
    <!-- 尘土 -->
    <circle cx="300" cy="830" r="8" fill="#8B4513" opacity="0.6"/>
    <circle cx="350" cy="840" r="10" fill="#8B4513" opacity="0.6"/>
    <circle cx="400" cy="835" r="7" fill="#8B4513" opacity="0.6"/>
EOF
    fi
    
    cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
  </g>
  
  <!-- 画笔图标 -->
  <g transform="translate(1700, 950)">
    <rect x="0" y="0" width="150" height="100" fill="#FFF8DC" stroke="#8B4513" stroke-width="3" rx="15"/>
    <text x="75" y="65" font-family="Arial" font-size="60" text-anchor="middle">🖌️</text>
  </g>
</svg>
EOF

done

echo "帧生成完成！转换为 PNG..."

# 将 SVG 转换为 PNG
for i in $(seq 1 60); do
    frame_num=$(printf "%03d" $i)
    rsvg-convert "$OUTPUT_DIR/frame_${frame_num}.svg" -o "$OUTPUT_DIR/frame_${frame_num}.png" -w 1920 -h 1080 2>/dev/null
done

echo "PNG 转换完成！制作视频..."

# 使用 FFmpeg 制作视频 (20fps, 3 秒视频)
ffmpeg -y -framerate 20 -i "$OUTPUT_DIR/frame_%03d.png" -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p "/home/ubuntu/.openclaw/workspace/video-project/horse-drawing-hd.mp4" 2>&1 | tail -5

echo ""
echo "=========================================="
echo "✅ 高清视频制作完成！"
echo "=========================================="
echo "文件位置：/home/ubuntu/.openclaw/workspace/video-project/horse-drawing-hd.mp4"
ls -lh /home/ubuntu/.openclaw/workspace/video-project/horse-drawing-hd.mp4
