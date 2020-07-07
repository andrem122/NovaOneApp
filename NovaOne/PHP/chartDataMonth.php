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
    SELECT d.date, count(a.id)
    FROM (SELECT TO_CHAR(DATE_TRUNC('day', (current_date - \"offs\")), 'YYYY-MM-DD') AS \"date\"
      FROM GENERATE_SERIES(0, 30, 1) AS \"offs\"
    ) d LEFT OUTER JOIN
    appointments_appointment_base a
    ON a.company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    AND d.date = TO_CHAR(DATE_TRUNC('day', a.created), 'YYYY-MM-DD')
    GROUP BY d.date
    ORDER BY d.date ASC;
    ";
    
    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id);
    echo query_db_login($query, $user_is_verified, $parameters, false);
    
?>
