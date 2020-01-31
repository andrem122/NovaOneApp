<?php
include 'settings.php';
require 'credentials.php';

// Create connection
try {
    $connection_string = "pgsql:host=$db_host;dbname=$db_name;password=$db_password;user=$db_username;port=$db_port";
    $db = new PDO($connection_string);
    $db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
} catch (PDOException $e) {
    
    // Print the error if we could not connect
    echo "Error!: " . $e->getMessage() . "<br/>";
    die();
    
}

?>
