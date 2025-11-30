#!/bin/bash

LOGFILE="btc_scraper.log"
MYSQL="sudo /usr/bin/mysql"
DB="btc_prices"
URL='https://coinmarketcap.com/currencies/bitcoin/'

$MYSQL -e "CREATE DATABASE IF NOT EXISTS $DB; USE $DB" >> "$LOGFILE" 2>&1
$MYSQL $DB -e "CREATE TABLE IF NOT EXISTS prices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME,
    current DECIMAL(12,2),
    high DECIMAL(12,2),
    low DECIMAL(12,2)
);" >> "$LOGFILE" 2>&1


#get price using regex
price=$(curl -s "$URL" | grep -oE 'data-test="text-cdp-price-display">\$[0-9,]+(\.[0-9]+)?' | sed -E 's/.*data-test="text-cdp-price-display">//; s/[$,]//g')

pricelow=$(curl -s "$URL" | grep -oE 'eQBACe label">Low</div><span>\$[0-9,]+(\.[0-9]+)?' | sed -E 's#.QBACe label">Low</div><span>##; s/[$,]//g')
# pricelow="";

pricehigh=$(curl -s "$URL" | grep -oE 'eQBACe label">High</div><span>\$[0-9,]+(\.[0-9]+)?' | sed -E 's#.QBACe label">High</div><span>##; s/[$,]//g')
# pricehigh=""

SHOULD_EXIT=false
if [ -z "$price" ]; then
    echo "$(date): ERROR - price missing prices!" >> "$LOGFILE"
    SHOULD_EXIT=true;
fi

if [ -z "$pricelow" ]; then
    echo "$(date): ERROR - pricelow missing prices!" >> "$LOGFILE"
    SHOULD_EXIT=true;
fi

if [ -z "$pricehigh" ]; then
    echo "$(date): ERROR - pricehigh missing prices!" >> "$LOGFILE"
    SHOULD_EXIT=true;
fi

if [ "$SHOULD_EXIT" = true ]; then
    exit 1
fi



echo "Price current: $price"
echo "Price 24h low: $pricelow"
echo "Price 24h high: $pricehigh"

$MYSQL $DB -e "INSERT INTO prices (timestamp, current, high, low) VALUES (NOW(), $price, $pricehigh, $pricelow);" >> "$LOGFILE" 2>&1
$MYSQL $DB -e "SELECT * FROM prices ORDER BY timestamp DESC LIMIT 5;"