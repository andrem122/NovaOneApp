<?php

    require 'utils.php';
    
    // user data
    $customer_user_id = $_POST['customerUserId'];
    $last_object_id = $_POST['lastObjectId'];
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
        l.date_of_inquiry as \"dateOfInquiry\",
        l.renter_brand as \"renterBrand\",
        l.company_id as \"companyId\",
        l.sent_text_date as \"sentTextDate\",
        l.sent_email_date as \"sentEmailDate\",
        l.filled_out_form as \"filledOutForm\",
        l.made_appointment as \"madeAppointment\",
        co.name as \"companyName\"
    FROM
        leads_lead l
    INNER JOIN property_company co
        ON l.company_id = co.id
    WHERE l.company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    AND l.id < :last_object_id
    ORDER BY l.id DESC
    LIMIT 15;
    ";
    
    // query the database and echo results
    query_db_login($query, $user_is_verified, $customer_user_id, '', $last_object_id);
    
?>


