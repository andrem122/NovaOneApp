<?php

    require 'utils.php';
    
    // user data
    $customer_user_id = $_POST['customerUserId'];
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // lead POST data
    $lead_name = $_POST['leadName'];
    $lead_phone_number = get_parameter($_POST['leadPhoneNumber']);
    $lead_email = get_parameter($_POST['leadEmail']);
    $lead_renter_brand = get_parameter($_POST['leadRenterBrand']);
    $lead_company_id = $_POST['leadCompanyId'];
    $date_of_inquiry = $_POST['dateOfInquiry'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);

    $query = "
    INSERT INTO leads_lead (name, phone_number, email, renter_brand, date_of_inquiry, company_id, filled_out_form, made_appointment) VALUES (:lead_name, :lead_phone_number, :lead_email, :lead_renter_brand, :lead_date_of_inquiry, :lead_company_id, 'f', 'f');
    ";
    
    // query the database and echo results
    $parameters = array(':lead_name' => $lead_name, ':lead_phone_number' => $lead_phone_number, ':lead_email' => $lead_email, ':lead_renter_brand' => $lead_renter_brand, ':lead_date_of_inquiry' => $date_of_inquiry, ':lead_company_id' => $lead_company_id);
    query_db_login($query, $user_is_verified, $parameters, true);
    
?>


