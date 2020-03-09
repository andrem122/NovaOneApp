<?php

require 'verify_user.php';

// user data
$customer_user_id = $_POST['customerUserId'];
$email = $_POST['email'];
$password = $_POST['password'];
$php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
$php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
$request_method = $_SERVER['REQUEST_METHOD'];

// get and return json data if user is verified
$user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);
    
if ($user_is_verified) {
    
    // check if user exists in database
    $query = "
    SELECT
        p.id,
        p.name,
        p.address,
        p.phone_number as \"phoneNumber\",
        TO_CHAR(p.created, 'YYYY-MM-DD HH24:MI:SS TZ') as \"created\",
        p.days_of_the_week_enabled as \"daysOfTheWeekEnabled\",
        p.hours_of_the_day_enabled as \"hoursOfTheDayEnabled\"
    FROM
        property_property p
    INNER JOIN customer_register_customer_user c
        ON c.property_id = p.id
    WHERE c.id = :customer_user_id
    ORDER BY created DESC;
    ";
    
    $db_object = new Database();
    $db = $db_object->connect();
    $stmt = $db->prepare($query);
    $stmt->bindParam(':customer_user_id', $customer_user_id);
    
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
    
?>


