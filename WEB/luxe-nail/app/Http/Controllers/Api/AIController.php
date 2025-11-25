<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Reservation;
use Illuminate\Support\Facades\Log;

class AIController extends Controller
{
    public function generate(Request $request)
    {
        // 1. Validasi
        $request->validate([
            'prompt' => 'required|string|min:3',
            'reservation_id' => 'required|integer',
        ]);

        $reservation = Reservation::find($request->reservation_id);

        if (!$reservation) {
            return response()->json(['success' => false, 'message' => 'Reservation not found'], 404);
        }

        if ($reservation->generate_count >= 3) {
            return response()->json(['success' => false, 'message' => 'Limit reached (3x).'], 403);
        }

        $apiKey = env('OPENROUTER_API_KEY');

        // KITA PAKAI MODEL PILIHANMU (GEMINI 2.5)
        // Karena kamu sudah buktikan di log kalau dia merespon.
        $model = "google/gemini-2.5-flash-image";

        try {
            // Request ke OpenRouter
            $response = Http::withHeaders([
                "Authorization" => "Bearer $apiKey",
                "Content-Type" => "application/json",
                "HTTP-Referer" => url('/'),
                "X-Title" => "Nail Art App",
            ])->post("https://openrouter.ai/api/v1/chat/completions", [
                "model" => $model,
                "messages" => [
                    [
                        "role" => "user",
                        "content" => "Generate a realistic nail art design based on: " . $request->prompt
                    ]
                ]
            ]);

            $json = $response->json();

            if ($response->failed()) {
                Log::error('AI Error', $json);
                return response()->json(['success' => false, 'message' => 'AI Error', 'raw' => $json], 500);
            }

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Connection failed'], 500);
        }

        // ==========================================================
        // PARSING LOGIC BARU (UNIVERSAL)
        // ==========================================================
        $imageUrl = null;

        // CARA 1: Cek struktur Gemini/OpenRouter "images" array (SESUAI LOG KAMU)
        // Path: choices -> 0 -> message -> images -> 0 -> image_url -> url
        $imagesArray = data_get($json, 'choices.0.message.images');
        if (!empty($imagesArray) && is_array($imagesArray)) {
            // Coba ambil nested url
            $imageUrl = data_get($imagesArray[0], 'image_url.url');

            // Kalau kosong, coba ambil langsung (format lain)
            if (!$imageUrl) {
                $imageUrl = data_get($imagesArray[0], 'url');
            }
        }

        // CARA 2: Kalau Cara 1 gagal, Cek Markdown di Content (Cara Lama)
        if (!$imageUrl) {
            $content = data_get($json, 'choices.0.message.content');
            if ($content) {
                preg_match('#\bhttps?://[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|/))#', $content, $matches);
                $imageUrl = $matches[0] ?? null;
            }
        }

        // CARA 3: Cek field 'url' langsung (Standar OpenAI DALL-E)
        if (!$imageUrl) {
             $imageUrl = data_get($json, 'choices.0.message.url');
        }

        // Kalau semua gagal
        if (!$imageUrl) {
            // Kita return RAW response biar kamu bisa lihat strukturnya kalau masih error
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil URL gambar. Format respons tidak dikenali.',
                'raw_response' => $json
            ], 500);
        }

        // Sukses
        $reservation->generate_count += 1;
        $reservation->save();

        return response()->json([
            "success" => true,
            "generate_count" => $reservation->generate_count,
            "image_url" => $imageUrl
        ]);
    }
}
