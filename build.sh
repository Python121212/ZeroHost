#!/bin/bash
# ---------------------------------------------------------------------
# ZeroHost Game Asset Fetcher & Builder (`build.sh`)
# ---------------------------------------------------------------------
set -e

echo "=================================================="
echo " ZeroHost: Game Asset Build Pipeline Started"
echo "=================================================="

# [Step 1] Dockerイメージのビルド（OS基盤の作成）
echo "[1/4] Building Custom Tiny Core Linux Image..."
docker build -t zerohost-base .

# [Step 2] SteamCMDを用いてゲームアセットをダウンロード
# ※ 本来はビルド時に環境変数や引数からSteamの認証情報を安全に渡します
echo "[2/4] Initializing SteamCMD and Fetching 'Escape the Backrooms'..."
mkdir -p ./game_files

# Codespaces上の隔離コンテナ内でSteamCMDを動かし、最新アセットを固定取得
docker run --rm -v $(pwd)/game_files:/data cm2network/steamcmd \
    +force_install_dir /data \
    +login anonymous \
    +app_update 1989270 validate \
    +quit

# [Step 3] ダウンロードしたゲームデータを高速・軽量なSquashFSに圧縮
# (これにより26GBのデータをブラウザが読み込める限界まで軽量化します)
echo "[3/4] Compressing Game Assets into Ultra-light SquashFS module..."
mkdir -p ./dist
rm -f ./dist/game_data.tcz

# 50の技術スタック（メモリ・FSR最適化）が直撃するフォルダ構造のままパッケージ化
mksquashfs ./game_files ./dist/game_data.tcz -comp zstd -Xcompression-level 3

# [Step 4] Docker内から最新のOSイメージ群をdistに抽出・統合
echo "[4/4] Merging OS Kernels and Frontend Assets..."
docker run --rm -v $(pwd)/dist:/output zerohost-base cp /zerohost/core_zerohost.gz /output/

echo "=================================================="
echo " ZeroHost Base Build Complete!"
echo " All artifacts generated in './dist/' folder."
echo " Ready for Cloudflare Pages Deployment."
echo "=================================================="
