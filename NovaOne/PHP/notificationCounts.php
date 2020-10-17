<?php

    require 'utils.php';
    
    // user data
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // POST data
    $customer_user_id = $_POST['customerUserId'];
    $device_token = $_POST['deviceToken'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);

    $query = "
        SELECT
        id,
        device_token as \"deviceToken\",
        created,
        type,
        customer_user_id as \"customerUserId\",
        application_badge_count as \"applicationBadgeCount\",
        new_appointment_count as \"newAppointmentCount\",
        new_lead_count as \"newLeadCount\"
    
        FROM customer_register_customer_user_push_notification_tokens
        WHERE customer_user_id = :customer_user_id
        AND device_token = :device_token;
    ";
    
    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id, ':device_token' => $device_token);
    echo query_db_login($query, $user_is_verified, $parameters, false, NULL);
    
?>
