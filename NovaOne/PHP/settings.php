<?php

//start the session
if(!isset($_SESSION)) {
  session_start();
}

//timezone
date_default_timezone_set('America/New_York');

//error reporting
error_reporting(-1);
ini_set('display_errors', 'On');
set_error_handler("var_dump");

?>
