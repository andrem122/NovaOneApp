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
    SELECT TO_CHAR(date_of_inquiry, 'Mon') AS \"month\",
    EXTRACT(YEAR FROM date_of_inquiry) AS \"year\",
    COUNT(id) AS \"count\"
    FROM leads_lead
    WHERE company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    AND date_of_inquiry > NOW() - INTERVAL '1 year'
    GROUP BY \"month\", \"year\";
    ";
    
    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id);
    query_db_login($query, $user_is_verified, $parameters);
?>






