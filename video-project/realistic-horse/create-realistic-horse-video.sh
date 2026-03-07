#!/bin/bash
# 根据参考照片生成写实风格骏马绘画视频

OUTPUT_DIR="/home/ubuntu/.openclaw/workspace/video-project/realistic-horse/frames"
mkdir -p "$OUTPUT_DIR"

# 颜色定义（根据参考图片）
BODY_LIGHT="#A0522D"      # 身体亮部
BODY_MAIN="#8B4513"       # 身体主色
BODY_DARK="#654321"       # 身体暗部
MANE_DARK="#2F1B0C"       # 鬃毛深色
HOOF_DARK="#1a1a1a"       # 马蹄深色
MOUTH_LIGHT="#c9a88c"     # 嘴部浅色

echo "🎨 生成 90 帧写实风格骏马绘画动画..."

for i in $(seq 1 90); do
    frame_num=$(printf "%03d" $i)
    
    # 计算进度
    progress=$((i * 100 / 90))
    
    # 计算各部分显示时机（更平滑的过渡）
    show_bg=$((i >= 1 ? 1 : 0))
    show_body_outline=$((i >= 5 ? 1 : 0))
    show_body_fill=$((i >= 10 ? 1 : 0))
    show_neck=$((i >= 20 ? 1 : 0))
    show_head=$((i >= 30 ? 1 : 0))
    show_ears=$((i >= 38 ? 1 : 0))
    show_muzzle=$((i >= 42 ? 1 : 0))
    show_eyes=$((i >= 48 ? 1 : 0))
    show_mane=$((i >= 55 ? 1 : 0))
    show_chest=$((i >= 60 ? 1 : 0))
    show_front_legs=$((i >= 65 ? 1 : 0))
    show_back_legs=$((i >= 72 ? 1 : 0))
    show_hooves=$((i >= 78 ? 1 : 0))
    show_tail=$((i >= 82 ? 1 : 0))
    show_details=$((i >= 85 ? 1 : 0))
    show_complete=$((i >= 88 ? 1 : 0))
    
    # 确定当前步骤文字
    if [ $i -le 4 ]; then
        step_text="准备画布..."
        step_color="#999999"
    elif [ $i -le 9 ]; then
        step_text="步骤 1: 勾勒身体轮廓"
        step_color="#4A90E2"
    elif [ $i -le 19 ]; then
        step_text="步骤 2: 填充身体底色"
        step_color="#E24A4A"
    elif [ $i -le 29 ]; then
        step_text="步骤 3: 绘制脖子"
        step_color="#50C878"
    elif [ $i -le 37 ]; then
        step_text="步骤 4: 绘制头部"
        step_color="#FFD700"
    elif [ $i -le 41 ]; then
        step_text="步骤 5: 绘制耳朵"
        step_color="#FF6B6B"
    elif [ $i -le 47 ]; then
        step_text="步骤 6: 绘制嘴鼻"
        step_color="#4ECDC4"
    elif [ $i -le 54 ]; then
        step_text="步骤 7: 绘制眼睛"
        step_color="#45B7D1"
    elif [ $i -le 59 ]; then
        step_text="步骤 8: 绘制鬃毛"
        step_color="#96CEB4"
    elif [ $i -le 64 ]; then
        step_text="步骤 9: 绘制胸部"
        step_color="#FFEAA7"
    elif [ $i -le 71 ]; then
        step_text="步骤 10: 绘制前腿"
        step_color="#DDA0DD"
    elif [ $i -le 77 ]; then
        step_text="步骤 11: 绘制后腿"
        step_color="#98D8C8"
    elif [ $i -le 81 ]; then
        step_text="步骤 12: 绘制马蹄"
        step_color="#F7DC6F"
    elif [ $i -le 84 ]; then
        step_text="步骤 13: 绘制尾巴"
        step_color="#BB8FCE"
    elif [ $i -le 87 ]; then
        step_text="步骤 14: 添加细节"
        step_color="#85C1E9"
    else
        step_text="✨ 完成！写实骏马 ✨"
        step_color="#FFD700"
    fi
    
    # 计算渐变透明度
    body_opacity=0
    if [ $i -ge 10 ] && [ $i -lt 20 ]; then
        body_opacity=$(( (i - 10) * 10 ))
    elif [ $i -ge 20 ]; then
        body_opacity=100
    fi
    
    cat > "$OUTPUT_DIR/frame_${frame_num}.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 1080" width="1920" height="1080">
  <defs>
    <!-- 身体渐变 -->
    <linearGradient id="bodyGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#A0522D;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#8B4513;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#654321;stop-opacity:1" />
    </linearGradient>
    
    <!-- 肌肉高光渐变 -->
    <radialGradient id="muscleHighlight" cx="50%" cy="50%" r="50%">
      <stop offset="0%" style="stop-color:#D2691E;stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:#8B4513;stop-opacity:0" />
    </radialGradient>
    
    <!-- 鬃毛渐变 -->
    <linearGradient id="maneGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#4A2511;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2F1B0C;stop-opacity:1" />
    </linearGradient>
    
    <!-- 背景渐变 -->
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#f5f5f5;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#e8e8e8;stop-opacity:1" />
    </linearGradient>
    
    <!-- 阴影滤镜 -->
    <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="3"/>
      <feOffset dx="2" dy="2" result="offsetblur"/>
      <feComponentTransfer>
        <feFuncA type="linear" slope="0.3"/>
      </feComponentTransfer>
      <feMerge>
        <feMergeNode/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  
  <!-- 背景 -->
  <rect width="1920" height="1080" fill="url(#bgGradient)" opacity="${show_bg}"/>
  
  <!-- 地面阴影 -->
  <ellipse cx="960" cy="850" rx="400" ry="40" fill="#000000" opacity="0">
    <animate attributeName="opacity" from="0" to="0.2" dur="2s" begin="$((5 + ${show_body_fill} * 10))s" fill="freeze"/>
  </ellipse>
  
  <!-- 标题 -->
  <text x="960" y="60" font-family="Arial, Microsoft YaHei" font-size="36" font-weight="bold" fill="#2F4F4F" text-anchor="middle">🎨 绘画过程：写实骏马</text>
  
  <!-- 进度条 -->
  <rect x="460" y="80" width="1000" height="16" fill="#E0E0E0" rx="8"/>
  <rect x="460" y="80" width="$((progress * 10))" height="16" fill="#4CAF50" rx="8"/>
  <text x="960" y="94" font-family="Arial" font-size="14" fill="#666" text-anchor="middle">${progress}%</text>
  
  <!-- 步骤提示 -->
  <text x="960" y="120" font-family="Arial, Microsoft YaHei" font-size="20" fill="${step_color}" text-anchor="middle" font-weight="bold">${step_text}</text>
  
  <!-- 骏马绘制区域 (居中缩放) -->
  <g transform="translate(360, 180) scale(1.1)">
