<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Successful</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f8f9fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
            width: 100%;
            max-width: 500px;
            text-align: center;
        }
        .success-icon {
            color: #28a745;
            font-size: 64px;
            margin-bottom: 20px;
        }
        .button {
            background-color: {{ config('razorpay.checkout.theme_color', '#3399cc') }};
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 30px;
            text-decoration: none;
            display: inline-block;
        }
        .button:hover {
            opacity: 0.9;
        }
        .details {
            margin: 30px 0;
            text-align: left;
        }
        .details-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .details-label {
            color: #6c757d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="success-icon">✓</div>
        <h1>Payment Successful</h1>
        <p>Your payment has been processed successfully.</p>
        
        <div class="details">
            <div class="details-row">
                <span class="details-label">Payment ID:</span>
                <span>{{ $payment->payment_id }}</span>
            </div>
            <div class="details-row">
                <span class="details-label">Amount:</span>
                <span>{{ $payment->currency }} {{ number_format($payment->amount, 2) }}</span>
            </div>
            <div class="details-row">
                <span class="details-label">Date:</span>
                <span>{{ $payment->created_at->format('d M Y, h:i A') }}</span>
            </div>
            @if($payment->description)
            <div class="details-row">
                <span class="details-label">Description:</span>
                <span>{{ $payment->description }}</span>
            </div>
            @endif
        </div>
        
        <a href="{{ $redirectUrl }}" class="button">Continue</a>
    </div>
</body>
</html>
