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



