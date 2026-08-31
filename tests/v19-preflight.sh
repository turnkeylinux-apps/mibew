#!/bin/bash
set -Eeuo pipefail
trap 'status=$?; echo "Mibew preflight failed at line $LINENO (status $status)" >&2; exit "$status"' ERR

version=3.6.0
archive=/tmp/mibew-${version}.zip
webroot=/var/www/mibew

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2 libapache2-mod-php mariadb-server php-cli php-curl php-gd \
    php-mbstring php-mysql unzip curl ca-certificates

curl --fail --location --show-error \
    "https://download.mibew.org/mibew/core/${version}/mibew-${version}.zip" \
    --output "$archive"
echo "8dcba849dfefa323919331f322d5f84b8da8a140b818b85b8356657e90d0d4ba  $archive" |
    sha256sum --check --strict -
unzip -q "$archive" -d /var/www
test "$(tr -d '[:space:]' <"$webroot/VERSION.txt")" = "Mibew/$version"
thread_class="$webroot/libs/classes/Mibew/Thread.php"
test "$(grep -Fc "':group_id' => \$this->groupId," "$thread_class")" -eq 2
sed -i "s/':group_id' => \$this->groupId,/':group_id' => \$this->groupId ?: null,/" \
    "$thread_class"

cp "$webroot/configs/default_config.yml" "$webroot/configs/config.yml"
sed -i \
    -e '0,/host: ""/s//host: "localhost"/' \
    -e '0,/db: ""/s//db: "mibew"/' \
    -e '0,/login: ""/s//login: "mibew"/' \
    -e '0,/pass: ""/s//pass: "preflight-pass"/' \
    "$webroot/configs/config.yml"
chown -R root:root "$webroot"
chown -R www-data:www-data "$webroot/cache" "$webroot/files/avatar"
chown www-data:www-data "$webroot/configs/config.yml"
chmod 640 "$webroot/configs/config.yml"

service mariadb start
mariadb --execute \
    "CREATE DATABASE mibew CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
     CREATE USER 'mibew'@'localhost' IDENTIFIED BY 'preflight-pass';
     GRANT ALL PRIVILEGES ON mibew.* TO 'mibew'@'localhost';"
sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/mibew#' \
    /etc/apache2/sites-available/000-default.conf
echo '<Directory /var/www/mibew>
AllowOverride All
Require all granted
</Directory>' >/etc/apache2/conf-available/mibew.conf
a2enconf mibew
a2enmod rewrite
service apache2 start

cookie=/tmp/mibew-preflight-cookie
curl_cmd=(curl --fail --silent --show-error --cookie "$cookie" --cookie-jar "$cookie")
"${curl_cmd[@]}" http://127.0.0.1/install >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/check-requirements >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/check-connection >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/create-tables >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/set-password >/dev/null
"${curl_cmd[@]}" \
    --data 'password=turnkey-mibew-pass&password_confirm=turnkey-mibew-pass&submit=Save' \
    http://127.0.0.1/install/set-password >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/import-locales >/dev/null
"${curl_cmd[@]}" http://127.0.0.1/install/done >/dev/null

test "$(mariadb --batch --skip-column-names mibew --execute \
    "SELECT COUNT(*) FROM operator WHERE vclogin='admin'")" = 1
test "$(mariadb --batch --skip-column-names mibew --execute 'SHOW TABLES' | wc -l)" -ge 20
curl --fail --silent --show-error http://127.0.0.1/operator/login |
    grep -Fq 'Mibew Messenger'
