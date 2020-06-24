<?php

    require 'utils.php';
    
    // user data
    $email = $_POST['email'];
    $password = $_POST['password'];
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    // update POST data
    $table_name = $_POST['tableName'];
    $columns = json_decode($_POST['columns'], true);
    $object_id = $_POST['objectId'];
    
    // get and return json data if user is verified
    $user_is_verified = verify_user($email, $password, $php_authentication_username_f, $php_authentication_password_f, $request_method);
    
    // get values from columns associative array
    $first_name = $columns['first_name'];
    $last_name = $columns['last_name'];

    $query = "UPDATE " . $table_name . " SET first_name = :first_name, last_name = :last_name WHERE id = :object_id;";
    
    // query the database and echo results
    $parameters = array(':first_name' => $first_name, ':last_name' => $last_name, ':object_id' => $object_id);
    query_db_login($query, $user_is_verified, $parameters, true);
    
?>






