<?php

    require 'utils.php';
    
    // user data
    $customer_user_id = $_POST['customerUserId'];
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);

    $query = "
    SELECT DATE(date_of_inquiry) AS \"date\", COUNT(*) AS \"count\"
    FROM leads_lead
    WHERE date_of_inquiry > NOW() - INTERVAL '7 days'
    AND company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    GROUP BY 1;
    ";
    
    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id);
    echo query_db_login($query, $user_is_verified, $parameters, false);
    
?>





