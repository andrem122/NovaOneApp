<?php

require 'db_connect.php';
require 'django_password.php';

//new users
if($_SERVER['REQUEST_METHOD'] === 'POST') {

  //check if POST request is from the app
  if(($_POST['PHPAuthenticationUsername'] === $php_authentication_username && $_POST['PHPAuthenticationPassword'] === $php_authentication_password) && (!empty($_POST['PHPAuthenticationUsername']) && !empty($_POST['PHPAuthenticationPassword']))) {
  
	  //input check
	  if(empty($_POST['email']) || empty($_POST['password'])) {
	
	    //set a 400 (bad request) response code and exit.
	    http_response_code(400);
        $response_array = array('error_number' => 6, 'reason' => 'Oops! Please complete all fields and try again.');
        echo json_encode($response_array);
	    exit();
	
	  } else {
	      
	      //check if credentials are valid
          $email = $_POST['email'];
          $query = "
          SELECT
              c.id,
              a.first_name,
              a.last_name,
              a.email,
              a.password,
              c.phone_number,
              a.date_joined,
              c.is_paying,
              c.wants_sms,
              p.id property_id,
              p.name property_name,
              p.address property_address,
              p.phone_number property_phone,
              p.email property_email,
              p.days_of_the_week_enabled,
              p.hours_of_the_day_enabled
          FROM
              auth_user a
          INNER JOIN customer_register_customer_user c
              ON a.id = c.user_id
          INNER JOIN property_property p
              ON c.property_id = p.id
          WHERE a.email = :email";
          
          $stmt = $db->prepare($query);
	      $stmt->bindParam(':email', $email);
	      
	      
	      if($stmt->execute()) {
              
              // If we get a result from the database
	          if($stmt->rowCount() > 0) {
                  
                  // Make our result in a dictionary format
	              $stmt->setFetchMode(PDO::FETCH_ASSOC);
                  
	              while($result = $stmt->fetch()) {
	              	      
		              // Get results of query and put them into JSON string for use by Swift if password is correct for given email
		              if(django_verify_password($result['password'], $_POST['password'])) {
		                  
		                  http_response_code(200);
		                  $response_array = array('id' => $result['id'], 'firstName' => $result['first_name'], 'lastName' => $result['last_name'], 'email' => $result['email'], 'customerPhone' => $result['phone_number'], 'dateJoined' => $result['date_joined'],
                              'isPaying' => $result['is_paying'], 'wantsSms' => $result['wants_sms'],
                              'propertyId' => $result['property_id'], 'propertyName' => $result['property_name'], 'propertyAddress' => $result['property_address'],
                              'propertyPhone' => $result['property_phone'], 'propertyEmail' => $result['property_email'], 'daysOfTheWeekEnabled' => $result['days_of_the_week_enabled'], 'hoursOfTheDayEnabled' => $result['hours_of_the_day_enabled'],
                          );
    
                          echo json_encode($response_array);
                          $db=null;
		                  exit();
		                  
		              } else {
		                  
		                  http_response_code(400);
                          $response_array = array('error_number' => 1, 'reason' => 'Incorrect password. Please try again.');
		                  echo json_encode($response_array);
		                  exit();
		                  
		              }
	              
	              }
	              
	          } else {
	              
                  // No result from database
	              http_response_code(400);
                  $response_array = array('error_number' => 2, 'reason' => 'Email was not found. Would you like to register?');
                  echo json_encode($response_array);
	              exit();
	              
	          }
	          
	      } else {
	          
	          http_response_code(500);
              $response_array = array('error_number' => 3, 'reason' => 'SQL Statement could not be executed.');
              echo json_encode($response_array);
	          exit();
	          
	      }
	  }
  
  } else {
      
  	//not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
	http_response_code(403);
    $response_array = array('error_number' => 4, 'reason' => 'Forbidden POST request');
    echo json_encode($response_array);
	exit();
      
  }

} else {
    
    //not a POST request. set a 403 (forbidden) response code.
    http_response_code(403);
    $response_array = array('error_number' => 5, 'reason' => 'Forbidden: Only POST requests allowed.');
    echo json_encode($response_array);

}
