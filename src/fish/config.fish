if status is-interactive
   bash display_weather.sh
   alias vim="nvim"
end

function fish_greeting

end

function fish_right_prompt
    set -l time (date +"%I:%M %p") # 12-hour format
    echo -n "$time" # Display the time
end

