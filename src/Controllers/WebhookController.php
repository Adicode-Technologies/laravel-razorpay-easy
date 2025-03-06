<?php

namespace YourName\LaravelRazorpayEasy\Controllers;

use Illuminate\Http\Request;
use Illuminate\Routing\Controller;
use YourName\LaravelRazorpayEasy\Events\WebhookReceived;
use YourName\LaravelRazorpayEasy\Facades\Razorpay;

class WebhookController extends Controller
{
    /**
     * Handle Razorpay webhook.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function handleWebhook(Request $request)
    {
        $payload = $request->all();
        $signature = $request->header('X-Razorpay-Signature');
        
        // Verify webhook signature
        if (!$this->verifyWebhookSignature($payload, $signature)) {
            return response()->json(['message' => 'Invalid signature'], 400);
        }
        
        // Process webhook event
        $event = $payload['event'];
        
        // Check if this event should be processed
        if (!in_array($event, config('razorpay.webhook_events'))) {
            return response()->json(['message' => 'Event not configured for processing'], 200);
        }
        
        // Dispatch event
        event(new WebhookReceived($event, $payload));
        
        // Process specific events
        switch ($event) {
            case 'payment.captured':
                $this->handlePaymentCaptured($payload);
                break;
            case 'payment.failed':
                $this->handlePaymentFailed($payload);
                break;
            // Add more event handlers as needed
        }
        
        return response()->json(['message' => 'Webhook processed successfully']);
    }
    
    /**
     * Verify webhook signature.
     *
     * @param  array  $payload
     * @param  string  $signature
     * @return bool
     */
    protected function verifyWebhookSignature($payload, $signature)
    {
        $webhookSecret = config('razorpay.webhook_secret');
        
        if (empty($webhookSecret) || empty($signature)) {
            return false;
        }
        
        try {
            $expectedSignature = hash_hmac('sha256', json_encode($payload, JSON_UNESCAPED_SLASHES), $webhookSecret);
            return hash_equals($expectedSignature, $signature);
        } catch (\Exception $e) {
            return false;
        }
    }
    
    /**
     * Handle payment captured event.
     *
     * @param  array  $payload
     * @return void
     */
    protected function handlePaymentCaptured($payload)
    {
        // Implementation for payment captured event
    }
    
    /**
     * Handle payment failed event.
     *
     * @param  array  $payload
     * @return void
     */
    protected function handlePaymentFailed($payload)
    {
        // Implementation for payment failed event
    }
}
