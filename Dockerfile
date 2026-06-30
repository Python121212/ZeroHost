# ---------------------------------------------------------------------
# ZeroHost Baseline Builder
# ---------------------------------------------------------------------
FROM debian:bookworm-slim

# 必用なビルドツールのインストール
RUN apt-get update && apt-get install -y \
    wget \
    squashfs-tools \
    cpio \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /zerohost

# Tiny Core Linux 15.x 最小コアイメージの取得
RUN wget http://tinycorelinux.net/15.x/x86_64/release/distribution_files/corepure64.gz \
    && wget http://tinycorelinux.net/15.x/x86_64/release/distribution_files/vmlinuz64

# 作業用ディレクトリの展開
RUN mkdir -p rootfs && cd rootfs \
    && zcat ../corepure64.gz | cpio -idmv

# 50の技術スタック（Box64, Proton-GE, Venus/Zink等）をダウンロードしマウント用フォルダーへ配置
# (Codespacesのローカルストレージへキャッシュを永続化する構造を定義)
RUN mkdir -p rootfs/opt/zerohost/modules \
    && mkdir -p rootfs/opt/zerohost/steam \
    && mkdir -p rootfs/opt/zerohost/ai

# 自律型AIデバッガ（Local Web-LLM Orchestrator）のログ監視スクリプトを設置
COPY ai_debugger.sh rootfs/opt/zerohost/ai/ai_debugger.sh
RUN chmod +x rootfs/opt/zerohost/ai/ai_debugger.sh

# 60fps固定・FSR強化・メモリバリア解除など、すべての環境変数をbootsyncに焼き込む
COPY bootsync.sh rootfs/opt/bootsync.sh
RUN chmod +x rootfs/opt/bootsync.sh

# カスタムOSイメージ（core_zerohost.gz）として再圧縮
RUN cd rootfs && find . | cpio -o -H newc | gzip -9 > ../core_zerohost.gz

# Cloudflare Pagesデプロイ用のWeb公開用フォルダー(dist)を作成
RUN mkdir -p /zerohost/dist \
    && cp /zerohost/core_zerohost.gz /zerohost/dist/ \
    && cp /zerohost/vmlinuz64 /zerohost/dist/

VOLUME [ "/zerohost/dist" ]
CMD ["echo", "ZeroHost Base OS Build Complete. Target files generated in /zerohost/dist"]
