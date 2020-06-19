<?php

    require 'utils.php';

    // user data
    $value_to_check_in_database = $_POST['valueToCheckInDatabase'];
    $table_name = $_POST['tableName'];
    $column_name = $_POST['columnName'];

    // app credentials
    $php_authentication_username_f = $_POST['PHPAuthenticationUsername'];
    $php_authentication_password_f = $_POST['PHPAuthenticationPassword'];
    $request_method = $_SERVER['REQUEST_METHOD'];
    
    $response_array = input_check($value_to_check_in_database, $table_name, $column_name, $request_method, $php_authentication_username_f, $php_authentication_password_f);
    
    echo json_encode($response_array);
?>
