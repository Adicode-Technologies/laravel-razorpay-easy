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
