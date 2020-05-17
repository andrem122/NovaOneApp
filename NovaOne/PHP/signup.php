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
    $company_days_enabled = $_POST['companyDaysEnabled'];
    $company_hours_enabled = $_POST['companyHoursEnabled'];
    $company_city = $_POST['companyCity'];
    $company_state = $_POST['companyState'];
    $company_zip = $_POST['companyZip'];
    
    // app credentials
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    if($request_method === 'POST') {
        
        //check if POST request is from the app and authenticate the user before giving data
        if(($php_authentication_username_f === $GLOBALS['php_authentication_username'] && $php_authentication_password_f === $GLOBALS['php_authentication_password']) && (!!isset($php_authentication_username_f) && !!isset($php_authentication_password_f))) {
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
                  // check if user email exists in database before inserting
                  $db_object = new Database();
                  $db = $db_object->connect();
                  
                  $query = "SELECT id FROM auth_user WHERE email = :email;";
                  $stmt = $db->prepare($query);
                  $stmt->bindParam(':email', $email);
                  $stmt->execute();
                  
                  if($stmt->rowCount() > 0) {
                      http_response_code(500);
                      $response_array = array('error' => 3, 'reason' => 'Email already exists in the database. Please sign in or use a new email.');
                      echo json_encode($response_array);
                  } else {
                      // insert into auth_user table first
                      $encrypted_password = django_make_password($password);
                      $query = "
                      INSERT INTO auth_user
                      (password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined)
                      VALUES (:encrypted_password, NOW(), 'f', :username, :first_name, :last_name, :email, 'f', 't', NOW());
                      ";
                      
                      $stmt = $db->prepare($query);
                      
                      // bind variables to query placeholers
                      $stmt->bindParam(':encrypted_password', $encrypted_password);
                      $stmt->bindParam(':username', $username);
                      $stmt->bindParam(':email', $email);
                      $stmt->bindParam(':first_name', $first_name);
                      $stmt->bindParam(':last_name', $last_name);
                      
                      
                      if($stmt->execute()) {
                          
                          // Get user_id from auth_user table
                          $query = "SELECT id FROM auth_user WHERE email = :email;";
                          $stmt = $db->prepare($query);
                          $stmt->bindParam(':email', $email);
                          
                          if ($stmt->execute()) {
                              
                              if($stmt->rowCount() > 0) {
                                  $stmt->setFetchMode(PDO::FETCH_ASSOC);
                                  $result = $stmt->fetch();
                                  $user_id = $result['id'];
                                  
                                  // add user data to customer_register_customer_user table
                                  $query = "
                                  INSERT INTO customer_register_customer_user
                                  (is_paying, wants_sms, phone_number, customer_type, user_id)
                                  VALUES ('f', 'f', :phone_number, :customer_type, :user_id);
                                  ";
                                  
                                  $stmt = $db->prepare($query);
                                  $stmt->bindParam(':phone_number', $phone_number);
                                  $stmt->bindParam(':customer_type', $customer_type);
                                  $stmt->bindParam(':user_id', $user_id);
                                  
                                  if($stmt->execute()) {
                                      
                                      // Get customer_user_id from auth_user table
                                      $query = "SELECT id FROM customer_register_customer_user WHERE user_id = :user_id;";
                                      $stmt = $db->prepare($query);
                                      $stmt->bindParam(':user_id', $user_id);
                                      
                                      if($stmt->execute()) {
                                          
                                          if($stmt->rowCount() > 0) {
                                              $stmt->setFetchMode(PDO::FETCH_ASSOC);
                                              $result = $stmt->fetch();
                                              $customer_user_id = $result['id'];
                                              
                                              // add user data to property_company table
                                              $query = "
                                              INSERT INTO property_company
                                              (name, address, phone_number, email, created, days_of_the_week_enabled, hours_of_the_day_enabled, city, customer_user_id, state, zip)
                                              VALUES (:company_name, :company_address, :company_phone_number, :company_email, NOW(), :company_days_enabled, :company_hours_enabled, :company_city, :customer_user_id, :company_state, :company_zip);
                                              ";
                                              
                                              $stmt = $db->prepare($query);
                                              $stmt->bindParam(':company_name', $company_name);
                                              $stmt->bindParam(':company_address', $company_address);
                                              $stmt->bindParam(':company_phone_number', $company_phone_number);
                                              $stmt->bindParam(':company_email', $company_email);
                                              $stmt->bindParam(':company_days_enabled', $company_days_enabled);
                                              $stmt->bindParam(':company_hours_enabled', $company_hours_enabled);
                                              $stmt->bindParam(':company_city', $company_city);
                                              $stmt->bindParam(':customer_user_id', $customer_user_id);
                                              $stmt->bindParam(':company_state', $company_state);
                                              $stmt->bindParam(':company_zip', $company_zip);
                                              
                                              if($stmt->execute()) {
                                                  http_response_code(200);
                                                  $response_array = array('success' => 1, 'reason' => 'User and company successfully added to the database!');
                                                  echo json_encode($response_array);
                                              } else {
                                                  http_response_code(500);
                                                  $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for property_company table.');
                                                  echo json_encode($response_array);
                                                  exit();
                                              }
                                              
                                          } else {
                                              http_response_code(500);
                                              $response_array = array('error' => 3, 'reason' => 'Customer not found in customer_register_customer_user table.');
                                              echo json_encode($response_array);
                                          }
                                          
                                      } else {
                                          http_response_code(500);
                                          $response_array = array('error' => 3, 'reason' => 'SQL query for customer_user_id not could not be executed.');
                                          echo json_encode($response_array);
                                      }
                                      
                                  } else {
                                      http_response_code(500);
                                      $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for customer_register_customer_user table.');
                                      echo json_encode($response_array);
                                  }
                                  
                              } else {
                                  // No result from database
                                  http_response_code(400);
                                  $response_array = array('error' => 2, 'reason' => 'Email was not found in auth_user table.');
                                  echo json_encode($response_array);
                                  exit();
                              }
                              
                              
                          } else {
                              http_response_code(500);
                              $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for id selection from auth_user table.');
                              echo json_encode($response_array);
                          }
                          
                      } else {
                          http_response_code(500);
                          $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed for data insertion into auth_user table.');
                          echo json_encode($response_array);
                      }
                  }
              }
            
        } else {
            // not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
            http_response_code(403);
            $response_array = array('error' => 4, 'reason' => 'Forbidden POST request');
            echo json_encode($response_array);
        }
        
    } else {
        // not a POST request. set a 403 (forbidden) response code.
        http_response_code(403);
        $response_array = array('error' => 5, 'reason' => 'Forbidden: Only POST requests allowed.');
        echo json_encode($response_array);
    }
    
?>







