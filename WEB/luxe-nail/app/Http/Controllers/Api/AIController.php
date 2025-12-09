<?php

namespace App\Http\Controllers\Api;

use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Reservation;
use Illuminate\Support\Facades\Log;

class AIController extends Controller
{
    public function generate(Request $request)
    {
        // 0. Pastikan token valid
        $user = Auth::user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not authenticated',
                'code' => 401
            ], 401);
        }

        // 1. Validasi input
        $request->validate([
            'prompt' => 'required|string|min:3',
            'reservation_id' => 'required|integer',
        ]);

        // 2. Ambil reservasi
        $reservation = Reservation::find($request->reservation_id);
        if (!$reservation) {
            return response()->json(['success' => false, 'message' => 'Reservation not found'], 404);
        }

        // 3. Cek limit generate
        if ($reservation->generate_count >= 3) {
            return response()->json(['success' => false, 'message' => 'Limit reached (3x).'], 403);
        }

        // 4. OpenRouter API
        $apiKey = env('OPENROUTER_API_KEY');
        $model = "google/gemini-2.5-flash-image";

        try {
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
                                "content" => "Create a simple, realistic photo of nail art on a hand. Requirements: " . $request->prompt . ". The image should be a clear, straightforward product photo showing the nails from a natural angle. No artistic effects, no dramatic lighting, no fancy backgrounds. Just a clean, realistic representation of the nail design as it would look in real life."
                            ]
                        ]
                    ]);

            $json = $response->json();

            if ($response->failed()) {
                Log::error("AI Error", ['raw' => $json]);
                return response()->json([
                    'success' => false,
                    'message' => 'AI Error',
                    'raw' => $json
                ], 500);
            }

        } catch (\Exception $e) {
            Log::error("AI Exception: " . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Connection failed',
                'error' => $e->getMessage()
            ], 500);
        }

        // 5. Ambil URL gambar
        $imageUrl =
            data_get($json, 'choices.0.message.images.0.image_url.url') ??
            data_get($json, 'choices.0.message.images.0.url') ??
            data_get($json, 'choices.0.message.url');

        if (!$imageUrl) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot parse image URL',
                'raw_response' => $json
            ], 500);
        }

        // 6. Download and save image locally
        try {
            $imageContent = file_get_contents($imageUrl);

            if ($imageContent === false) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to download image from AI service'
                ], 500);
            }

            // Generate unique filename
            $filename = 'ai_' . time() . '_' . $reservation->id . '.jpg';
            $path = 'ai_generated/' . $filename;

            // Save to storage/app/public/ai_generated/
            \Storage::disk('public')->put($path, $imageContent);

            // Generate local URL
            $localImageUrl = url('/served-image/' . $path);

        } catch (\Exception $e) {
            Log::error("Image download failed: " . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to save image',
                'error' => $e->getMessage()
            ], 500);
        }

        // 7. Update generate count
        $reservation->increment('generate_count');

        return response()->json([
            'success' => true,
            'generate_count' => $reservation->generate_count,
            'image_url' => $localImageUrl
        ]);
    }
}
