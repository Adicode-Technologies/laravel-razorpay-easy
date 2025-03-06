#!/bin/bash

# Laravel Razorpay Package Generator
# This script creates a complete Laravel Razorpay integration package

# Set colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - change these as needed
PACKAGE_NAME="laravel-razorpay-easy"
VENDOR_NAME="yourname"
NAMESPACE="YourName"
PACKAGE_DESCRIPTION="A simple and customizable Razorpay integration for Laravel applications"
AUTHOR_NAME="Your Name"
AUTHOR_EMAIL="your.email@example.com"

# Create base directory
echo -e "${BLUE}Creating package structure for ${GREEN}$VENDOR_NAME/$PACKAGE_NAME${NC}"
mkdir -p $PACKAGE_NAME/{config,database/migrations,resources/{views,js},routes,src/{Commands,Controllers,Events,Facades,Models,Services,Traits}}

# Change to the package directory
cd $PACKAGE_NAME

# Create composer.json
echo -e "${BLUE}Creating composer.json${NC}"
cat > composer.json << EOF
{
    "name": "$VENDOR_NAME/$PACKAGE_NAME",
    "description": "$PACKAGE_DESCRIPTION",
    "keywords": ["laravel", "razorpay", "payment", "gateway"],
    "type": "library",
    "license": "MIT",
    "authors": [
        {
            "name": "$AUTHOR_NAME",
            "email": "$AUTHOR_EMAIL"
        }
    ],
    "require": {
        "php": "^8.1",
        "illuminate/support": "^10.0|^11.0",
        "razorpay/razorpay": "^2.8"
    },
    "autoload": {
        "psr-4": {
            "$NAMESPACE\\\\LaravelRazorpayEasy\\\\": "src/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "$NAMESPACE\\\\LaravelRazorpayEasy\\\\RazorpayServiceProvider"
            ],
            "aliases": {
                "Razorpay": "$NAMESPACE\\\\LaravelRazorpayEasy\\\\Facades\\\\Razorpay"
            }
        }
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}
EOF

# Create LICENSE file
echo -e "${BLUE}Creating LICENSE file${NC}"
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create config file
echo -e "${BLUE}Creating config file${NC}"
cat > config/razorpay.php << 'EOF'
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
EOF

# Create Service Provider
echo -e "${BLUE}Creating Service Provider${NC}"
cat > src/RazorpayServiceProvider.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy;

use Illuminate\Support\ServiceProvider;
use $NAMESPACE\LaravelRazorpayEasy\Commands\InstallRazorpayCommand;
use $NAMESPACE\LaravelRazorpayEasy\Services\RazorpayService;

class RazorpayServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     */
    public function boot()
    {
        // Publish configuration
        \$this->publishes([
            __DIR__.'/../config/razorpay.php' => config_path('razorpay.php'),
        ], 'razorpay-config');

        // Publish migrations
        \$this->publishes([
            __DIR__.'/../database/migrations/' => database_path('migrations'),
        ], 'razorpay-migrations');

        // Publish views
        \$this->publishes([
            __DIR__.'/../resources/views' => resource_path('views/vendor/razorpay'),
        ], 'razorpay-views');

        // Publish assets
        \$this->publishes([
            __DIR__.'/../resources/js' => public_path('vendor/razorpay'),
        ], 'razorpay-assets');

        // Load routes
        \$this->loadRoutesFrom(__DIR__.'/../routes/web.php');

        // Load views
        \$this->loadViewsFrom(__DIR__.'/../resources/views', 'razorpay');

        // Register commands
        if (\$this->app->runningInConsole()) {
            \$this->commands([
                InstallRazorpayCommand::class,
            ]);
        }
    }

    /**
     * Register the application services.
     */
    public function register()
    {
        // Merge configuration
        \$this->mergeConfigFrom(__DIR__.'/../config/razorpay.php', 'razorpay');

        // Register the service
        \$this->app->singleton('razorpay', function (\$app) {
            return new RazorpayService(
                config('razorpay.key_id'),
                config('razorpay.key_secret')
            );
        });
    }
}
EOF

# Create Facade
echo -e "${BLUE}Creating Facade${NC}"
cat > src/Facades/Razorpay.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Facades;

use Illuminate\Support\Facades\Facade;

class Razorpay extends Facade
{
    /**
     * Get the registered name of the component.
     *
     * @return string
     */
    protected static function getFacadeAccessor()
    {
        return 'razorpay';
    }
}
EOF

