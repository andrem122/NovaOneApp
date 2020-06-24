<?php

    require 'utils.php';

    // user data
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];

    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);
    
    // get customer POST data
    $customer_message = $_POST['customerMessage'];
    
    if ($user_is_verified == true) {
        $sent = mail("andre@novaonesoftware.com", "Support Needed From NovaOne App", $customer_message);
        
        $response_array = array('reason' => 'Failed to send message. Please try again.');
        if ($sent == true) {
            $response_array = array('successReason' => 'Message successfully sent.');
        }
        
        echo json_encode($response_array);
    }
    
?>
