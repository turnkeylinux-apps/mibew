#!/bin/bash -e

while getopts p: option
    do
        case "${option}"
        in
        p) PASSWORD=${OPTARG};;
    esac
done

WEBROOT=/var/www/mibew

/usr/bin/php -r '
require_once $argv[1] . "/libs/init.php";
$admin = operator_by_login("admin");
if (!$admin) {
    fwrite(STDERR, "Mibew admin operator was not found\n");
    exit(1);
}
$admin["vcpassword"] = calculate_password_hash("admin", $argv[2]);
update_operator($admin);
' "$WEBROOT" "$PASSWORD"
