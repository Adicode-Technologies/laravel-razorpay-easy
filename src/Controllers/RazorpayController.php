<?php

namespace AdicodeTechnologies\LaravelRazorpayEasy\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use AdicodeTechnologies\LaravelRazorpayEasy\Facades\Razorpay;

class RazorpayController extends Controller
{
    /**
     * Show the checkout page.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\View\View
     */
    public function checkout(Request $request)
    {
        $amount = $request->amount;
        $currency = $request->currency ?? config('razorpay.currency');
        $description = $request->description ?? 'Payment for order';

        // Create Razorpay order
        $order = Razorpay::createOrder($amount, $currency, [
            'notes' => $request->notes ?? [],
        ]);

        // Prepare checkout data
        $checkoutData = [
            'key' => config('razorpay.key_id'),
            'amount' => $order->amount,
            'currency' => $order->currency,
            'name' => $request->name ?? config('app.name'),
            'description' => $description,
            'order_id' => $order->id,
            'prefill' => [
                'name' => $request->customer_name ?? '',
                'email' => $request->customer_email ?? '',
                'contact' => $request->customer_phone ?? '',
            ],
            'theme' => [
                'color' => config('razorpay.checkout.theme_color'),
            ],
        ];

        // Add logo if configured
        if (config('razorpay.checkout.logo')) {
            $checkoutData['image'] = config('razorpay.checkout.logo');
        }

        // Add modal options
        $checkoutData['modal'] = config('razorpay.checkout.modal');

        return view('razorpay::checkout', [
            'checkoutData' => $checkoutData,
            'callbackUrl' => $request->callback_url ?? route('razorpay.payment.callback'),
        ]);
    }

    /**
     * Handle payment callback.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function callback(Request $request)
    {
        try {
            // Validate request
            $request->validate([
                'razorpay_payment_id' => 'required',
                'razorpay_order_id' => 'required',
                'razorpay_signature' => 'required',
            ]);

            // Process payment
            $payment = Razorpay::processPayment($request->all());

            // Redirect to success page
            return view('razorpay::success', [
                'payment' => $payment,
                'redirectUrl' => $request->redirect_url ?? '/',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 400);
        }
    }
}
