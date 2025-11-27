<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class AuthController extends Controller
{
    // ======================================================
    // LOGIN
    // ======================================================
    public function login(Request $request)
    {
        // 1. VALIDASI INPUT
        $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $loginInput = trim($request->username);

        // 2. CARI USER BERDASARKAN USERNAME ATAU EMAIL
        $user = User::where('username', $loginInput)
                    ->orWhere('email', $loginInput)
                    ->first();

        // ERROR: USER / PASSWORD SALAH
        if (!$user || !Hash::check($request->password, $user->password)) {

            // Jika request API / mobile
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            // Jika request web
            return back()->withErrors([
                'username' => 'Invalid username or password.'
            ]);
        }


        // ======================================================
        // LOGIN MOBILE (API)
        // ======================================================
        if ($request->expectsJson() || $request->is('api/*')) {

            // Blokir Admin di mobile
            if ($user->role !== 'nail_artist') {
                return response()->json([
                    'success' => false,
                    'message' => 'Access denied. Only Nail Artists can login via mobile.'
                ], 403);
            }

            // Bikin Token Sanctum
            $token = $user->createToken('api_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'user' => [
                    'id'       => $user->id,
                    'username' => $user->username,
                    'email'    => $user->email,
                    'role'     => $user->role,
                ],
                'token' => $token,
                'token_type' => 'Bearer'
            ]);
        }


        // ======================================================
        // LOGIN WEB (ADMIN PANEL)
        // ======================================================
        if ($user->role !== 'admin') {
            return back()->withErrors([
                'access' => 'Only admin can login to the dashboard.'
            ]);
        }

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route('dashboard')->with('success', 'Welcome back, Admin!');
    }


    // ======================================================
    // LOGOUT
    // ======================================================
    public function logout(Request $request)
    {
        // API (mobile) logout
        if ($request->expectsJson() || $request->is('api/*')) {
            $request->user()->tokens()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully'
            ]);
        }

        // Web logout
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login-page')
                ->with('success', 'Logged out successfully.');
    }
}
