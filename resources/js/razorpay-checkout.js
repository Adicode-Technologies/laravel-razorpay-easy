/**
 * Razorpay Checkout Helper
 * 
 * This script provides helper functions for working with Razorpay checkout.
 */

/**
 * Initialize Razorpay checkout with the given options
 * 
 * @param {Object} options - Razorpay options
 * @param {Function} successCallback - Callback function on successful payment
 * @param {Function} errorCallback - Callback function on payment error
 * @returns {Object} - Razorpay instance
 */
function initRazorpayCheckout(options, successCallback, errorCallback) {
    // Set default handlers if not provided
    options.handler = options.handler || function(response) {
        if (typeof successCallback === 'function') {
            successCallback(response);
        }
    };

    options.modal = options.modal || {};
    options.modal.ondismiss = options.modal.ondismiss || function() {
        if (typeof errorCallback === 'function') {
            errorCallback({ error: 'Payment cancelled by user' });
        }
    };

    // Create Razorpay instance
    const rzp = new Razorpay(options);

    // Handle payment errors
    rzp.on('payment.failed', function(response) {
        if (typeof errorCallback === 'function') {
            errorCallback(response.error);
        }
    });

    return rzp;
}

/**
 * Open Razorpay checkout
 * 
 * @param {Object} options - Razorpay options
 * @param {Function} successCallback - Callback function on successful payment
 * @param {Function} errorCallback - Callback function on payment error
 */
function openRazorpayCheckout(options, successCallback, errorCallback) {
    const rzp = initRazorpayCheckout(options, successCallback, errorCallback);
    rzp.open();
}
