<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Razorpay Keys
    |--------------------------------------------------------------------------
    |
    | The Razorpay API keys for authentication.
    |
    */
    'key_id' => env('RAZORPAY_KEY_ID', ''),
    'key_secret' => env('RAZORPAY_KEY_SECRET', ''),

    /*
    |--------------------------------------------------------------------------
    | Webhook Secret
    |--------------------------------------------------------------------------
    |
    | This is used to verify the webhook signature from Razorpay.
    |
    */
    'webhook_secret' => env('RAZORPAY_WEBHOOK_SECRET', ''),

    /*
    |--------------------------------------------------------------------------
    | Payment Settings
    |--------------------------------------------------------------------------
    |
    | These settings control the behavior of the payment process.
    |
    */
    'currency' => env('RAZORPAY_CURRENCY', 'INR'),
    'capture_automatically' => env('RAZORPAY_CAPTURE_AUTOMATICALLY', true),

    /*
    |--------------------------------------------------------------------------
    | Checkout Customization
    |--------------------------------------------------------------------------
    |
    | Customize the checkout experience.
    |
    */
    'checkout' => [
        'theme_color' => env('RAZORPAY_THEME_COLOR', '#3399cc'),
        'logo' => env('RAZORPAY_LOGO_URL', null),
        'prefill' => [
            'contact' => true,
            'email' => true,
        ],
        'modal' => [
            'backdrop_close' => false,
            'escape_key_close' => false,
            'animation' => true,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Routes Configuration
    |--------------------------------------------------------------------------
    |
    | Configure the routes for the package.
    |
    */
    'routes' => [
        'prefix' => 'razorpay',
        'middleware' => ['web'],
        'webhook_middleware' => ['api'],
        'enable_default_routes' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Database Configuration
    |--------------------------------------------------------------------------
    |
    | Configure the database table name for storing payment records.
    |
    */
    'table_name' => 'razorpay_payments',

    /*
    |--------------------------------------------------------------------------
    | Webhook Events
    |--------------------------------------------------------------------------
    |
    | Configure which webhook events to process.
    |
    */
    'webhook_events' => [
        'payment.authorized',
        'payment.captured',
        'payment.failed',
        'refund.created',
        'refund.processed',
        'refund.failed',
    ],
];
