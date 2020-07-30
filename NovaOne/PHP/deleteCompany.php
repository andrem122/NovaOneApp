<?php

    require 'utils.php';
    
    // user data
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // update POST data
    $column_name = $_POST['columnName'];
    $object_id = $_POST['objectId'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);
    
    // Delete all leads for the company
    $query_one = "DELETE FROM leads_lead WHERE company_id = :object_id;";
    
    // Delete all appointments for the company
    $query_two = "DELETE FROM appointments_appointment_medical WHERE appointment_base_ptr_id IN (SELECT id FROM appointments_appointment_base WHERE company_id = :object_id);";
    $query_three = "DELETE FROM appointments_appointment_real_estate WHERE appointment_base_ptr_id IN (SELECT id FROM appointments_appointment_base WHERE company_id = :object_id);";
    $query_four = "DELETE FROM appointments_appointment_base WHERE company_id = :object_id;";
    
    
    // Delete the company
    $query_five = "DELETE FROM property_company WHERE id = :object_id;";
    
    // Query the database and echo results
    $parameters = array(':object_id' => $object_id);
    query_db_login($query_one, $user_is_verified, $parameters, true, NULL);
    
    query_db_login($query_two, $user_is_verified, $parameters, true, function() use($query_four, $user_is_verified, $parameters) {
          query_db_login($query_four, $user_is_verified, $parameters, true, NULL);
    });
    query_db_login($query_three, $user_is_verified, $parameters, true, function() use($query_four, $user_is_verified, $parameters) {
          query_db_login($query_four, $user_is_verified, $parameters, true, NULL);
    });
    echo query_db_login($query_five, $user_is_verified, $parameters, true, NULL);
?>






