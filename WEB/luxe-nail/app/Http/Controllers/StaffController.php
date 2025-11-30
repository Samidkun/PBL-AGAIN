<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\NailArtist; 

class StaffController extends Controller
{
    public function index()
    {
        $staff = User::all();
        $nailArtists = NailArtist::orderBy('name')->get();

    return view('staff.index', compact('staff', 'nailArtists'));
        
    }

    public function create()
    {
        return view('staff.create');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required',
            'username' => 'required|string|unique:users,username',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|min:6'
        ]);

        User::create([
            'name'     => $request->name,
            'username' => $request->username,
            'email'    => $request->email,
            'password' => Hash::make($request->password)
        ]);

        return redirect()->route('staff.index')->with('success', 'Staff berhasil ditambahkan.');
    }

    public function edit(int $id)
    {
        $staff = User::findOrFail($id);
        return view('staff.edit', compact('staff'));
    }

    public function update(Request $request, int $id)
    {
        $staff = User::findOrFail($id);

        $request->validate([
            'name'     => 'required',
            'username' => 'required|string|unique:users,username,' . $id,
            'email'    => 'required|email|unique:users,email,' . $id
        ]);

        $staff->name = $request->name;
        $staff->username = $request->username;
        $staff->email = $request->email;

        if ($request->password) {
            $staff->password = Hash::make($request->password);
        }

        $staff->save();

        return redirect()->route('staff.index')->with('success', 'Staff berhasil diperbarui.');
    }

    public function destroy(int $id)
    {
        User::destroy($id);
        return redirect()->route('staff.index')->with('success', 'Staff berhasil dihapus.');
    }

}
