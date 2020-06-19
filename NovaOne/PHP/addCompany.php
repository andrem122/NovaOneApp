<?php

    require 'utils.php';
    
    // user data
    $customer_user_id = $_POST['customerUserId'];
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // company POST data
    $company_name = $_POST['companyName'];
    $company_address = $_POST['companyAddress'];
    $company_city = $_POST['companyCity'];
    $company_state = $_POST['companyState'];
    $company_zip = $_POST['companyZip'];
    $company_phone_number = $_POST['companyPhoneNumber'];
    $company_email = $_POST['companyEmail'];
    $company_days_of_the_week_enabled = $_POST['daysOfTheWeekEnabled'];
    $company_hours_of_the_day_enabled = $_POST['hoursOfTheDayEnabled'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);

    $query = "
    INSERT INTO property_company (name, address, phone_number, email, days_of_the_week_enabled, hours_of_the_day_enabled, city, customer_user_id, state, zip, created) VALUES (:company_name, :company_address, :company_phone_number, :company_email, :company_days_of_the_week_enabled, :company_hours_of_the_day_enabled, :company_city, :customer_user_id, :company_state, :company_zip, NOW());
    ";
    
    // query the database and echo results
    $parameters = array(':company_name' => $company_name, ':company_address' => $company_address, ':company_phone_number' => $company_phone_number, ':company_email' => $company_email, ':company_days_of_the_week_enabled' => $company_days_of_the_week_enabled, ':company_hours_of_the_day_enabled' => $company_hours_of_the_day_enabled, ':company_city' => $company_city, ':customer_user_id' => $customer_user_id, ':company_state' => $company_state, ':company_zip' => $company_zip);
    query_db_login($query, $user_is_verified, $parameters, true);
    
?>



