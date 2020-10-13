<?php

    require 'utils.php';
    
    // user data
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // POST data
    $columns = json_decode($_POST['columns'], true);
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);
    
    // get values from columns associative array
    $device_token = $columns['deviceToken'];
    $type = $columns['type'];
    $customer_user_id = $columns['customerUserId'];

    $query = "INSERT INTO customer_register_customer_user_push_notification_tokens (device_token, created, type, customer_user_id, new_lead_count, new_appointment_count, application_badge_count) VALUES (:device_token, NOW(), :type, :customer_user_id, 0, 0, 0);";
    
    // query the database and echo results
    $parameters = array(':device_token' => $device_token, ':type' => $type, ':customer_user_id' => $customer_user_id);
    echo query_db_login($query, $user_is_verified, $parameters, true, NULL);
    
?>