# Create RazorpayService
echo -e "${BLUE}Creating RazorpayService${NC}"
cat > src/Services/RazorpayService.php << 'EOF'
<?php

namespace YourName\LaravelRazorpayEasy\Services;

use Razorpay\Api\Api;
use Illuminate\Support\Str;
use YourName\LaravelRazorpayEasy\Models\Payment;
use YourName\LaravelRazorpayEasy\Events\PaymentSucceeded;
use YourName\LaravelRazorpayEasy\Events\PaymentFailed;

class RazorpayService
{
    /**
     * Razorpay API instance
     *
     * @var \Razorpay\Api\Api
     */
    protected $api;

    /**
     * Create a new RazorpayService instance.
     *
     * @param string $keyId
     * @param string $keySecret
     */
    public function __construct($keyId = null, $keySecret = null)
    {
        $keyId = $keyId ?? config('razorpay.key_id');
        $keySecret = $keySecret ?? config('razorpay.key_secret');
        
        $this->api = new Api($keyId, $keySecret);
    }

    /**
     * Create a new order.
     *
     * @param float $amount
     * @param string $currency
     * @param array $options
     * @return \Razorpay\Api\Order
     */
    public function createOrder($amount, $currency = null, $options = [])
    {
        $currency = $currency ?? config('razorpay.currency');
        
        // Convert amount to paise/cents (Razorpay expects amount in smallest currency unit)
        $amountInSmallestUnit = $amount * 100;
        
        $orderData = array_merge([
            'receipt' => 'order_' . Str::random(16),
            'amount' => (int) $amountInSmallestUnit,
            'currency' => $currency,
        ], $options);
        
        return $this->api->order->create($orderData);
    }

