<?php
include 'settings.php';
require 'credentials.php';

// Create connection
    
class Database {
    
    private $db_username;
    private $db_password;
    private $db_name;
    private $db_host;
    private $db_port;
    private $db_uri;
    protected $db;
    
    public function __construct($db_type = 'pgsql') {
        
        if($db_type == 'pgsql') {
            $this->db_username = $GLOBALS['pg_db_username'];
            $this->db_password = $GLOBALS['pg_db_password'];
            $this->db_name = $GLOBALS['pg_db_name'];
            $this->db_host = $GLOBALS['pg_db_host'];
            $this->db_port = $GLOBALS['pg_db_port'];
            $this->db_uri = $GLOBALS['pg_db_uri'];
        } else {
            $this->db_username = $GLOBALS['mysql_db_username'];
            $this->db_password = $GLOBALS['mysql_db_password'];
            $this->db_name = $GLOBALS['mysql_db_name'];
            $this->db_host = $GLOBALS['mysql_db_host'];
            $this->db_port = $GLOBALS['mysql_db_port'];
            $this->db_uri = $GLOBALS['mysql_db_uri'];
        }
    }
    
    public function connect($db_type = 'pgsql') {
        
        // for MYSQL
        $charset_string = ";charset=UTF8;";
        
        // for PGSQL
        if ($db_type == 'pgsql') {
            $charset_string = "";
        }
        
        try {
            
            $connection_string = $db_type . ":host=" . $this->db_host . ";dbname=" . $this->db_name . ";password=" . $this->db_password . ";user=" . $this->db_username . ";port=" . $this->db_port . $charset_string;
            $this->db = new PDO($connection_string);
            $this->db->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
            return $this->db;
            
        } catch (PDOException $e) {
            
            // Print the error if we could not connect
            echo "Error!: " . $e->getMessage() . "<br/>";
            die();
            
        }
        
    }
    
}

?>
