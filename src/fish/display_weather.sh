#!/bin/bash

WEATHER_FILE="/tmp/weather_data.json"
[ ! -f "$WEATHER_FILE" ] && echo "No weather data. Run fetch_weather.sh first." && exit 1

# === Parse current conditions ===
cur_temp=$(jq -r '.current_condition[0].temp_F' "$WEATHER_FILE")
cur_desc=$(jq -r '.current_condition[0].weatherDesc[0].value' "$WEATHER_FILE" | sed -E 's/in nearby//g' | sed -E 's/shower//g' | sed -E 's/ +/ /g' | sed 's/ *$//')
wind_speed=$(jq -r '.current_condition[0].windspeedMiles' "$WEATHER_FILE")
city=$(jq -r '.nearest_area[0].areaName[0].value' "$WEATHER_FILE")
region=$(jq -r '.nearest_area[0].region[0].value' "$WEATHER_FILE")

# === Emergency checks ===
emergencies=$(jq -r '.weather[].hourly[].weatherDesc[0].value' "$WEATHER_FILE" |
  grep -iE 'evacuation|hurricane|flood warning|blizzard|tornado|ice storm|dust storm|danger' |
  sort -u)

# === Notable forecast days ===
declare -a bad_days
for i in 0 1 2; do
  date=$(date -d "+$i day" +%A)
  hourly=$(jq -c ".weather[$i].hourly[]" "$WEATHER_FILE")
  best_desc=""
  total_rain=0
  max_chance=0
  wind_alert=""
  significant=false

  while read -r block; do
    desc=$(echo "$block" | jq -r '.weatherDesc[0].value' | sed -E 's/in nearby//g' | sed -E 's/shower//g' | sed -E 's/ +/ /g' | sed 's/ *$//' | sed 's/Light rain/Light rain/gI')
    rain=$(echo "$block" | jq -r '.precipMM')
    chance=$(echo "$block" | jq -r '.chanceofrain')
    wind=$(echo "$block" | jq -r '.windspeedMiles')

    # Convert mm to inches
    rain_in=$(awk "BEGIN {printf \"%.2f\", $rain * 0.03937}")

    # Skip noise
    if echo "$desc" | grep -iqE 'partly cloudy|overcast|cloudy'; then
      if ! echo "$desc" | grep -iqE 'thunder|storm|rain|hail|snow'; then
        continue
      fi
    fi

    # Choose most relevant description
    if echo "$desc" | grep -iqE 'tornado|hurricane|blizzard|hail|thunder'; then
      best_desc="$desc"
      significant=true
      break
    elif echo "$desc" | grep -iqE 'rain|snow|storm'; then
      best_desc="$desc"
      significant=true
    fi

    # Rain summary
    (( $(echo "$chance > $max_chance" | bc -l) )) && max_chance=$chance
    total_rain=$(awk "BEGIN {print $total_rain + $rain_in}")

    # Wind alert
    if (( $(echo "$wind >= 25" | bc -l) )); then
      wind_alert="Wind: ${wind}mph"
      significant=true
    fi
  done <<< "$hourly"

  # Only add if important
  if [ "$significant" = true ]; then
    clean_desc=$(echo "$best_desc" | sed -E 's/ +/ /g' | sed 's/ *$//')
    report="$date: $clean_desc"
    if (( $(echo "$total_rain > 0.01" | bc -l) )); then
      report+=" | Amount: ${total_rain}in"
    fi
    if (( $(echo "$max_chance > 0" | bc -l) )); then
      report+=" | Chance: ${max_chance}%"
    fi
    if [ -n "$wind_alert" ]; then
      report+=" | $wind_alert"
    fi
    bad_days+=("$report")
  fi
done

# === Output ===
if [ -n "$emergencies" ]; then
  echo "🚨 EMERGENCY WEATHER ALERT for $region 🚨"
  echo "Now: $cur_desc, ${cur_temp}°F, Wind: ${wind_speed}mph"
  echo "Dangerous events in $city:"
  echo "$emergencies" | sed 's/^/  - /'
elif [ ${#bad_days[@]} -gt 0 ]; then
  command -v hyfetch >/dev/null && hyfetch
  echo "In: $region"
  echo "Now: $cur_desc, ${cur_temp}°F"
  echo "Weather Forecast:"
  for d in "${bad_days[@]}"; do
    # Don't repeat today if same as now
    if [[ "$d" == *"$(date +%A): $cur_desc"* ]]; then
      continue
    fi
    echo "  - $d"
  done
else
  command -v hyfetch >/dev/null && hyfetch
  echo "In: $region"
  echo "Now: $cur_desc, ${cur_temp}°F"
fi
