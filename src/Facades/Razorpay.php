<?php

namespace YourName\LaravelRazorpayEasy\Facades;

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