    /**
     * Verify payment signature.
     *
     * @param string $razorpayPaymentId
     * @param string $razorpayOrderId
     * @param string $signature
     * @return bool
     */
    public function verifyPaymentSignature($razorpayPaymentId, $razorpayOrderId, $signature)
    {
        try {
            $this->api->utility->verifyPaymentSignature([
                'razorpay_payment_id' => $razorpayPaymentId,
                'razorpay_order_id' => $razorpayOrderId,
                'razorpay_signature' => $signature,
            ]);
            
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Fetch payment details.
     *
     * @param string $paymentId
     * @return \Razorpay\Api\Payment
     */
    public function fetchPayment($paymentId)
    {
        return $this->api->payment->fetch($paymentId);
    }

    /**
     * Capture payment.
     *
     * @param string $paymentId
     * @param int $amount
     * @param string $currency
     * @return \Razorpay\Api\Payment
     */
    public function capturePayment($paymentId, $amount, $currency = null)
    {
        $currency = $currency ?? config('razorpay.currency');
        
        // Convert amount to paise/cents
        $amountInSmallestUnit = $amount * 100;
        
        return $this->api->payment->fetch($paymentId)->capture([
            'amount' => (int) $amountInSmallestUnit,
            'currency' => $currency,
        ]);
    }

    /**
     * Create a refund.
     *
     * @param string $paymentId
     * @param float|null $amount
     * @param array $options
     * @return \Razorpay\Api\Refund
     */
    public function createRefund($paymentId, $amount = null, $options = [])
    {
        $refundData = $options;
        
        if ($amount !== null) {
            // Convert amount to paise/cents
            $amountInSmallestUnit = $amount * 100;
            $refundData['amount'] = (int) $amountInSmallestUnit;
        }
        
        return $this->api->payment->fetch($paymentId)->refund($refundData);
    }

    /**
     * Process payment after successful checkout.
     *
     * @param array $paymentData
     * @return \YourName\LaravelRazorpayEasy\Models\Payment
     */
    public function processPayment(array $paymentData)
    {
        // Verify payment signature
        $isValid = $this->verifyPaymentSignature(
            $paymentData['razorpay_payment_id'],
            $paymentData['razorpay_order_id'],
            $paymentData['razorpay_signature']
        );
        
        if (!$isValid) {
            event(new PaymentFailed($paymentData));
            throw new \Exception('Invalid payment signature');
        }
        
        // Fetch payment details
        $paymentDetails = $this->fetchPayment($paymentData['razorpay_payment_id']);
        
        // Create payment record
        $payment = Payment::create([
            'payment_id' => $paymentDetails->id,
            'order_id' => $paymentDetails->order_id,
            'amount' => $paymentDetails->amount / 100, // Convert back from paise to rupees
            'currency' => $paymentDetails->currency,
            'status' => $paymentDetails->status,
            'method' => $paymentDetails->method ?? null,
            'email' => $paymentDetails->email ?? null,
            'contact' => $paymentDetails->contact ?? null,
            'description' => $paymentData['description'] ?? null,
            'metadata' => json_encode($paymentData['metadata'] ?? []),
        ]);
        
        event(new PaymentSucceeded($payment));
        
        return $payment;
    }

    /**
     * Get the Razorpay API instance.
     *
     * @return \Razorpay\Api\Api
     */
    public function getApi()
    {
        return $this->api;
    }
}
EOF

# Create Payment Model
echo -e "${BLUE}Creating Payment Model${NC}"
cat > src/Models/Payment.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected \$fillable = [
        'payment_id',
        'order_id',
        'amount',
        'currency',
        'status',
        'method',
        'email',
        'contact',
        'description',
        'metadata',
        'payable_id',
        'payable_type',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected \$casts = [
        'amount' => 'float',
        'metadata' => 'array',
    ];

    /**
     * Get the table name from config.
     *
     * @return string
     */
    public function getTable()
    {
        return config('razorpay.table_name', parent::getTable());
    }

    /**
     * Get the owner of the payment.
     *
     * @return \Illuminate\Database\Eloquent\Relations\MorphTo
     */
    public function payable()
    {
        return \$this->morphTo();
    }

    /**
     * Scope a query to only include successful payments.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  \$query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeSuccessful(\$query)
    {
        return \$query->where('status', 'captured');
    }

    /**
     * Scope a query to only include failed payments.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  \$query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeFailed(\$query)
    {
        return \$query->where('status', 'failed');
    }
}
EOF

# Create HasRazorpayPayments Trait
echo -e "${BLUE}Creating HasRazorpayPayments Trait${NC}"
cat > src/Traits/HasRazorpayPayments.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Traits;

use $NAMESPACE\LaravelRazorpayEasy\Models\Payment;

trait HasRazorpayPayments
{
    /**
     * Get all payments for this model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\MorphMany
     */
    public function payments()
    {
        return \$this->morphMany(Payment::class, 'payable');
    }
    
    /**
     * Get successful payments for this model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\MorphMany
     */
    public function successfulPayments()
    {
        return \$this->payments()->where('status', 'captured');
    }
    
    /**
     * Create a new payment for this model.
     *
     * @param  float  \$amount
     * @param  string|null  \$currency
     * @param  array  \$options
     * @return \Razorpay\Api\Order
     */
    public function createPayment(\$amount, \$currency = null, \$options = [])
    {
        \$razorpay = app('razorpay');
        return \$razorpay->createOrder(\$amount, \$currency, \$options);
    }
    
    /**
     * Get the total amount paid.
     *
     * @return float
     */
    public function totalPaid()
    {
        return \$this->successfulPayments()->sum('amount');
    }
}
EOF

# Create RazorpayController
echo -e "${BLUE}Creating RazorpayController${NC}"
cat > src/Controllers/RazorpayController.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use $NAMESPACE\LaravelRazorpayEasy\Facades\Razorpay;

class RazorpayController extends Controller
{
    /**
     * Show the checkout page.
     *
     * @param  \Illuminate\Http\Request  \$request
     * @return \Illuminate\View\View
     */
    public function checkout(Request \$request)
    {
        \$amount = \$request->amount;
        \$currency = \$request->currency ?? config('razorpay.currency');
        \$description = \$request->description ?? 'Payment for order';
        
        // Create Razorpay order
        \$order = Razorpay::createOrder(\$amount, \$currency, [
            'notes' => \$request->notes ?? [],
        ]);
        
        // Prepare checkout data
        \$checkoutData = [
            'key' => config('razorpay.key_id'),
            'amount' => \$order->amount,
            'currency' => \$order->currency,
            'name' => \$request->name ?? config('app.name'),
            'description' => \$description,
            'order_id' => \$order->id,
            'prefill' => [
                'name' => \$request->customer_name ?? '',
                'email' => \$request->customer_email ?? '',
                'contact' => \$request->customer_phone ?? '',
            ],
            'theme' => [
                'color' => config('razorpay.checkout.theme_color'),
            ],
        ];
        
        // Add logo if configured
        if (config('razorpay.checkout.logo')) {
            \$checkoutData['image'] = config('razorpay.checkout.logo');
        }
        
        // Add modal options
        \$checkoutData['modal'] = config('razorpay.checkout.modal');
        
        return view('razorpay::checkout', [
            'checkoutData' => \$checkoutData,
            'callbackUrl' => \$request->callback_url ?? route('razorpay.payment.callback'),
        ]);
    }
    
    /**
     * Handle payment callback.
     *
     * @param  \Illuminate\Http\Request  \$request
     * @return \Illuminate\Http\Response
     */
    public function callback(Request \$request)
    {
        try {
            // Validate request
            \$request->validate([
                'razorpay_payment_id' => 'required',
                'razorpay_order_id' => 'required',
                'razorpay_signature' => 'required',
            ]);
            
            // Process payment
            \$payment = Razorpay::processPayment(\$request->all());
            
            // Redirect to success page
            return view('razorpay::success', [
                'payment' => \$payment,
                'redirectUrl' => \$request->redirect_url ?? '/',
            ]);
        } catch (\Exception \$e) {
            return response()->json([
                'success' => false,
                'message' => \$e->getMessage(),
            ], 400);
        }
    }
}
EOF

# Create WebhookController
echo -e "${BLUE}Creating WebhookController${NC}"
cat > src/Controllers/WebhookController.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use $NAMESPACE\LaravelRazorpayEasy\Events\WebhookReceived;
use $NAMESPACE\LaravelRazorpayEasy\Facades\Razorpay;

class WebhookController extends Controller
{
    /**
     * Handle Razorpay webhook.
     *
     * @param  \Illuminate\Http\Request  \$request
     * @return \Illuminate\Http\Response
     */
    public function handleWebhook(Request \$request)
    {
        \$payload = \$request->all();
        \$signature = \$request->header('X-Razorpay-Signature');
        
        // Verify webhook signature
        if (!\$this->verifyWebhookSignature(\$payload, \$signature)) {
            return response()->json(['message' => 'Invalid signature'], 400);
        }
        
        // Process webhook event
        \$event = \$payload['event'];
        
        // Check if this event should be processed
        if (!in_array(\$event, config('razorpay.webhook_events'))) {
            return response()->json(['message' => 'Event not configured for processing'], 200);
        }
        
        // Dispatch event
        event(new WebhookReceived(\$event, \$payload));
        
        // Process specific events
        switch (\$event) {
            case 'payment.captured':
                \$this->handlePaymentCaptured(\$payload);
                break;
            case 'payment.failed':
                \$this->handlePaymentFailed(\$payload);
                break;
            // Add more event handlers as needed
        }
        
        return response()->json(['message' => 'Webhook processed successfully']);
    }
    
    /**
     * Verify webhook signature.
     *
     * @param  array  \$payload
     * @param  string  \$signature
     * @return bool
     */
    protected function verifyWebhookSignature(\$payload, \$signature)
    {
        \$webhookSecret = config('razorpay.webhook_secret');
        
        if (empty(\$webhookSecret) || empty(\$signature)) {
            return false;
        }
        
        try {
            \$expectedSignature = hash_hmac('sha256', json_encode(\$payload, JSON_UNESCAPED_SLASHES), \$webhookSecret);
            return hash_equals(\$expectedSignature, \$signature);
        } catch (\Exception \$e) {
            return false;
        }
    }
    
    /**
     * Handle payment captured event.
     *
     * @param  array  \$payload
     * @return void
     */
    protected function handlePaymentCaptured(\$payload)
    {
        // Implementation for payment captured event
    }
    
    /**
     * Handle payment failed event.
     *
     * @param  array  \$payload
     * @return void
     */
    protected function handlePaymentFailed(\$payload)
    {
        // Implementation for payment failed event
    }
}
EOF

# Create Events
echo -e "${BLUE}Creating Events${NC}"
cat > src/Events/PaymentSucceeded.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use $NAMESPACE\LaravelRazorpayEasy\Models\Payment;

class PaymentSucceeded
{
    use Dispatchable, SerializesModels;

    /**
     * The payment instance.
     *
     * @var \$NAMESPACE\LaravelRazorpayEasy\Models\Payment
     */
    public \$payment;

    /**
     * Create a new event instance.
     *
     * @param  \$NAMESPACE\LaravelRazorpayEasy\Models\Payment  \$payment
     * @return void
     */
    public function __construct(Payment \$payment)
    {
        \$this->payment = \$payment;
    }
}
EOF

cat > src/Events/PaymentFailed.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class PaymentFailed
{
    use Dispatchable, SerializesModels;

    /**
     * The payment data.
     *
     * @var array
     */
    public \$paymentData;

    /**
     * Create a new event instance.
     *
     * @param  array  \$paymentData
     * @return void
     */
    public function __construct(array \$paymentData)
    {
        \$this->paymentData = \$paymentData;
    }
}
EOF

cat > src/Events/WebhookReceived.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class WebhookReceived
{
    use Dispatchable, SerializesModels;

    /**
     * The webhook event name.
     *
     * @var string
     */
    public \$eventName;

    /**
     * The webhook payload.
     *
     * @var array
     */
    public \$payload;

    /**
     * Create a new event instance.
     *
     * @param  string  \$eventName
     * @param  array  \$payload
     * @return void
     */
    public function __construct(string \$eventName, array \$payload)
    {
        \$this->eventName = \$eventName;
        \$this->payload = \$payload;
    }
}
EOF

# Create Install Command
echo -e "${BLUE}Creating Install Command${NC}"
cat > src/Commands/InstallRazorpayCommand.php << EOF
<?php

namespace $NAMESPACE\LaravelRazorpayEasy\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class InstallRazorpayCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected \$signature = 'razorpay:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected \$description = 'Install the Razorpay package';

    /**
     * Execute the console command.
     *
     * @return void
     */
    public function handle()
    {
        \$this->info('Installing Laravel Razorpay Easy...');

        // Publish configuration
        \$this->callSilent('vendor:publish', [
            '--provider' => '$NAMESPACE\LaravelRazorpayEasy\RazorpayServiceProvider',
            '--tag' => 'razorpay-config',
        ]);

        \$this->info('Published configuration');

        // Publish migrations
        \$this->callSilent('vendor:publish', [
            '--provider' => '$NAMESPACE\LaravelRazorpayEasy\RazorpayServiceProvider',
            '--tag' => 'razorpay-migrations',
        ]);

        \$this->info('Published migrations');

        // Run migrations
        if (\$this->confirm('Would you like to run migrations now?', true)) {
            \$this->call('migrate');
        }

        // Add environment variables
        \$this->addEnvironmentVariables();

        \$this->info('Razorpay integration installed successfully.');
        \$this->info('Please set your Razorpay API keys in the .env file:');
        \$this->info('RAZORPAY_KEY_ID=your_key_id');
        \$this->info('RAZORPAY_KEY_SECRET=your_key_secret');
    }

    /**
     * Add environment variables to .env file.
     *
     * @return void
     */
    protected function addEnvironmentVariables()
    {
        \$envPath = base_path('.env');
        
        if (File::exists(\$envPath)) {
            \$content = File::get(\$envPath);
            
            if (!str_contains(\$content, 'RAZORPAY_KEY_ID')) {
                File::append(\$envPath, "\n# Razorpay Configuration\nRAZORPAY_KEY_ID=\nRAZORPAY_KEY_SECRET=\nRAZORPAY_WEBHOOK_SECRET=\n");
                \$this->info('Added Razorpay environment variables to .env file');
            }
        }
    }
}
EOF

# Create Routes
echo -e "${BLUE}Creating Routes${NC}"
cat > routes/web.php << EOF
<?php

use Illuminate\Support\Facades\Route;
use $NAMESPACE\LaravelRazorpayEasy\Controllers\RazorpayController;
use $NAMESPACE\LaravelRazorpayEasy\Controllers\WebhookController;

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
EOF

# Create Migration
echo -e "${BLUE}Creating Migration${NC}"
cat > database/migrations/create_razorpay_payments_table.php << 'EOF'
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
EOF

# Create Views
echo -e "${BLUE}Creating Views${NC}"
mkdir -p resources/views
cat > resources/views/checkout.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Razorpay Checkout</title>
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
            width: 100%;
            max-width: 500px;
            text-align: center;
        }
        .button {
            background-color: {{ config('razorpay.checkout.theme_color', '#3399cc') }};
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 20px;
        }
        .button:hover {
            opacity: 0.9;
        }
        .amount {
            font-size: 24px;
            font-weight: bold;
            margin: 20px 0;
        }
        .description {
            color: #6c757d;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Checkout</h1>
        <div class="description">{{ $checkoutData['description'] }}</div>
        <div class="amount">{{ $checkoutData['currency'] }} {{ number_format($checkoutData['amount'] / 100, 2) }}</div>
        <button id="rzp-button" class="button">Pay Now</button>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const options = @json($checkoutData);
            
            options.handler = function(response) {
                // Create a form to submit the payment details
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '{{ $callbackUrl }}';
                
                // Add CSRF token
                const csrfToken = document.createElement('input');
                csrfToken.type = 'hidden';
                csrfToken.name = '_token';
                csrfToken.value = '{{ csrf_token() }}';
                form.appendChild(csrfToken);
                
                // Add payment details
                for (const key in response) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = key;
                    input.value = response[key];
                    form.appendChild(input);
                }
                
                // Add description if available
                if (options.description) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'description';
                    input.value = options.description;
                    form.appendChild(input);
                }
                
                // Submit the form
                document.body.appendChild(form);
                form.submit();
            };
            
            const rzp = new Razorpay(options);
            
            document.getElementById('rzp-button').onclick = function(e) {
                rzp.open();
                e.preventDefault();
            };
        });
    </script>
