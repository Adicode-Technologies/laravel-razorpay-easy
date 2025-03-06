<?php

namespace AdicodeTechnologies\LaravelRazorpayEasy\Events;

use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use AdicodeTechnologies\LaravelRazorpayEasy\Models\Payment;

class PaymentSucceeded
{
    use Dispatchable, SerializesModels;

    /**
     * The payment instance.
     *
     * @var $NAMESPACE\LaravelRazorpayEasy\Models\Payment
     */
    public $payment;

    /**
     * Create a new event instance.
     *
     * @param  $NAMESPACE\LaravelRazorpayEasy\Models\Payment  $payment
     * @return void
     */
    public function __construct(Payment $payment)
    {
        $this->payment = $payment;
    }
}
