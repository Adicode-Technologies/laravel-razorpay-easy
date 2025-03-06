<?php

namespace AdicodeTechnologies\LaravelRazorpayEasy\Traits;

use AdicodeTechnologies\LaravelRazorpayEasy\Models\Payment;

trait HasRazorpayPayments
{
    /**
     * Get all payments for this model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\MorphMany
     */
    public function payments()
    {
        return $this->morphMany(Payment::class, 'payable');
    }

    /**
     * Get successful payments for this model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\MorphMany
     */
    public function successfulPayments()
    {
        return $this->payments()->where('status', 'captured');
    }

    /**
     * Create a new payment for this model.
     *
     * @param  float  $amount
     * @param  string|null  $currency
     * @param  array  $options
     * @return \Razorpay\Api\Order
     */
    public function createPayment($amount, $currency = null, $options = [])
    {
        $razorpay = app('razorpay');
        return $razorpay->createOrder($amount, $currency, $options);
    }

    /**
     * Get the total amount paid.
     *
     * @return float
     */
    public function totalPaid()
    {
        return $this->successfulPayments()->sum('amount');
    }
}
