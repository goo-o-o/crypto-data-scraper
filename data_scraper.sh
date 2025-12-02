#!/bin/bash

MYSQL="sudo /usr/bin/mysql"
DB="crypto_prices"
MAX_RETRIES=5
COOLDOWN=10
# Create once only, outside loop as well
$MYSQL -e "CREATE DATABASE IF NOT EXISTS $DB; USE $DB";

# List what coins we want to track

COINS=("bitcoin" "ethereum")

for coin in "${COINS[@]}"; do
    # Separate log files would be neater
    LOGFILE="${coin}_scraper.log"
    TABLE="${coin}_prices"
    
    # Create table for each if not present
    $MYSQL $DB -e "CREATE TABLE IF NOT EXISTS $TABLE (
        id INT AUTO_INCREMENT PRIMARY KEY,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        current DECIMAL(15,2),
        high DECIMAL(15,2),
        low DECIMAL(15,2)
    );" >> "$LOGFILE" 2>&1
    
    URL="https://coinmarketcap.com/currencies/${coin}/"
    
    # Loop if needed (if failed)
    for attempt in $(seq 1 $MAX_RETRIES); do
        echo "$(date): [$coin] Attempt $attempt/$MAX_RETRIES" | tee -a "$LOGFILE"
        
        # Extract prices
        current_price=$(curl -s "$URL" | grep -oP 'data-test="text-cdp-price-display">\K\$[\d,]+(\.\d+)?' | sed 's/[$,]//g' | head -1)
        price_low=$(curl -s "$URL" | grep -oP 'Low</div><span>\K\$[\d,]+(\.\d+)?' | sed 's/[$,]//g')
        price_high=$(curl -s "$URL" | grep -oP 'High</div><span>\K\$[\d,]+(\.\d+)?' | sed 's/[$,]//g')
        
        if [ -n "$current_price" ] && [ -n "$price_low" ] && [ -n "$price_high" ]; then
            # Success, we insert and break
            $MYSQL $DB -e "INSERT INTO $TABLE (current, high, low) VALUES ($current_price, $price_high, $price_low);" >> "$LOGFILE" 2>&1
            
            echo "$(date): SUCCESS → $coin | Current: \$$current_price | High: \$$price_high | Low: \$$price_low" | tee -a "$LOGFILE"
            echo "=========================================================================" | tee -a "$LOGFILE"
            break
        else
            # Retry the curl if we fail to get it, in case internet out or server down, just to be more robust
            echo "$(date): Failed (attempt $attempt). Missing data. Retrying in ${SLEEP}s..." | tee -a "$LOGFILE"
            [ $attempt -lt $MAX_RETRIES ] && sleep $SLEEP
        fi
        
        # Final failure after all retries
        if [ $attempt -eq $MAX_RETRIES ]; then
            echo "$(date): FAILED after $MAX_RETRIES attempts for $coin" | tee -a "$LOGFILE"
        fi
    done
done