<?php

namespace AdicodeTechnologies\LaravelRazorpayEasy\Events;

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
    public $paymentData;

    /**
     * Create a new event instance.
     *
     * @param  array  $paymentData
     * @return void
     */
    public function __construct(array $paymentData)
    {
        $this->paymentData = $paymentData;
    }
}
