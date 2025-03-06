<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create(config('razorpay.table_name', 'razorpay_payments'), function (Blueprint $table) {
            $table->id();
            $table->string('payment_id')->unique();
            $table->string('order_id');
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3);
            $table->string('status');
            $table->string('method')->nullable();
            $table->string('email')->nullable();
            $table->string('contact')->nullable();
            $table->string('description')->nullable();
            $table->json('metadata')->nullable();
            $table->nullableMorphs('payable');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists(config('razorpay.table_name', 'razorpay_payments'));
    }
};
