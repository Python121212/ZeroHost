#!/bin/bash
set -e

echo "=================================================="
echo " ZeroHost: System Build Pipeline Started"
echo "=================================================="

# [Step 1] Dockerイメージのビルド（カスタムLinuxのベース作成）
echo "[1/2] Building Custom Tiny Core Linux Image..."
docker build -t zerohost-base .

# [Step 2] 出力フォルダの準備
mkdir -p ./dist

# [Step 3] OSイメージ群をdistに抽出・統合
echo "[2/2] Merging OS Kernels and Frontend Assets..."
docker run --rm -v $(pwd)/dist:/output zerohost-base cp /zerohost/core_zerohost.gz /output/

echo "=================================================="
echo " ZeroHost Base Build Complete!"
echo " All artifacts generated in './dist/' folder."
echo "=================================================="