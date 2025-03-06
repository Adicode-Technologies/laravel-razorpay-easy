<?php

namespace YourName\LaravelRazorpayEasy;

use Illuminate\Support\ServiceProvider;
use YourName\LaravelRazorpayEasy\Commands\InstallRazorpayCommand;
use YourName\LaravelRazorpayEasy\Services\RazorpayService;

class RazorpayServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     */
    public function boot()
    {
        // Publish configuration
        $this->publishes([
            __DIR__.'/../config/razorpay.php' => config_path('razorpay.php'),
        ], 'razorpay-config');

        // Publish migrations
        $this->publishes([
            __DIR__.'/../database/migrations/' => database_path('migrations'),
        ], 'razorpay-migrations');

        // Publish views
        $this->publishes([
            __DIR__.'/../resources/views' => resource_path('views/vendor/razorpay'),
        ], 'razorpay-views');

        // Publish assets
        $this->publishes([
            __DIR__.'/../resources/js' => public_path('vendor/razorpay'),
        ], 'razorpay-assets');

        // Load routes
        $this->loadRoutesFrom(__DIR__.'/../routes/web.php');

        // Load views
        $this->loadViewsFrom(__DIR__.'/../resources/views', 'razorpay');

        // Register commands
        if ($this->app->runningInConsole()) {
            $this->commands([
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
        $this->mergeConfigFrom(__DIR__.'/../config/razorpay.php', 'razorpay');

        // Register the service
        $this->app->singleton('razorpay', function ($app) {
            return new RazorpayService(
                config('razorpay.key_id'),
                config('razorpay.key_secret')
            );
        });
    }
}
