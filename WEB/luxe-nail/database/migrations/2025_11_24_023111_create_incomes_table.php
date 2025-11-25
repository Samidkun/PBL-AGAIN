<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('incomes', function (Blueprint $table) {
            $table->id();

            // FIXED 1 & 2: Foreign key modern, dan biarkan nullable untuk menghindari error saat reservasi dihapus.
            $table->foreignId('reservation_id')->nullable()->constrained('reservations')->onDelete('set null');

            // snapshot customer (Ditambahkan nullable() agar lebih aman)
            $table->string('customer_name')->nullable();
            $table->string('customer_phone')->nullable();
            $table->string('treatment_type')->nullable();

            // detail desain AI
            $table->string('shape')->nullable();
            $table->string('color')->nullable();
            $table->string('finish')->nullable();
            $table->string('accessory')->nullable();

            // harga
            $table->integer('price_shape')->default(0);
            $table->integer('price_color')->default(0);
            $table->integer('price_finish')->default(0);
            $table->integer('price_accessory')->default(0);
            $table->integer('total_price')->default(0);

            // FIXED 3: COLUMN NAME DIUBAH KE ai_image_url (match Controller) dan tipe LONGTEXT
            $table->longText('ai_image_url')->nullable();

            // pembayaran
            $table->enum('payment_status', ['pending', 'paid'])->default('pending');

            $table->date('reservation_date')->nullable(); // Ditambahkan nullable
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('incomes');
    }
};
