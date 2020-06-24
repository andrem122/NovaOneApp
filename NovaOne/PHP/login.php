<?php

require 'database.php';
require 'django_password.php';

//new users
if($_SERVER['REQUEST_METHOD'] === 'POST') {

  //check if POST request is from the app
  if(($_POST['PHPAuthenticationUsername'] === $GLOBALS['php_authentication_username'] && $_POST['PHPAuthenticationPassword'] === $GLOBALS['php_authentication_password']) && (!empty($_POST['PHPAuthenticationUsername']) && !empty($_POST['PHPAuthenticationPassword']))) {
  
	  //input check
	  if(empty($_POST['email']) || empty($_POST['password'])) {
	
	    //set a 400 (bad request) response code and exit.
	    http_response_code(400);
        $response_array = array('error' => 6, 'reason' => 'Oops! Please complete all fields and try again.');
        echo json_encode($response_array);
	    exit();
	
	  } else {
	      
	      //check if credentials are valid
          $email = $_POST['email'];
          $query = "
          SELECT
              c.id,
              c.user_id as \"userId\",
              a.password,
              a.last_login as \"lastLogin\",
              a.username,
              a.first_name as \"firstName\",
              a.last_name as \"lastName\",
              a.email,
              a.date_joined as \"dateJoined\",
              c.is_paying as \"isPaying\",
              c.wants_sms as \"wantsSms\",
              c.phone_number as \"phoneNumber\",
              c.customer_type as \"customerType\"
          FROM
              auth_user a
          INNER JOIN customer_register_customer_user c
              ON a.id = c.user_id
          WHERE a.email = :email";
          
          
          $db_object = new Database();
          $db = $db_object->connect();
          $stmt = $db->prepare($query);
	      $stmt->bindParam(':email', $email);
	      
	      
	      if($stmt->execute()) {
              
              // If we get a result from the database
	          if($stmt->rowCount() > 0) {
                  
                  // Make our result in a dictionary format
                  $stmt->setFetchMode(PDO::FETCH_ASSOC);
                  $result = $stmt->fetch();
                  
                // Get results of query and put them into JSON string for use by Swift if password is correct for given email
                if(django_verify_password($result['password'], $_POST['password'])) {
                    
                    echo json_encode($result);
                    http_response_code(200);
                    exit();
                    
                } else {
                    
                    http_response_code(400);
                    $response_array = array('error' => 1, 'reason' => 'Incorrect password. Please try again.');
                    echo json_encode($response_array);
                    exit();
                    
                }
	              
	          } else {
	              
                  // No result from database
	              http_response_code(400);
                  $response_array = array('error' => 2, 'reason' => 'Email was not found. Would you like to register?');
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
  
  } else {
      
  	//not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
	http_response_code(403);
    $response_array = array('error' => 4, 'reason' => 'Forbidden POST request');
    echo json_encode($response_array);
	exit();
      
  }

} else {
    
    //not a POST request. set a 403 (forbidden) response code.
    http_response_code(403);
    $response_array = array('error' => 5, 'reason' => 'Forbidden: Only POST requests allowed.');
    echo json_encode($response_array);

}
