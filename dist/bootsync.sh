#!/bin/sh
# ---------------------------------------------------------------------
# ZeroHost 50-Stack Optimization & Environment Variable Injector
# ---------------------------------------------------------------------

# [CPU/Wasmパススルー & メモリ最適化]
export BOX64_DYNAREC_WEAKBARRIER=1
sysctl -w vm.swappiness=80
sysctl -w sys.kernel.panic_on_gpu_error=0

# [60fps固定 & トリプルバッファリング]
export DXVK_FRAME_LIMIT=60
export MESA_VK_WSI_PRESENT_MODE=mailbox

# [GPUブースト & AMD FSR強度最適化]
export force_vulkan_device_type=discrete
export WINE_FULLSCREEN_FSR=1
export WINE_FULLSCREEN_FSR_STRENGTH=5

# [APIリアルタイム翻訳ステートキャッシュの永続化]
export DXVK_STATE_CACHE=1
export DXVK_STATE_CACHE_PATH=/opt/zerohost/steam/cache

# D-Busの自動立ち上げ（Steam欺瞞用）
dbus-daemon --system --fork

# バックグラウンドで自律型AIデバッガを起動
/opt/zerohost/ai/ai_debugger.sh &
