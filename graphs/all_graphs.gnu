set terminal png size 900,600 enhanced font 'Arial,12'
set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%m-%d\n%H:%M"
set grid
set key top left box
set datafile separator "\t"

set output '1_eth_current.png'
set title 'Ethereum Current Price Over 1 Week'
plot 'eth.csv' using 1:2 with lines lw 2 lc rgb "blue" title 'Current Price'

set output '2_btc_current.png'
set title 'Bitcoin Current Price Over 1 Week'
plot 'btc.csv' using 1:2 with lines lw 2 lc rgb "orange" title 'Current Price'

set output '3_compare_current.png'
set title 'BTC vs ETH Current Price Comparison'
plot 'btc.csv' using 1:2 with lines lw 2 lc rgb "orange" title 'BTC', \
     'eth.csv' using 1:2 with lines lw 2 lc rgb "blue" title 'ETH'

set output '4_eth_range.png'
set title 'Ethereum 24h High and Low'
plot 'eth.csv' using 1:3 with lines lw 2 lc rgb "green" title '24h High', \
     '' using 1:4 with lines lw 2 lc rgb "red" title '24h Low'

set output '5_btc_range.png'
set title 'Bitcoin 24h High and Low'
plot 'btc.csv' using 1:3 with lines lw 2 lc rgb "green" title '24h High', \
     '' using 1:4 with lines lw 2 lc rgb "red" title '24h Low'

set output '6_eth_midrange.png'
set title 'Ethereum Mid-Range and Current Price'
plot 'eth.csv' using 1:($3+$4)/2 with lines lw 2 lc rgb "purple" title 'Mid (High+Low)/2', \
     '' using 1:2 with lines lw 2 lc rgb "blue" title 'Current'

set output '7_btc_midrange.png'
set title 'Bitcoin Mid-Range and Current Price'
plot 'btc.csv' using 1:($3+$4)/2 with lines lw 2 lc rgb "purple" title 'Mid (High+Low)/2', \
     '' using 1:2 with lines lw 2 lc rgb "orange" title 'Current'

set output '8_volatility.png'
set title '24h Price Volatility (High - Low)'
plot 'eth.csv' using 1:($3-$4) with lines lw 2 lc rgb "blue" title 'ETH Volatility', \
     'btc.csv' using 1:($3-$4) with lines lw 2 lc rgb "orange" title 'BTC Volatility'

set output '9_eth_all.png'
set title 'Ethereum: Current, 24h High & Low'
plot 'eth.csv' using 1:2 with lines lw 3 lc rgb "blue" title 'Current', \
     '' using 1:3 with lines lw 1.5 lc rgb "green" title '24h High', \
     '' using 1:4 with lines lw 1.5 lc rgb "red" title '24h Low'

set output '10_btc_all.png'
set title 'Bitcoin: Current, 24h High & Low'
plot 'btc.csv' using 1:2 with lines lw 3 lc rgb "orange" title 'Current', \
     '' using 1:3 with lines lw 1.5 lc rgb "green" title '24h High', \
     '' using 1:4 with lines lw 1.5 lc rgb "red" title '24h Low'