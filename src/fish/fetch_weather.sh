#!/bin/bash

# Save location config
USE_HARDCODED=true
HARDCODED_LOCATION="Plymouth%20Massachusetts"  # ENCODED for URLs
WEATHER_FILE="/tmp/weather_data.json"

# Determine location
if [ "$USE_HARDCODED" = true ]; then
  LOCATION="$HARDCODED_LOCATION"
else
  LOCATION=$(curl -s https://ipinfo.io/loc || echo "auto")
fi

# Fetch and store weather data (imperial)
curl -s "https://wttr.in/${LOCATION}?format=j1&u" > "$WEATHER_FILE"
