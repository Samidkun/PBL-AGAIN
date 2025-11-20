<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AIController extends Controller
{

    public function index()
    {
        return view('ai-generator');
    }
    public function generate(Request $request)
    {
        $request->validate([
            'prompt' => 'required|string',
        ]);

        $apiKey = env('OPENROUTER_API_KEY');

        if (!$apiKey) {
            return response()->json([
                'success' => false,
                'message' => 'OPENROUTER_API_KEY is not set in .env',
            ], 500);
        }

        // gabung prompt (kalau nanti mau tambahin style dsb, bisa di sini)
        $prompt = $request->prompt;

        $payload = [
            "model" => "google/gemini-2.5-flash-image",
            "messages" => [
                [
                    "role" => "user",
                    "content" => $prompt,
                ],
            ],
            "modalities" => ["image", "text"],
        ];

        $response = Http::withHeaders([
            "Authorization" => "Bearer $apiKey",
            "Content-Type" => "application/json",
            "HTTP-Referer" => url('/'),
            "X-Title" => "Luxe Nail AI Generator",
        ])->post("https://openrouter.ai/api/v1/chat/completions", $payload);

        if ($response->failed()) {
            return response()->json([
                'success' => false,
                'message' => 'Request to OpenRouter failed',
                'status'  => $response->status(),
                'raw'     => $response->json(),
            ], 500);
        }

        $json = $response->json();

        // ambil url gambar: choices[0].message.images[0].image_url.url
        $imageUrl = data_get($json, 'choices.0.message.images.0.image_url.url');

        if (!$imageUrl) {
            return response()->json([
                'success' => false,
                'message' => 'Image URL not found in OpenRouter response',
                'raw'     => $json,
            ], 500);
        }

        return response()->json([
            'success' => true,
            'url'     => $imageUrl,
        ]);
    }
}
