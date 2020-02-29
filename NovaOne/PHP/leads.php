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

// check if user exists in database
if ($user_is_verified) {
    
    $query = "
    SELECT
        l.id,
        l.name,
        l.phone,
        l.email,
        l.date_of_inquiry as \"dateOfInquiry\",
        l.renter_brand as \"renterBrand\",
        l.sent_text_date as \"sentTextDate\",
        l.sent_email_date as \"sentEmailDate\",
        l.filled_out_form as \"filledOutForm\",
        l.made_appointment as \"madeAppointment\",
        p.address
    FROM
        leads l
    INNER JOIN property p
        ON l.property_id = p.id
    WHERE p.customer_user_id = :customer_user_id
    ORDER BY time DESC
    LIMIT 10;
    ";
    
    $db_object = new Database('mysql');
    $db = $db_object->connect('mysql');
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

