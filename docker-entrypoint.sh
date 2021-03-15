#!/bin/bash

if [ ! -d /var/www/html/polr ]; then
  echo >&2 "Polr not found in $PWD - copying now..."
  cd /var/www/html
  tar cf - --one-file-system -C /usr/src/polr . | tar xf -
fi

touch /var/www/html/storage/logs/lumen.log

chown -R www-data:www-data /var/www/html

INITIAL_USER_NAME=${INITIAL_USER_NAME:-demo}
INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD:-demo}
INITIAL_USER_EMAIL=${INITIAL_USER_EMAIL:-demo@test.local}

APP_KEY="${APP_KEY:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}"
APP_NAME="${APP_NAME:-Polr}"
APP_PROTOCOL="${APP_PROTOCOL:-http://}"
APP_ADDRESS="${APP_ADDRESS:-localhost}"
APP_STYLESHEET="${APP_STYLESHEET:-}"
POLR_GENERATED_AT="$(date)"

DB_CONNECTION="${DB_CONNECTION:-mysql}"
DB_HOST="${DB_HOST:-mysql}"
DB_PORT="${DB_PORT:-3306}"
DB_DATABASE="${DB_DATABASE:-polr}"
DB_USERNAME="${DB_USERNAME:-polr}"
DB_PASSWORD="${DB_PASSWORD:-polr}"

SETTING_PUBLIC_INTERFACE="${SETTING_PUBLIC_INTERFACE:-true}"
POLR_ALLOW_ACCT_CREATION="${POLR_ALLOW_ACCT_CREATION:-false}"
POLR_ACCT_ACTIVATION="${POLR_ACCT_ACTIVATION:-false}"
SETTING_SHORTEN_PERMISSION="${SETTING_SHORTEN_PERMISSION:-false}"
SETTING_INDEX_REDIRECT="${SETTING_INDEX_REDIRECT:-}"
SETTING_REDIRECT_404="${SETTING_REDIRECT_404:-false}"
SETTING_PASSWORD_RECOV="${SETTING_PASSWORD_RECOV:-false}"
SETTING_AUTO_API="${SETTING_AUTO_API:-false}"
SETTING_ANON_API="${SETTING_ANON_API:-false}"
SETTING_ANON_API_QUOTA="${SETTING_ANON_API_QUOTA:-}"
SETTING_PSEUDORANDOM_ENDING="${SETTING_PSEUDORANDOM_ENDING:-false}"
SETTING_ADV_ANALYTICS="${SETTING_ADV_ANALYTICS:-false}"
SETTING_RESTRICT_EMAIL_DOMAIN="${SETTING_RESTRICT_EMAIL_DOMAIN:-false}"
SETTING_ALLOWED_EMAIL_DOMAINS="${SETTING_ALLOWED_EMAIL_DOMAINS:-}"


MAIL_ENABLED="${MAIL_ENABLED:-false}"
MAIL_DRIVER="${MAIL_DRIVER:-smtp}"
MAIL_HOST="${MAIL_HOST:-}"
MAIL_PORT="${MAIL_PORT:-}"
MAIL_USERNAME="${MAIL_USERNAME:-}"
MAIL_PASSWORD="${MAIL_PASSWORD:-}"
MAIL_FROM_ADDRESS="${MAIL_FROM_ADDRESS:-}"
MAIL_FROM_NAME="${MAIL_FROM_NAME:-}"


CONFIG=$(cat /var/www/html/resources/views/env.blade.php)

CONFIG=$(echo "${CONFIG}" | sed "s/APP_KEY=.*/APP_KEY=${APP_KEY}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/APP_NAME=.*/APP_NAME=${APP_NAME}/g")
CONFIG=$(echo "${CONFIG}" | sed "s;APP_PROTOCOL=.*;APP_PROTOCOL=${APP_PROTOCOL};g")
CONFIG=$(echo "${CONFIG}" | sed "s/APP_ADDRESS=.*/APP_ADDRESS=${APP_ADDRESS}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/APP_STYLESHEET=.*/APP_STYLESHEET=${APP_STYLESHEET}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/POLR_GENERATED_AT=.*/POLR_GENERATED_AT=${POLR_GENERATED_AT}/g")


CONFIG=$(echo "${CONFIG}" | sed "s/DB_CONNECTION=.*/DB_CONNECTION=${DB_CONNECTION}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/DB_HOST=.*/DB_HOST=${DB_HOST}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/DB_PORT=.*/DB_PORT=${DB_PORT}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/DB_PASSWORD=.*/APP_KEY=${DB_PASSWORD}/g")

CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_PUBLIC_INTERFACE=.*/SETTING_PUBLIC_INTERFACE=${SETTING_PUBLIC_INTERFACE}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/POLR_ALLOW_ACCT_CREATION=.*/POLR_ALLOW_ACCT_CREATION=${POLR_ALLOW_ACCT_CREATION}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/POLR_ACCT_ACTIVATION=.*/POLR_ACCT_ACTIVATION=${POLR_ACCT_ACTIVATION}/g")

CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_SHORTEN_PERMISSION=.*/SETTING_SHORTEN_PERMISSION=${SETTING_SHORTEN_PERMISSION}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_INDEX_REDIRECT=.*/SETTING_INDEX_REDIRECT=${SETTING_INDEX_REDIRECT}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_REDIRECT_404=.*/SETTING_REDIRECT_404=${SETTING_REDIRECT_404}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_PASSWORD_RECOV=.*/SETTING_PASSWORD_RECOV=${SETTING_PASSWORD_RECOV}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_AUTO_API=.*/SETTING_AUTO_API=${SETTING_AUTO_API}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_ANON_API=.*/SETTING_ANON_API=${SETTING_ANON_API}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_ANON_API_QUOTA=.*/SETTING_ANON_API_QUOTA=${SETTING_ANON_API_QUOTA}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_PSEUDORANDOM_ENDING=.*/SETTING_PSEUDORANDOM_ENDING=${SETTING_PSEUDORANDOM_ENDING}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_ADV_ANALYTICS=.*/SETTING_ADV_ANALYTICS=${SETTING_ADV_ANALYTICS}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_RESTRICT_EMAIL_DOMAIN=.*/SETTING_RESTRICT_EMAIL_DOMAIN=${SETTING_RESTRICT_EMAIL_DOMAIN}/g")
CONFIG=$(echo "${CONFIG}" | sed "s/SETTING_ALLOWED_EMAIL_DOMAINS=.*/SETTING_ALLOWED_EMAIL_DOMAINS=${SETTING_ALLOWED_EMAIL_DOMAINS}/g")

CONFIG=$(echo "${CONFIG}" | sed "s/POLR_SETUP_RAN=.*/POLR_SETUP_RAN=true/g")
CONFIG=$(echo "${CONFIG}" | sed "s/POLR_BASE=.*/POLR_BASE=32/g")

if [[ "${MAIL_ENABLED}" != "true" ]]; then
  CONFIG=$(echo "${CONFIG}" | sed '/^@if($MAIL_ENABLED)/,/@endif/d' )
else
  CONFIG=$(echo "${CONFIG}" | sed 's/^@if($MAIL_ENABLED)//g')
  CONFIG=$(echo "${CONFIG}" | sed 's/^@endif//g')
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_DRIVER=.*/MAIL_DRIVER=${MAIL_DRIVER}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_HOST=.*/MAIL_HOST=${MAIL_HOST}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_PORT=.*/MAIL_PORT=${MAIL_PORT}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_USERNAME=.*/MAIL_USERNAME=${MAIL_USERNAME}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_PASSWORD=.*/MAIL_PASSWORD=${MAIL_PASSWORD}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_FROM_ADDRESS=.*/MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}/g")
  CONFIG=$(echo "${CONFIG}" | sed "s/MAIL_FROM_NAME=.*/MAIL_FROM_NAME=${MAIL_FROM_NAME}/g")
fi

echo "${CONFIG}" > /var/www/html/.env
echo "APP_LOG=errorlog" >> /var/www/html/.env

cd /var/www/html

count=0
while
  nc -vz -w3 ${DB_HOST} ${DB_PORT}
  ret=$?
  ((ret!=0))
do
  sleep 1;
  ((count++))
  if [ $count -ge 10 ]; then
    echo "Database is not reachable - exiting now"
    exit 666;
  fi
done

php artisan migrate --force
php artisan geoip:update

cp ./vendor/laravel/lumen-framework/config/mail.php ./config/mail.php


TERM=dumb DB_HOST=${DB_HOST} DB_PORT=${DB_PORT} DB_USERNAME=${DB_USERNAME} DB_PASSWORD=${DB_PASSWORD} DB_DATABASE=${DB_DATABASE} INITIAL_USER_NAME=${INITIAL_USER_NAME} INITIAL_USER_PASSWORD=${INITIAL_USER_PASSWORD} INITIAL_USER_EMAIL=${INITIAL_USER_EMAIL} php -- <<'EOPHP'
<?php
$stderr = fopen('php://stderr', 'w');

$host = getenv('DB_HOST');
$socket = getenv('DB_PORT');
$port = 0;
if (is_numeric($socket)) {
	$port = (int) $socket;
	$socket = null;
}
$user = getenv('DB_USERNAME');
$pass = getenv('DB_PASSWORD');
$dbName = getenv('DB_DATABASE');
$initalUserPassword = getenv('INITIAL_USER_PASSWORD');
$initalUserName = getenv('INITIAL_USER_NAME');
$initalUserEMail = getenv('INITIAL_USER_EMAIL');

$hashedInitialUserPassword  = password_hash($initalUserPassword, PASSWORD_BCRYPT, ['cost' => 10]);

$rand_bytes = random_bytes(50);
$recoveryKey = bin2hex($rand_bytes);


$maxTries = 10;
do {
	$mysql = new mysqli($host, $user, $pass, $dbName, $port, $socket);
	if ($mysql->connect_error) {
		fwrite($stderr, "\n" . 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
		--$maxTries;
		if ($maxTries <= 0) {
			exit(1);
		}
		sleep(3);
	}
} while ($mysql->connect_error);

$result = $mysql->query("SELECT count(*) FROM users WHERE role='admin'");
$row = $result->fetch_row();
$adminCount = $row[0];

$insertSql = <<<EOS
INSERT INTO users (username, password, email, ip, recovery_key, role, active, api_key, api_active)
VALUES('{$initalUserName}', '{$hashedInitialUserPassword}', '{$initalUserEMail}', '127.0.0.1', '{$recoveryKey}', 'admin', '1', false, 0)
EOS;

if ($adminCount < 1) {
  if (!$mysql->query($insertSql)) {
    fwrite($stderr, "User could not be created: {$mysql->error}\n");
  }
}


$mysql->close();
EOPHP


exec "$@"
