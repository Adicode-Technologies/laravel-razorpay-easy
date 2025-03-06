<?php

namespace YourName\LaravelRazorpayEasy\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\File;

class InstallRazorpayCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'razorpay:install';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Install the Razorpay package';

    /**
     * Execute the console command.
     *
     * @return void
     */
    public function handle()
    {
        $this->info('Installing Laravel Razorpay Easy...');

        // Publish configuration
        $this->callSilent('vendor:publish', [
            '--provider' => 'YourName\LaravelRazorpayEasy\RazorpayServiceProvider',
            '--tag' => 'razorpay-config',
        ]);

        $this->info('Published configuration');

        // Publish migrations
        $this->callSilent('vendor:publish', [
            '--provider' => 'YourName\LaravelRazorpayEasy\RazorpayServiceProvider',
            '--tag' => 'razorpay-migrations',
        ]);

        $this->info('Published migrations');

        // Run migrations
        if ($this->confirm('Would you like to run migrations now?', true)) {
            $this->call('migrate');
        }

        // Add environment variables
        $this->addEnvironmentVariables();

        $this->info('Razorpay integration installed successfully.');
        $this->info('Please set your Razorpay API keys in the .env file:');
        $this->info('RAZORPAY_KEY_ID=your_key_id');
        $this->info('RAZORPAY_KEY_SECRET=your_key_secret');
    }

    /**
     * Add environment variables to .env file.
     *
     * @return void
     */
    protected function addEnvironmentVariables()
    {
        $envPath = base_path('.env');
        
        if (File::exists($envPath)) {
            $content = File::get($envPath);
            
            if (!str_contains($content, 'RAZORPAY_KEY_ID')) {
                File::append($envPath, "\n# Razorpay Configuration\nRAZORPAY_KEY_ID=\nRAZORPAY_KEY_SECRET=\nRAZORPAY_WEBHOOK_SECRET=\n");
                $this->info('Added Razorpay environment variables to .env file');
            }
        }
    }
}
