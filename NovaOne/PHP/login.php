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
	    echo 'Oops! Please complete all fields and try again.';
	    exit();
	
	  } else {
	      
	      //check if credentials are valid
          $email = $_POST['email'];
          $query = "
          SELECT
              c.id,
              a.first_name AS firstName,
              a.last_name AS lastName,
              a.email,
              a.password,
              c.phone_number AS customerPhone,
              a.date_joined AS dateJoined,
              c.is_paying AS isPaying,
              c.wants_sms AS wantsSms,
              p.id AS propertyId,
              p.name AS propertyName,
              p.address AS propertyAddress,
              p.phone_number AS propertyPhone,
              p.email AS propertyEmail,
              p.days_of_the_week_enabled AS daysOfTheWeekEnabled,
              p.hours_of_the_day_enabled AS hoursOfTheDayEnabled
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
                          echo "RESULT";
                          echo $result;
		                  $user_info = array('id' => $result['id'], 'firstName' => $result['firstName'], 'lastName' => $result['lastName'], 'email' => $result['email'], 'customerPhone' => $result['customerPhone'], 'dateJoined' => $result['dateJoined'],
                              'isPaying' => $result['isPaying'], 'wantsSms' => $result['wantsSms'],
                              'propertyId' => $result['propertyId'], 'propertyName' => $result['propertyName'], 'propertyAddress' => $result['propertyAddress'],
                              'propertyPhone' => $result['propertyPhone'], 'propertyEmail' => $result['propertyEmail'], 'daysOfTheWeekEnabled' => $result['daysOfTheWeekEnabled'], 'hoursOfTheDayEnabled' => $result['hoursOfTheDayEnabled'],
                           );
		                  
		              
                          echo json_encode($user_info);
                          $db=null;
		                  exit();
		                  
		              } else {
		                  
		                  http_response_code(400);
		                  echo 'Incorrect password. Please try again.';
		                  exit();
		                  
		              }
	              
	              }
	              
	          } else {
	              
                  // No result from database
	              http_response_code(400);
	              echo 'Email was not found. Would you like to register?';
	              exit();
	              
	          }
	          
	      } else {
	          
	          http_response_code(500);
	          echo 'Statement could not be executed.';
	          exit();
	          
	      }
	  }
  
  } else {
      
  	//not a POST request from the NovaOne app. Set a 403 (forbidden) response code.
	http_response_code(403);
	die('login.php: Forbidden POST request');
      
  }

} else {
    
    //not a POST request. set a 403 (forbidden) response code.
    http_response_code(403);
    echo 'Forbidden: Only POST requests allowed.';

}
