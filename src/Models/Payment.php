<?php

namespace YourName\LaravelRazorpayEasy\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
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
    protected $casts = [
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
        return $this->morphTo();
    }

    /**
     * Scope a query to only include successful payments.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeSuccessful($query)
    {
        return $query->where('status', 'captured');
    }

    /**
     * Scope a query to only include failed payments.
     *
     * @param  \Illuminate\Database\Eloquent\Builder  $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeFailed($query)
    {
        return $query->where('status', 'failed');
    }
}
