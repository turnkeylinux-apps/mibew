#!/bin/bash -e

while getopts p: option
    do
        case "${option}"
        in
        p) PASSWORD=${OPTARG};;
    esac
done

EDDIT_PASS="/var/www/mibew/eddit_pass.php"
cp /var/www/mibew/index.php  $EDDIT_PASS

PASS_CODE="\$admin = operator_by_login('admin');\$admin['vcpassword'] = calculate_password_hash('admin', '$PASSWORD');update_operator(\$admin);"
echo $PASS_CODE >> $EDDIT_PASS

/usr/bin/php $EDDIT_PASS
rm $EDDIT_PASS
