<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\NailArtist;

class StaffController extends Controller
{
    public function toggleBreak(Request $request)
    {
        $user = $request->user();

        // Ensure user is a nail artist
        if ($user->role !== 'nail_artist') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Only nail artists can toggle break.'
            ], 403);
        }

        $artist = NailArtist::where('user_id', $user->id)->first();

        if (!$artist) {
            return response()->json([
                'success' => false,
                'message' => 'Nail Artist profile not found.'
            ], 404);
        }

        // Toggle status
        $artist->is_on_break = !$artist->is_on_break;
        $artist->save();

        return response()->json([
            'success' => true,
            'message' => $artist->is_on_break ? 'You are now on break.' : 'Welcome back!',
            'data' => [
                'is_on_break' => (bool) $artist->is_on_break,
                'status' => $artist->real_time_status // Return dynamic status
            ]
        ]);
    }
}
