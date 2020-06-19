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
    SELECT
        co.id,
        co.name,
        co.address,
        co.phone_number as \"phoneNumber\",
        co.auto_respond_number as \"autoRespondNumber\",
        co.auto_respond_text as \"autoRespondText\",
        co.email,
        TO_CHAR(co.created, 'YYYY-MM-DD HH24:MI:SS TZ') as \"created\",
        co.days_of_the_week_enabled as \"daysOfTheWeekEnabled\",
        co.hours_of_the_day_enabled as \"hoursOfTheDayEnabled\",
        co.city,
        co.customer_user_id as \"customerUserId\",
        co.state,
        co.zip
    FROM
        property_company co
    WHERE customer_user_id = :customer_user_id
    ORDER BY co.id DESC
    LIMIT 15;
    ";

    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id);
    query_db_login($query, $user_is_verified, $parameters, false);
    
    
?>


