<?php
    
    require 'database.php';
    require 'django_password.php';
    
    function verify_user($email,
                             $password,
                             $php_authentication_username_f,
                             $php_authentication_password_f,
                             $request_method) {
        
        //new users
        if($request_method === 'POST') {

          //check if POST request is from the app and authenticate the user before giving data
          if(($php_authentication_username_f === $GLOBALS['php_authentication_username'] && $php_authentication_password_f === $GLOBALS['php_authentication_password']) && (!empty($php_authentication_username_f) && !empty($php_authentication_password_f))) {
          
              // input check
              if(empty($email) || empty($password)) {
            
                //set a 400 (bad request) response code and exit.
                http_response_code(400);
                $response_array = array('error' => 6, 'reason' => 'Oops! Please complete all fields and try again.');
                return false;
            
              } else {
                  
                  //check if user exists in database
                  $query = 'SELECT * FROM auth_user WHERE email = :email';
                  
                  $db_object = new Database();
                  $db = $db_object->connect();
                  $stmt = $db->prepare($query);
                  $stmt->bindParam(':email', $email);
                  
                  
                  if($stmt->execute()) {
                      
                      // If we get a result from the database
                      if($stmt->rowCount() > 0) {
                          
                          // Make our result in a dictionary format
                          $stmt->setFetchMode(PDO::FETCH_ASSOC);
                          
                          while($result = $stmt->fetch()) {
                                    
                              // Get results of query and put them into JSON string for use by Swift if password is correct for given email
                              if(django_verify_password($result['password'], $password)) {
                                  
                                  http_response_code(200);
                                  return true;
                                  exit();
                                  
                              } else {
                                  
                                  http_response_code(400);
                                  $response_array = array('error' => 1, 'reason' => 'Incorrect password. Please try again.');
                                  return false;
                                  
                              }
                          
                          }
                          
                      } else {
                          
                          // No result from database for user email
                          http_response_code(400);
                          $response_array = array('error' => 2, 'reason' => 'Email was not found. Would you like to register?');
                          return false;
                          
                      }
                      
                  } else {
                      
                      http_response_code(500);
                      $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed.');
                      return false;
                      
                  }
              }
          
          } else {
              
            // not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
            http_response_code(403);
            $response_array = array('error' => 4, 'reason' => 'Forbidden POST request');
            return false;
              
          }

        } else {
            
            // not a POST request. set a 403 (forbidden) response code.
            http_response_code(403);
            $response_array = array('error' => 5, 'reason' => 'Forbidden: Only POST requests allowed.');
            return false;

        }
        
    }
    
    function query_db_login($query, $user_is_verified, $customer_user_id, $first_object_id, $last_object_id) {
        if ($user_is_verified) {
            // queries the database for the users who are logged in
            $db_object = new Database();
            $db = $db_object->connect();
            $stmt = $db->prepare($query);
            
            // bind parameters
            $stmt->bindParam(':customer_user_id', $customer_user_id);
            
            if(!empty($first_object_id)) {
                $stmt->bindParam(':first_object_id', $first_object_id);
            }
            
            if (!empty($last_object_id)) {
                $stmt->bindParam(':last_object_id', $last_object_id);
            }
            
            if ($stmt->execute()) {
                
                // If we get a result from the database
                if($stmt->rowCount() > 0) {
                    
                    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    echo json_encode($result);
                    exit();
                    
                } else {
                    
                    // No result from database
                    http_response_code(400);
                    $response_array = array('error' => 2, 'reason' => 'No rows matching the query were found.');
                    echo json_encode($response_array);
                    exit();
                    
                }
                
            } else {
                
                http_response_code(500);
                $response_array = array('error' => 3, 'reason' => 'SQL Statement could not be executed.');
                echo json_encode($response_array);
                exit();
                
            }
            
        }
    }
    
    function query_db_signup($query, $parameters = array('' => '')) {
        
        // queries the database for the signup process
        $db_object = new Database();
        $db = $db_object->connect();
        $stmt = $db->prepare($query);
        
        // bind parameters
        foreach ($parameters as $parameter_key => $parameter_value) {
            $stmt->bindParam($parameter_key, $parameter_value);
        }
        
        if ($stmt->execute()) {
            return $stmt;
        } else {
            http_response_code(500);
            echo $stmt->errorInfo();
        }
        
    }
    
    function signup_input_check($value_to_check_in_database, $table_name, $column_name, $request_method, $php_authentication_username_f, $php_authentication_password_f) {
        // checks the input of a field for an existing value in the database
        
        // function variables
        $response_array = array();
        $column_name_formatted = ucfirst(str_replace("_"," ", $column_name));
        
        if($request_method === 'POST') {
            
            if($php_authentication_username_f === $GLOBALS['php_authentication_username'] && $php_authentication_password_f === $GLOBALS['php_authentication_password']) {
                
                if(!isset($value_to_check_in_database)) {
                    // set a 400 (bad request) response code and exit.
                    http_response_code(400);
                    $response_array = array('error' => 6, 'reason' => 'Oops! Please complete all fields and try again.');
                } else {
                    $parameter = ':' . $column_name;
                    $query = 'SELECT * FROM ' . $table_name . ' WHERE ' . $column_name . ' = ' . $parameter;
                    $parameters = array($parameter => $value_to_check_in_database);
                    $stmt = query_db_signup($query, $parameters);
                    
                    if ($stmt->rowCount() > 0) {
                        $response_array = array('error' => 8, 'reason' => $column_name_formatted . ' has already been registered. Please use a different ' . strtolower($column_name_formatted) . '.');
                    } else {
                        $response_array = array('success' => 2, 'reason' => $column_name_formatted . ' not found in database.');
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
        
        return $response_array;
    }

