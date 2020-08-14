<?php

    require 'utils.php';
    
    // user data
    $email = $_POST['email'];
    $username = $email;
    $password = $_POST['password'];
    $first_name = $_POST['firstName'];
    $last_name = $_POST['lastName'];
    $phone_number = $_POST['phoneNumber'];
    $customer_type = $_POST['customerType'];
    
    // company data
    $company_name = $_POST['companyName'];
    $company_address = $_POST['companyAddress'];
    $company_phone_number = $_POST['companyPhoneNumber'];
    $company_email = $_POST['companyEmail'];
    $company_allow_same_day_appointments = $_POST['companyAllowSameDayAppointments'];
    $company_days_enabled = $_POST['companyDaysEnabled'];
    $company_hours_enabled = $_POST['companyHoursEnabled'];
    $company_city = $_POST['companyCity'];
    $company_state = $_POST['companyState'];
    $company_zip = $_POST['companyZip'];
    
    // app credentials
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // script variables
    $response_array = array();
    
    // Connect to database
    $db_object = new Database();
    $db = $db_object->connect();
    
    if($request_method === 'POST') {
        
        //check if POST request is from the app and authenticate the user before giving data
        if($php_authentication_username_f === $GLOBALS['php_authentication_username'] && $php_authentication_password_f === $GLOBALS['php_authentication_password']) {
            // input check
            if(!isset($email) ||
                 !isset($password) ||
                 !isset($first_name) ||
                 !isset($last_name) ||
                 !isset($phone_number) ||
                 !isset($customer_type) ||
                 !isset($company_name) ||
                 !isset($company_address) ||
                 !isset($company_phone_number) ||
                 !isset($company_email) ||
                 !isset($company_allow_same_day_appointments) ||
                 !isset($company_days_enabled) ||
                 !isset($company_hours_enabled) ||
                 !isset($company_city) ||
                 !isset($company_state) ||
                 !isset($company_zip)) {
            
                // set a 400 (bad request) response code and exit.
                http_response_code(400);
                $response_array = array('error' => 6, 'reason' => 'Oops! Please complete all fields and try again.');
                echo json_encode($response_array);
            
              } else {
                  
                  // insert into auth_user table first
                  $query = "
                  INSERT INTO auth_user
                  (password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined)
                  VALUES (:encrypted_password, NOW(), 'f', :username, :first_name, :last_name, :email, 'f', 't', NOW());
                  ";
                  $encrypted_password = django_make_password($password);
                  $parameters = array(':encrypted_password' => $encrypted_password,
                                      ':username' => $username, ':email' => $email,
                                      ':first_name' => $first_name,
                                      ':last_name' => $last_name);
                  $stmt = query_db_signup($db, $query, $parameters);
                  
                  
                  if($stmt->rowCount() > 0) {
                      
                      // Get user_id from auth_user table
                      $query = "SELECT id FROM auth_user WHERE email = :email;";
                      $parameters = array(':email' => $email);
                      $stmt = query_db_signup($db, $query, $parameters);
                      
                      if ($stmt->rowCount() > 0) {
                          $stmt->setFetchMode(PDO::FETCH_ASSOC);
                          $result = $stmt->fetch();
                          $user_id = $result['id'];
                          
                          // add user data to customer_register_customer_user table
                          $query = "
                          INSERT INTO customer_register_customer_user
                          (is_paying, wants_sms, wants_email_notifications, phone_number, customer_type, user_id)
                          VALUES ('f', 't', 't', :phone_number, :customer_type, :user_id);
                          ";
                          
                          $parameters = array(':phone_number' => $phone_number,
                                              ':customer_type' => $customer_type,
                                              ':user_id' => $user_id);
                          $stmt = query_db_signup($db, $query, $parameters);
                          
                          if($stmt->rowCount() > 0) {
                              
                              // Get customer_user_id from auth_user table
                              $query = "SELECT id FROM customer_register_customer_user WHERE user_id = :user_id;";
                              $parameters = array(':user_id' => $user_id);
                              $stmt = query_db_signup($db, $query, $parameters);
                              
                              if($stmt->rowCount() > 0) {
                                  $stmt->setFetchMode(PDO::FETCH_ASSOC);
                                  $result = $stmt->fetch();
                                  $customer_user_id = $result['id'];
                                  
                                  // add user data to property_company table
                                  $query = "
                                  INSERT INTO property_company
                                  (name, address, phone_number, email, allow_same_day_appointments, created, days_of_the_week_enabled, hours_of_the_day_enabled, city, customer_user_id, state, zip)
                                  VALUES (:company_name, :company_address, :company_phone_number, :company_email, :company_allow_same_day_appointments, NOW(), :company_days_enabled, :company_hours_enabled, :company_city, :customer_user_id, :company_state, :company_zip);
                                  ";
                                  
                                  $parameters = array(':company_name' => $company_name,
                                                      ':company_address' => $company_address,
                                                      ':company_phone_number' => $company_phone_number,
                                                      ':company_email' => $company_email,
                                                      ':company_allow_same_day_appointments' => $company_allow_same_day_appointments,
                                                      ':company_days_enabled' => $company_days_enabled,
                                                      ':company_hours_enabled' => $company_hours_enabled,
                                                      ':company_city' => $company_city,
                                                      ':customer_user_id' => $customer_user_id,
                                                      ':company_state' => $company_state,
                                                      ':company_zip' => $company_zip);
                                  $stmt = query_db_signup($db, $query, $parameters);
                                  
                                  if($stmt->rowCount() > 0) {
                                      $query = "INSERT INTO auth_user_groups (user_id, group_id) VALUES (:user_id, 1);";
                                      $parameters = array(':user_id' => $user_id);
                                      $stmt = query_db_signup($db, $query, $parameters);
                                      
                                      if($stmt->rowCount() > 0) {
                                          http_response_code(200);
                                          $response_array = array('successReason' => 'User and company successfully added to the database!');
                                      }
                                      
                                  } else {
                                      http_response_code(500);
                                      $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for property_company table.');
                                  }
                                  
                              } else {
                                  http_response_code(500);
                                  $response_array = array('error' => 3, 'reason' => 'SQL query for customer_user_id not could not be executed.');
                              }
                              
                          } else {
                              http_response_code(500);
                              $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for customer_register_customer_user table.');
                          }
                      } else {
                          http_response_code(500);
                          $response_array = array('error' => 3, 'reason' => 'Could not select id from auth_user table.');
                      }
                      
                  } else {
                      http_response_code(500);
                      $response_array = array('error' => 3, 'reason' => 'SQL statement could not be executed for data insertion into auth_user table.');
                  }
              }
            
        } else {
            // not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
            http_response_code(403);
            $response_array = array('error' => 4, 'reason' => 'Forbidden POST request');
        }
        
    } else {
        // not a POST request. set a 403 (forbidden) response code.
        http_response_code(403);
        $response_array = array('error' => 5, 'reason' => 'Forbidden: Only POST requests allowed.');
    }
    
    echo json_encode($response_array);
    
?>







