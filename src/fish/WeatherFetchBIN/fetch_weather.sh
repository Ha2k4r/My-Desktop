#!/bin/bash

# Save location config
USE_HARDCODED=false
HARDCODED_LOCATION="Plymouth+Massachusetts"  # Plain text only!
WEATHER_FILE="/tmp/weather_data.json"

# Reset any botched previous saved data
rm -f "$WEATHER_FILE"

# Determine location
if [ "$USE_HARDCODED" = true ]; then
  LOCATION="$HARDCODED_LOCATION"
else
  PublicIp= curl ifconfig.me
  LOCATION= ${PublicIp}
fi

# Fetch and store weather data (imperial)
curl -s "https://wttr.in/${LOCATION}?format=j1&u" > "$WEATHER_FILE"