</body>
</html>
EOF

cat > resources/views/success.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
            width: 100%;
            max-width: 500px;
            text-align: center;
        }
        .success-icon {
            color: #28a745;
            font-size: 64px;
            margin-bottom: 20px;
        }
        .button {
            background-color: {{ config('razorpay.checkout.theme_color', '#3399cc') }};
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 30px;
            text-decoration: none;
            display: inline-block;
        }
        .button:hover {
            opacity: 0.9;
        }
        .details {
            margin: 30px 0;
            text-align: left;
        }
        .details-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .details-label {
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">✓</div>
        <h1>Payment Successful</h1>
        <p>Your payment has been processed successfully.</p>
        
        <div class="details">
            <div class="details-row">
                <span class="details-label">Payment ID:</span>
                <span>{{ $payment->payment_id }}</span>
            </div>
            <div class="details-row">
                <span class="details-label">Amount:</span>
                <span>{{ $payment->currency }} {{ number_format($payment->amount, 2) }}</span>
            </div>
            <div class="details-row">
                <span class="details-label">Date:</span>
                <span>{{ $payment->created_at->format('d M Y, h:i A') }}</span>
            </div>
            @if($payment->description)
            <div class="details-row">
                <span class="details-label">Description:</span>
                <span>{{ $payment->description }}</span>
            </div>
            @endif
        </div>
        
        <a href="{{ $redirectUrl }}" class="button">Continue</a>
    </div>
</body>
</html>
EOF

# Create JS assets
echo -e "${BLUE}Creating JS assets${NC}"
mkdir -p resources/js
cat > resources/js/razorpay-checkout.js << 'EOF'
/**
 * Razorpay Checkout Helper
 * 
 * This script provides helper functions for working with Razorpay checkout.
 */

/**
 * Initialize Razorpay checkout with the given options
 * 
 * @param {Object} options - Razorpay options
 * @param {Function} successCallback - Callback function on successful payment
 * @param {Function} errorCallback - Callback function on payment error
 * @returns {Object} - Razorpay instance
 */
function initRazorpayCheckout(options, successCallback, errorCallback) {
    // Set default handlers if not provided
    options.handler = options.handler || function(response) {
        if (typeof successCallback === 'function') {
            successCallback(response);
        }
    };

    options.modal = options.modal || {};
    options.modal.ondismiss = options.modal.ondismiss || function() {
        if (typeof errorCallback === 'function') {
            errorCallback({ error: 'Payment cancelled by user' });
        }
    };

    // Create Razorpay instance
    const rzp = new Razorpay(options);

    // Handle payment errors
    rzp.on('payment.failed', function(response) {
        if (typeof errorCallback === 'function') {
            errorCallback(response.error);
        }
    });

    return rzp;
}

/**
 * Open Razorpay checkout
 * 
 * @param {Object} options - Razorpay options
 * @param {Function} successCallback - Callback function on successful payment
 * @param {Function} errorCallback - Callback function on payment error
 */
function openRazorpayCheckout(options, successCallback, errorCallback) {
    const rzp = initRazorpayCheckout(options, successCallback, errorCallback);
    rzp.open();
}
EOF

echo -e "${GREEN}Package created successfully!${NC}"
echo -e "You can now run ${BLUE}composer install${NC} in the package directory to install dependencies."
echo -e "To use this package in your Laravel project, add it as a path repository in your project's composer.json."
