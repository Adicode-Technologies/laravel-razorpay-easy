# Laravel Razorpay Easy

A simple and highly customizable Razorpay integration package for Laravel applications.

## Features

- 🚀 Quick and easy setup
- 🛠️ Pre-built checkout page
- 🎨 Highly customizable
- 📊 Database integration for payment tracking
- 🔄 Event-driven architecture
- 🔗 Model relationships with payments
- 🔒 Secure payment processing
- 🪝 Webhook handling

## Installation

You can install the package via composer:

``` bash
composer require adicode-technologies/laravel-razorpay-easy
```

After installing the package, publish the assets:

``` bash
php artisan vendor:publish --provider="AdicodeTechnologies\LaravelRazorpayEasy\RazorpayServiceProvider"
```

Run the migrations:

``` bash
php artisan migrate
```

## Configuration

Add your Razorpay credentials to your `.env` file:

```
RAZORPAY_KEY_ID=your_key_id
RAZORPAY_KEY_SECRET=your_key_secret
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret
```

You can customize the package behavior by modifying the `config/razorpay.php` file.

## Basic Usage

## # Quick Checkout

Redirect to the pre-built checkout page:

``` php
return redirect()->route('razorpay.checkout', [
    'amount' => 100, // Amount in your currency (e.g., 100 = ₹100)
    'description' => 'Payment for Order #123',
    'customer_name' => 'John Doe',
    'customer_email' => 'john@example.com',
    'callback_url' => route('orders.payment.callback', $orderId),
]);
```

## # Custom Callback Handler

Create a callback handler to process payments:

``` php
// routes/web.php
Route::post('orders/{order}/payment/callback', [OrderController::class, 'handlePaymentCallback'])
    ->name('orders.payment.callback');

// OrderController.php
public function handlePaymentCallback(Request $request, Order $order)
{
    try {
        // Process the payment
        $payment = app('razorpay')->processPayment($request->all());
        
        // Associate with order
        $payment->payable_id = $order->id;
        $payment->payable_type = get_class($order);
        $payment->save();
        
        // Update order status
        $order->update(['status' => 'paid']);
        
        return redirect()->route('orders.show', $order)
            ->with('success', 'Payment completed successfully!');
    } catch (\Exception $e) {
        return redirect()->route('orders.show', $order)
            ->with('error', 'Payment failed: ' . $e->getMessage());
    }
}
```

## # Using the Trait

Add payment functionality to your models:

``` php
// app/Models/Order.php
use AdicodeTechnologies\LaravelRazorpayEasy\Traits\HasRazorpayPayments;

class Order extends Model
{
    use HasRazorpayPayments;
    
    // ...
}
```

Then you can use:

``` php
$order = Order::find(1);

// Get all payments
$payments = $order->payments;

// Get successful payments
$successfulPayments = $order->successfulPayments;

// Get total paid
$totalPaid = $order->totalPaid();
```

## # Direct API Access

Use the facade for direct API access:

``` php
use AdicodeTechnologies\LaravelRazorpayEasy\Facades\Razorpay;

// Create an order
$order = Razorpay::createOrder(100, 'INR');

// Fetch payment
$payment = Razorpay::fetchPayment($paymentId);

// Create refund
$refund = Razorpay::createRefund($paymentId, 100);
```

## Browser Compatibility

This package works with all major browsers. However, Brave Browser users may experience issues due to its privacy features. If you encounter problems:

- Try using incognito mode
- Temporarily disable Brave Shields
- Use an alternative browser like Chrome or Firefox

## Events

The package dispatches the following events:

- `PaymentSucceeded`: When a payment is successfully processed
- `PaymentFailed`: When a payment fails
- `WebhookReceived`: When a webhook is received

## License

The MIT License (MIT). Please see [License File](LICENSE) for more information.
