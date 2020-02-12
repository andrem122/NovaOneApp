<?php

require 'db_connect.php';
require 'verify_user.php';

//new users
$email = $_POST['email']
$password = $_POST['password']
$php_authentication_username = $_POST['PHPAuthenticationUsername']
$php_authentication_password = $_POST['PHPAuthenticationPassword']
$request_method = $_SERVER['REQUEST_METHOD']

// get and return json data if user is verified
$user_is_verified = verify_user($email, $password, $php_authentication_username, $php_authentication_password, $request_method)
if ($user_is_verified) {
    
    
    
}
    
?>
