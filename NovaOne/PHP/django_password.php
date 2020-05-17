<?php
    
    // Makes password hash for django and verifies that password hashes are equal
    
    function django_make_password($password) {
        $algorithm = "pbkdf2_sha256";
        $iterations = 10000;

        $newSalt = random_bytes(6);
        $newSalt = base64_encode($newSalt);

        $hash = hash_pbkdf2("SHA256", $password, $newSalt, $iterations, 0, true);
        $toDBStr = $algorithm ."$". $iterations ."$". $newSalt ."$". base64_encode($hash);

        // This string is to be saved into DB, just like what Django generate.
        return $toDBStr;
    }
    
    function django_verify_password($dbString, $password) {
        $pieces = explode("$", $dbString);

        $iterations = $pieces[1];
        $salt = $pieces[2];
        $old_hash = $pieces[3];

        $hash = hash_pbkdf2("SHA256", $password, $salt, $iterations, 0, true);
        $hash = base64_encode($hash);

        if ($hash == $old_hash) {
           // login ok.
           return true;
        }
        else {
           //login fail
           return false;
        }
    }
    
?>
