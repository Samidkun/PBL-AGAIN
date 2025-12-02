<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('nail_artists', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('cascade');

            // available / busy / break
            $table->enum('status', ['available', 'busy', 'break'])->default('available');

            // hitungan salary harian
            $table->integer('customers_today')->default(0);

            $table->timestamps();
        });

        // Tambahkan kolom nail_artist_id ke reservations
        // Schema::table('reservations', function (Blueprint $table) {
        //     $table->unsignedBigInteger('nail_artist_id')->nullable()->after('id');

        //     $table->foreign('nail_artist_id')
        //         ->references('id')
        //         ->on('nail_artists')
        //         ->nullOnDelete();
        // });
    }

    public function down()
    {
        Schema::dropIfExists('nail_artists');

        Schema::table('reservations', function (Blueprint $table) {
            $table->dropColumn('nail_artist_id');
        });
    }
}
;
