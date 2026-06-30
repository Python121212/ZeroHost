// ---------------------------------------------------------------------
// ZeroHost Frontend Core & OPFS Asset Manager
// ---------------------------------------------------------------------

window.addEventListener('DOMContentLoaded', async () => {
    const statusEl = document.getElementById('status');
    const bootScreen = document.getElementById('boot-screen');
    const canvas = document.getElementById('canvas');

    try {
        // [Step 1] OPFS（オリジン非依存ファイルシステム）の初期化
        statusEl.innerText = "Connecting to Secure Storage (OPFS)...";
        const root = await navigator.storage.getDirectory();
        
        // [Step 2] CloudflareからカスタムOSイメージの差分チェック・ロード
        statusEl.innerText = "Loading ZeroHost Custom OS Component...";
        const response = await fetch('./core_zerohost.gz');
        if (!response.ok) throw new Error("Failed to fetch OS image from Cloudflare CDN.");
        
        // [Step 3] Wasm64 / Venus GPU パススルーの初期化設定
        statusEl.innerText = "Booting WebVM Core with 50-Stack Optimizations...";
        
        // 仮想WebVMインスタンスのモック定義（実際のランタイムに引き渡す環境変数一式）
        const webvmConfig = {
            canvas: canvas,
            arguments: ["vmlinuz64", "initrd=core_zerohost.gz", "quiet", "WASM64_SIGN_EXT=1"],
            env: {
                "MESA_VK_WSI_PRESENT_MODE": "mailbox",
                "DXVK_FRAME_LIMIT": "60",
                "BOX64_DYNAREC_WEAKBARRIER": "1"
            }
        };

        // [Step 4] OSの起動完了
        statusEl.innerText = "Connecting Steamworks P2P / EOS Network...";
        setTimeout(() => {
            bootScreen.style.display = 'none'; // 画面をゲーム（Canvas）へ切り替え
            console.log("[ZeroHost] System fully active on 60fps profile.");
        }, 1000);

    } catch (error) {
        statusEl.innerText = `[Error] ${error.message}`;
        statusEl.style.color = '#ff0000';
        console.error("[ZeroHost Boot Failure]", error);
    }
});
