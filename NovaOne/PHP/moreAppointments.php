
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
    a.id,
    a.name,
    a.phone_number as \"phoneNumber\",
    a.time,
    a.created,
    a.time_zone as \"timeZone\",
    a.confirmed,
    a.company_id as \"companyId\",
    a_re.unit_type as \"unitType\",
    a_m.email,
    a_m.date_of_birth as \"dateOfBirth\",
    a_m.test_type as \"testType\",
    a_m.gender as \"gender\",
    a_m.address


    FROM appointments_appointment_base a
    LEFT JOIN appointments_appointment_real_estate a_re
        ON a.id = a_re.appointment_base_ptr_id
    LEFT JOIN appointments_appointment_medical a_m
        ON a.id = a_m.appointment_base_ptr_id
    WHERE a.company_id IN (SELECT id FROM property_company WHERE customer_user_id = :customer_user_id)
    AND a.id < :last_object_id
    ORDER BY a.id DESC
    LIMIT 15;
    ";
    
    $parameters = array(':customer_user_id' => $customer_user_id, 'last_object_id' => $last_object_id);
    query_db_login($query, $user_is_verified, $parameters, false);
    
?>


