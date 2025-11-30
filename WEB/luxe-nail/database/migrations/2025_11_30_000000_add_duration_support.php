<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('treatment_types', function (Blueprint $table) {
            $table->integer('duration')->default(60)->after('name'); // Default 60 mins
        });

        Schema::table('reservations', function (Blueprint $table) {
            $table->time('end_time')->nullable()->after('reservation_time');
        });
    }

    public function down()
    {
        Schema::table('treatment_types', function (Blueprint $table) {
            $table->dropColumn('duration');
        });

        Schema::table('reservations', function (Blueprint $table) {
            $table->dropColumn('end_time');
        });
    }
};
