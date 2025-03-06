<?php

use Illuminate\Support\Facades\Route;
use YourName\LaravelRazorpayEasy\Controllers\RazorpayController;
use YourName\LaravelRazorpayEasy\Controllers\WebhookController;

// Only register routes if enabled in config
if (config('razorpay.routes.enable_default_routes', true)) {
    Route::group([
        'prefix' => config('razorpay.routes.prefix', 'razorpay'),
        'middleware' => config('razorpay.routes.middleware', ['web']),
    ], function () {
        // Checkout route
        Route::get('/checkout', [RazorpayController::class, 'checkout'])->name('razorpay.checkout');
        
        // Payment callback route
        Route::post('/payment/callback', [RazorpayController::class, 'callback'])->name('razorpay.payment.callback');
    });

    // Webhook route
    Route::post('/razorpay/webhook', [WebhookController::class, 'handleWebhook'])
        ->middleware(config('razorpay.routes.webhook_middleware', ['api']))
        ->name('razorpay.webhook');
}