EOF

    # 步骤 1: 身体轮廓
    if [ $show_body_outline -eq 1 ]; then
        opacity=$((i >= 5 && i < 10 ? (i - 5) * 20 : 100))
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 身体轮廓 -->
    <path d="M 280 420 
             Q 250 400 240 350 
             Q 230 280 280 240 
             Q 320 210 400 200 
             Q 500 190 580 200 
             Q 650 210 680 230 
             Q 700 240 700 260 
             Q 700 300 680 350 
             Q 660 400 640 420 
             Q 620 450 600 550 
             Q 590 600 580 620 
             Q 570 640 550 640 
             Q 530 640 520 620 
             Q 510 600 500 550 
             Q 490 500 480 480 
             Q 470 470 450 470 
             Q 430 470 420 480 
             Q 410 500 400 550 
             Q 390 600 380 620 
             Q 370 640 350 640 
             Q 330 640 320 620 
             Q 310 600 300 550 
             Q 290 480 280 420 Z" 
          fill="none" stroke="#8B4513" stroke-width="3" stroke-dasharray="5,5" opacity="0.6"/>
EOF
    fi
    
    # 步骤 2: 身体填充
    if [ $show_body_fill -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 身体主体 -->
    <path d="M 280 420 
             Q 250 400 240 350 
             Q 230 280 280 240 
             Q 320 210 400 200 
             Q 500 190 580 200 
             Q 650 210 680 230 
             Q 700 240 700 260 
             Q 700 300 680 350 
             Q 660 400 640 420 
             Q 620 450 600 550 
             Q 590 600 580 620 
             Q 570 640 550 640 
             Q 530 640 520 620 
             Q 510 600 500 550 
             Q 490 500 480 480 
             Q 470 470 450 470 
             Q 430 470 420 480 
             Q 410 500 400 550 
             Q 390 600 380 620 
             Q 370 640 350 640 
             Q 330 640 320 620 
             Q 310 600 300 550 
             Q 290 480 280 420 Z" 
          fill="url(#bodyGradient)" stroke="#654321" stroke-width="2"/>
    
    <!-- 肌肉高光 -->
    <ellipse cx="420" cy="320" rx="80" ry="50" fill="url(#muscleHighlight)" opacity="0.4"/>
    <ellipse cx="520" cy="300" rx="60" ry="40" fill="url(#muscleHighlight)" opacity="0.3"/>
EOF
    fi
    
    # 步骤 3: 脖子
    if [ $show_neck -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 脖子 -->
    <path d="M 580 200 
             Q 620 180 650 160 
             Q 680 140 700 130 
             Q 720 120 740 120 
             Q 750 120 750 130 
             Q 750 150 740 180 
             Q 730 220 710 260 
             Q 700 280 680 300 
             Q 660 320 640 330 
             Q 620 340 600 340 
             Q 580 340 570 330 
             Q 560 320 560 300 
             Q 560 280 570 260 
             Q 580 240 580 220 
             Q 580 210 580 200 Z" 
          fill="url(#bodyGradient)" stroke="#654321" stroke-width="2"/>
EOF
    fi
    
    # 步骤 4: 头部
    if [ $show_head -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 头部 -->
    <ellipse cx="750" cy="130" rx="70" ry="50" fill="url(#bodyGradient)" stroke="#654321" stroke-width="2"/>
    <!-- 额头渐变 -->
    <ellipse cx="740" cy="120" rx="40" ry="30" fill="#A0522D" opacity="0.5"/>
EOF
    fi
    
    # 步骤 5: 耳朵
    if [ $show_ears -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 左耳 -->
    <path d="M 720 90 L 715 60 L 730 85 Z" fill="#4A2511" stroke="#2F1B0C" stroke-width="1"/>
    <!-- 右耳 -->
    <path d="M 760 90 L 765 60 L 750 85 Z" fill="#4A2511" stroke="#2F1B0C" stroke-width="1"/>
    <!-- 耳朵内部 -->
    <path d="M 722 85 L 718 65 L 728 83 Z" fill="#8B7355" opacity="0.6"/>
    <path d="M 758 85 L 762 65 L 752 83 Z" fill="#8B7355" opacity="0.6"/>
EOF
    fi
    
    # 步骤 6: 嘴鼻
    if [ $show_muzzle -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 嘴鼻部 -->
    <ellipse cx="790" cy="140" rx="35" ry="25" fill="#c9a88c" stroke="#8B7355" stroke-width="1"/>
    <!-- 鼻孔 -->
    <ellipse cx="800" cy="135" rx="5" ry="8" fill="#1a1a1a" opacity="0.8"/>
    <ellipse cx="810" cy="140" rx="5" ry="8" fill="#1a1a1a" opacity="0.8"/>
    <!-- 嘴巴线条 -->
    <path d="M 785 150 Q 795 155 805 150" fill="none" stroke="#654321" stroke-width="2"/>
EOF
    fi
    
    # 步骤 7: 眼睛
    if [ $show_eyes -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 眼睛 -->
    <ellipse cx="760" cy="115" rx="12" ry="10" fill="#1a1a1a"/>
    <ellipse cx="762" cy="113" rx="5" ry="4" fill="#FFFFFF"/>
    <ellipse cx="758" cy="118" rx="3" ry="2" fill="#4A2511" opacity="0.5"/>
    <!-- 眼睑 -->
    <path d="M 750 108 Q 760 105 770 108" fill="none" stroke="#4A2511" stroke-width="2"/>
    <!-- 睫毛 -->
    <line x1="765" y1="106" x2="768" y2="102" stroke="#1a1a1a" stroke-width="1"/>
    <line x1="770" y1="108" x2="774" y2="105" stroke="#1a1a1a" stroke-width="1"/>
EOF
    fi
    
    # 步骤 8: 鬃毛
    if [ $show_mane -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 鬃毛 -->
    <path d="M 700 130 Q 680 150 670 180 Q 660 210 660 240" fill="none" stroke="url(#maneGradient)" stroke-width="15" stroke-linecap="round"/>
    <path d="M 690 140 Q 670 160 660 190 Q 650 220 650 250" fill="none" stroke="url(#maneGradient)" stroke-width="12" stroke-linecap="round"/>
    <path d="M 680 150 Q 660 170 650 200 Q 640 230 640 260" fill="none" stroke="url(#maneGradient)" stroke-width="10" stroke-linecap="round"/>
    <path d="M 670 160 Q 650 180 640 210 Q 630 240 630 270" fill="none" stroke="url(#maneGradient)" stroke-width="8" stroke-linecap="round"/>
EOF
    fi
    
    # 步骤 9: 胸部
    if [ $show_chest -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 胸部肌肉 -->
    <path d="M 600 350 Q 620 380 630 420 Q 640 460 640 500" fill="none" stroke="#654321" stroke-width="2" opacity="0.5"/>
    <ellipse cx="620" cy="400" rx="40" ry="60" fill="url(#muscleHighlight)" opacity="0.2"/>
EOF
    fi
    
    # 步骤 10: 前腿
    if [ $show_front_legs -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 左前腿 -->
    <path d="M 580 450 
             Q 575 500 570 550 
             Q 565 600 560 640 
             Q 555 680 550 700" 
          fill="none" stroke="url(#bodyGradient)" stroke-width="25" stroke-linecap="round"/>
    
    <!-- 右前腿 -->
    <path d="M 620 450 
             Q 625 500 630 550 
             Q 635 600 640 640 
             Q 645 680 650 700" 
          fill="none" stroke="url(#bodyGradient)" stroke-width="25" stroke-linecap="round"/>
    
    <!-- 腿部肌肉线条 -->
    <path d="M 575 500 Q 580 550 575 600" fill="none" stroke="#654321" stroke-width="2" opacity="0.4"/>
    <path d="M 625 500 Q 620 550 625 600" fill="none" stroke="#654321" stroke-width="2" opacity="0.4"/>
EOF
    fi
    
    # 步骤 11: 后腿
    if [ $show_back_legs -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 左后腿 -->
    <path d="M 380 450 
             Q 360 500 340 550 
             Q 320 600 310 650 
             Q 300 680 295 700" 
          fill="none" stroke="url(#bodyGradient)" stroke-width="25" stroke-linecap="round"/>
    
    <!-- 右后腿 -->
    <path d="M 420 450 
             Q 440 500 460 550 
             Q 480 600 490 650 
             Q 500 680 505 700" 
          fill="none" stroke="url(#bodyGradient)" stroke-width="25" stroke-linecap="round"/>
    
    <!-- 后腿肌肉线条 -->
    <path d="M 370 480 Q 350 530 330 580" fill="none" stroke="#654321" stroke-width="2" opacity="0.4"/>
    <path d="M 430 480 Q 450 530 470 580" fill="none" stroke="#654321" stroke-width="2" opacity="0.4"/>
EOF
    fi
    
    # 步骤 12: 马蹄
    if [ $show_hooves -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 左前蹄 -->
    <path d="M 545 700 L 555 700 L 560 720 L 540 720 Z" fill="#1a1a1a"/>
    <!-- 右前蹄 -->
    <path d="M 645 700 L 655 700 L 660 720 L 640 720 Z" fill="#1a1a1a"/>
    <!-- 左后蹄 -->
    <path d="M 290 700 L 300 700 L 305 720 L 285 720 Z" fill="#1a1a1a"/>
    <!-- 右后蹄 -->
    <path d="M 500 700 L 510 700 L 515 720 L 495 720 Z" fill="#1a1a1a"/>
EOF
    fi
    
    # 步骤 13: 尾巴
    if [ $show_tail -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 尾巴 -->
    <path d="M 260 380 
             Q 240 420 230 480 
             Q 220 540 215 600 
             Q 210 660 210 700" 
          fill="none" stroke="url(#maneGradient)" stroke-width="20" stroke-linecap="round"/>
    <!-- 尾毛细节 -->
    <path d="M 220 500 Q 210 550 205 600" fill="none" stroke="#4A2511" stroke-width="8" stroke-linecap="round"/>
    <path d="M 215 550 Q 205 600 200 650" fill="none" stroke="#4A2511" stroke-width="6" stroke-linecap="round"/>
    <path d="M 210 600 Q 200 650 195 700" fill="none" stroke="#4A2511" stroke-width="5" stroke-linecap="round"/>
EOF
    fi
    
    # 步骤 14: 细节
    if [ $show_details -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 肌肉细节线条 -->
    <path d="M 400 300 Q 450 320 500 300" fill="none" stroke="#654321" stroke-width="1" opacity="0.3"/>
    <path d="M 380 350 Q 430 370 480 350" fill="none" stroke="#654321" stroke-width="1" opacity="0.3"/>
    
    <!-- 身体高光 -->
    <ellipse cx="450" cy="280" rx="50" ry="30" fill="#D2691E" opacity="0.2"/>
    <ellipse cx="550" cy="270" rx="40" ry="25" fill="#D2691E" opacity="0.15"/>
    
    <!-- 腿部关节细节 -->
    <circle cx="565" cy="620" r="8" fill="#654321" opacity="0.4"/>
    <circle cx="635" cy="620" r="8" fill="#654321" opacity="0.4"/>
    <circle cx="315" cy="620" r="8" fill="#654321" opacity="0.4"/>
    <circle cx="485" cy="620" r="8" fill="#654321" opacity="0.4"/>
EOF
    fi
    
    # 完成效果
    if [ $show_complete -eq 1 ]; then
        cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
    <!-- 完成文字 -->
    <text x="600" y="100" font-family="Arial" font-size="56" font-weight="bold" fill="#FFD700" text-anchor="middle" stroke="#2F4F4F" stroke-width="3">✨ 完成！✨</text>
    
    <!-- 装饰光晕 -->
    <circle cx="600" cy="80" r="60" fill="none" stroke="#FFD700" stroke-width="2" opacity="0.6">
      <animate attributeName="r" from="50" to="70" dur="1s" repeatCount="indefinite"/>
      <animate attributeName="opacity" from="0.6" to="0.3" dur="1s" repeatCount="indefinite"/>
    </circle>
EOF
    fi
    
    cat >> "$OUTPUT_DIR/frame_${frame_num}.svg" << 'EOF'
  </g>
  
  <!-- 画笔图标 -->
  <g transform="translate(1720, 960)">
    <rect x="0" y="0" width="140" height="90" fill="#FFF8DC" stroke="#8B4513" stroke-width="3" rx="12"/>
    <text x="70" y="60" font-family="Arial" font-size="50" text-anchor="middle">🖌️</text>
  </g>
  
  <!-- 参考图提示 -->
  <text x="100" y="1050" font-family="Arial" font-size="14" fill="#999">参考：写实棕色骏马照片</text>
</svg>
EOF

done

echo "✅ 帧生成完成！转换为 PNG..."

# 将 SVG 转换为 PNG
for i in $(seq 1 90); do
    frame_num=$(printf "%03d" $i)
    rsvg-convert "$OUTPUT_DIR/frame_${frame_num}.svg" -o "$OUTPUT_DIR/frame_${frame_num}.png" -w 1920 -h 1080 2>/dev/null
done

echo "✅ PNG 转换完成！制作视频..."

# 使用 FFmpeg 制作视频 (30fps, 3 秒视频)
ffmpeg -y -framerate 30 -i "$OUTPUT_DIR/frame_%03d.png" -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p "/home/ubuntu/.openclaw/workspace/video-project/realistic-horse/realistic-horse-drawing.mp4" 2>&1 | tail -5

echo ""
echo "=========================================="
echo "✅ 写实骏马绘画视频制作完成！"
echo "=========================================="
echo "文件位置：/home/ubuntu/.openclaw/workspace/video-project/realistic-horse/realistic-horse-drawing.mp4"
ls -lh "/home/ubuntu/.openclaw/workspace/video-project/realistic-horse/realistic-horse-drawing.mp4"
