<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <title>AI Image Generator</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="min-h-screen flex flex-col items-center justify-center p-4 bg-slate-950 text-slate-50">

    <div class="w-full max-w-xl space-y-4">

        <h1 class="text-2xl font-semibold text-center">
            🎨 AI Image Generator
        </h1>

        <!-- PROMPT -->
        <textarea id="prompt"
            class="w-full border border-slate-700 bg-slate-900 rounded-md p-3 text-sm outline-none focus:ring-2 focus:ring-blue-500"
            rows="3" placeholder="Describe your image..."></textarea>

        <!-- STYLE -->
        <div class="flex items-center gap-3">
            <span class="text-sm text-slate-300">Style:</span>

            <select id="style" class="border border-slate-700 bg-slate-900 rounded-md p-2 text-sm">
                <option value="anime">Anime</option>
                <option value="realistic">Realistic</option>
                <option value="3d">3D Render</option>
                <option value="pixel">Pixel Art</option>
            </select>
        </div>

        <!-- BUTTON -->
        <button id="generateBtn" class="w-full py-2 rounded-md font-medium bg-blue-500 hover:bg-blue-600 transition">
            Generate Image
        </button>

        <!-- ERROR -->
        <p id="errorMsg" class="text-red-400 text-sm text-center mt-2 hidden"></p>

        <!-- IMAGE RESULT -->
        <div id="result" class="mt-4 flex flex-col items-center gap-3 hidden">
            <img id="generatedImg" src="" alt="AI Image" class="rounded-lg max-h-[400px]" />

            <div class="flex gap-3">
                <a id="downloadBtn" download="ai-image.png"
                    class="px-4 py-2 text-xs rounded-md bg-slate-800 hover:bg-slate-700 cursor-pointer">
                    Download
                </a>

                <a id="openBtn" target="_blank" class="px-4 py-2 text-xs rounded-md bg-slate-800 hover:bg-slate-700">
                    Open in new tab
                </a>
            </div>
        </div>

    </div>


    <script>
        document.getElementById("generateBtn").addEventListener("click", async () => {
            const prompt = document.getElementById("prompt").value.trim();
            const style = document.getElementById("style").value;
            const errorMsg = document.getElementById("errorMsg");
            const resultBox = document.getElementById("result");
            const imgEl = document.getElementById("generatedImg");
            const downloadBtn = document.getElementById("downloadBtn");
            const openBtn = document.getElementById("openBtn");

            if (!prompt) return;

            // reset
            errorMsg.classList.add("hidden");
            resultBox.classList.add("hidden");

            const btn = document.getElementById("generateBtn");
            btn.innerText = "Generating...";
            btn.disabled = true;

            // call Laravel API
            const res = await fetch("/api/ai/generate", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: new URLSearchParams({
                    prompt: `${prompt} | style: ${style}`,
                }),
            });

            const data = await res.json();

            btn.innerText = "Generate Image";
            btn.disabled = false;

            if (!data.success) {
                errorMsg.innerText = data.message || "Failed to generate image";
                errorMsg.classList.remove("hidden");
                return;
            }

            // tampilkan hasil
            imgEl.src = data.url;
            downloadBtn.href = data.url;
            openBtn.href = data.url;

            resultBox.classList.remove("hidden");
        });
    </script>

</body>

</html>
