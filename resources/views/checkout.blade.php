<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Razorpay Checkout</title>
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
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
        .button {
            background-color: {{ config('razorpay.checkout.theme_color', '#3399cc') }};
            color: white;
            border: none;
            padding: 12px 24px;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 20px;
        }
        .button:hover {
            opacity: 0.9;
        }
        .amount {
            font-size: 24px;
            font-weight: bold;
            margin: 20px 0;
        }
        .description {
            color: #6c757d;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Checkout</h1>
        <div class="description">{{ $checkoutData['description'] }}</div>
        <div class="amount">{{ $checkoutData['currency'] }} {{ number_format($checkoutData['amount'] / 100, 2) }}</div>
        <button id="rzp-button" class="button">Pay Now</button>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const options = @json($checkoutData);
            
            options.handler = function(response) {
                // Create a form to submit the payment details
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '{{ $callbackUrl }}';
                
                // Add CSRF token
                const csrfToken = document.createElement('input');
                csrfToken.type = 'hidden';
                csrfToken.name = '_token';
                csrfToken.value = '{{ csrf_token() }}';
                form.appendChild(csrfToken);
                
                // Add payment details
                for (const key in response) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = key;
                    input.value = response[key];
                    form.appendChild(input);
                }
                
                // Add description if available
                if (options.description) {
                    const input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = 'description';
                    input.value = options.description;
                    form.appendChild(input);
                }
                
                // Submit the form
                document.body.appendChild(form);
                form.submit();
            };
            
            const rzp = new Razorpay(options);
            
            document.getElementById('rzp-button').onclick = function(e) {
                rzp.open();
                e.preventDefault();
            };
        });
    </script>
</body>
</html>
