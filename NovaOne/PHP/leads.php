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
        l.id,
        l.name,
        l.phone_number as \"phoneNumber\",
        l.email,
        TO_CHAR(l.date_of_inquiry, 'YYYY-MM-DD HH24:MI:SS TZ') as \"dateOfInquiry\",
        l.renter_brand as \"renterBrand\",
        l.company_id as \"companyId\",
        TO_CHAR(l.sent_text_date, 'YYYY-MM-DD HH24:MI:SS TZ') as \"sentTextDate\",
        TO_CHAR(l.sent_email_date, 'YYYY-MM-DD HH24:MI:SS TZ') as \"sentEmailDate\",
        l.filled_out_form as \"filledOutForm\",
        l.made_appointment as \"madeAppointment\",
        co.name as \"companyName\"
    FROM
        leads_lead l
    INNER JOIN property_company co
        ON l.company_id = co.id
    WHERE l.company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    ORDER BY l.id DESC
    LIMIT 15;
    ";
    
    // query the database and echo results
    $parameters = array(':customer_user_id' => $customer_user_id);
    echo query_db_login($query, $user_is_verified, $parameters, false, NULL);
    
?>

