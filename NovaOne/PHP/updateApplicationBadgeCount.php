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
    $subtract_from_badge_count = $_POST['subtractFromBadgeCount'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);

    $query = "UPDATE customer_register_customer_user_push_notification_tokens SET application_badge_count = application_badge_count - :subtract_from_badge_count WHERE customer_user_id = :customer_user_id;";
    
    // query the database and echo results
    $parameters = array(':subtract_from_badge_count' => $subtract_from_badge_count, ':customer_user_id' => $customer_user_id);
    echo query_db_login($query, $user_is_verified, $parameters, true, NULL);
    
?>
