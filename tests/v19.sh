#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
app_password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
base=https://localhost
operator_cookie=/tmp/tkl-mibew-operator.$$
visitor_cookie=/tmp/tkl-mibew-visitor.$$
page=/tmp/tkl-mibew-page.$$
headers=/tmp/tkl-mibew-headers.$$
response=/tmp/tkl-mibew-response.$$

cleanup() {
    rm -f -- "$operator_cookie" "$visitor_cookie" "$page" "$headers" "$response"
}
trap cleanup EXIT
trap 'status=$?; echo "Mibew acceptance failed at line $LINENO (status $status)" >&2; exit "$status"' ERR

systemctl --quiet is-active apache2.service mariadb.service postfix.service cron.service
systemctl --quiet is-enabled apache2.service mariadb.service postfix.service cron.service
apache2ctl -t
apache2ctl -M 2>/dev/null | grep -F ' rewrite_module ' >/dev/null
apache2ctl -M 2>/dev/null | grep -F ' ssl_module ' >/dev/null
test "$(tr -d '[:space:]' </var/www/mibew/VERSION.txt)" = Mibew/3.6.0

curl --insecure --fail --silent --show-error \
    --cookie "$operator_cookie" --cookie-jar "$operator_cookie" \
    "$base/operator/login" >"$page"
csrf_token=$(sed -n 's/.*name="csrf_token"[^>]*value="\([^"]*\)".*/\1/p' "$page" | head -n1)
test -n "$csrf_token"
curl --insecure --silent --show-error \
    --cookie "$operator_cookie" --cookie-jar "$operator_cookie" \
    --dump-header "$headers" --output "$page" \
    --data-urlencode "csrf_token=$csrf_token" \
    --data-urlencode 'login=admin' \
    --data-urlencode "password=$app_password" \
    --data-urlencode 'submit=Enter' \
    "$base/operator/login"
grep -q '^HTTP/.* 302' "$headers"
curl --insecure --fail --silent --show-error \
    --cookie "$operator_cookie" "$base/operator" >"$page"
grep -Fq 'Visitors' "$page"
grep -Fq '/operator/logout' "$page"

package=$(php -r '
$call = [
    "token" => "turnkey-v19",
    "functions" => [[
        "function" => "processLeaveMessage",
        "arguments" => [
            "references" => [], "return" => [], "groupId" => 0,
            "name" => "TurnKey Visitor", "info" => null,
            "email" => "visitor@example.invalid",
            "message" => "TurnKey v19 support request",
            "referrer" => "https://example.invalid/", "captcha" => "",
            "threadId" => null, "token" => null,
        ],
    ]],
];
echo json_encode(["signature" => "", "proto" => "1.0", "async" => true, "requests" => [$call]]);
')
curl --insecure --fail --silent --show-error \
    --cookie "$visitor_cookie" --cookie-jar "$visitor_cookie" \
    --data-urlencode "data=$package" "$base/thread/update" >"$response"
php -r '
$payload = json_decode(urldecode(file_get_contents($argv[1])), true);
if (!is_array($payload)) { exit(1); }
$functions = $payload["requests"][0]["functions"] ?? [];
foreach ($functions as $function) {
    if (($function["function"] ?? "") === "result"
        && ($function["arguments"]["errorCode"] ?? -1) === 0) { exit(0); }
}
exit(1);
' "$response"

thread_id=$(mariadb --batch --skip-column-names mibew --execute \
    "SELECT threadid FROM thread WHERE username='TurnKey Visitor' ORDER BY threadid DESC LIMIT 1")
test -n "$thread_id"
test "$(mariadb --batch --skip-column-names mibew --execute \
    "SELECT COUNT(*) FROM message WHERE threadid=$thread_id AND tmessage='TurnKey v19 support request'")" = 1
curl --insecure --fail --silent --show-error \
    --cookie "$operator_cookie" "$base/operator/history/thread/$thread_id" >"$page"
grep -Fq 'TurnKey Visitor' "$page"
grep -Fq 'TurnKey v19 support request' "$page"

password_hash=$(mariadb --batch --skip-column-names mibew --execute \
    "SELECT vcpassword FROM operator WHERE vclogin='admin'")
[[ $password_hash == '$2y$'* ]]
test "$(mariadb --batch --skip-column-names mibew --execute 'SHOW TABLES' | wc -l)" -ge 20

dpkg-query -W php8.4-cli php8.4-mysql php8.4-gd libapache2-mod-php8.4 mariadb-server \
    webmin-apache webmin-mysql >/dev/null
curl --insecure --fail --silent --show-error --head https://127.0.0.1:12321/ >/dev/null
ss -ltn | grep -Eq '127\.0\.0\.1:25[[:space:]]'

latest_tag=$(curl --fail --silent --show-error \
    https://api.github.com/repos/Mibew/mibew/releases/latest |
    sed -n 's/.*"tag_name": "\([^"]*\)".*/\1/p' | head -n1)
test "$latest_tag" = v3.6.0
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie PHP, MariaDB and Apache packages; official Mibew 3.6.0 release archive
installed_version=Mibew 3.6.0; PHP $(php -r 'echo PHP_VERSION;')
runtime_checks=normal init; Apache TLS; firstboot administrator web login; visitor support request through Mibew API; authenticated history read; MariaDB persistence; Webmin and local Postfix
updater_command=back up the database, configs/config.yml and files/avatar; replace application files from a reviewed official release; restore retained data; visit /update/ for database migrations
updater_result=official latest release endpoint returned $latest_tag
updater_channel=official Mibew releases and documented built-in database migration tool
integrity_evidence=build verifies the upstream-published Mibew 3.6.0 archive SHA-256 8dcba849dfefa323919331f322d5f84b8da8a140b818b85b8356657e90d0d4ba; Debian metadata is signed; no Bookworm source remained
EOF
