<?php

require 'verify_user.php';

// user data
$email = $_POST['email']
$password = $_POST['password']
$php_authentication_username = $_POST['PHPAuthenticationUsername']
$php_authentication_password = $_POST['PHPAuthenticationPassword']
$request_method = $_SERVER['REQUEST_METHOD']

// get and return json data if user is verified
$user_is_verified = verify_user($email, $password, $php_authentication_username, $php_authentication_password, $request_method)
if ($user_is_verified) {
    
    //check if user exists in database
    $query = 'SELECT * FROM appointments_appointment WHERE email = :email';
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(':email', $email);
    
}
    
?>

