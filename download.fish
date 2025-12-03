#!/bin/env fish

echo "Please enter your session cookie:"
read --silent cookie

echo "Enter day number (1-12) or `all` for all days:"
read --prompt-str '> ' day_input

set numbers (seq 1 12)

if test -z $day_input
    exit
end

if test $day_input != all
    if contains $day_input (seq 1 12)
        set numbers $day_input
    else
        echo "Not a valid day (1-12) or `all`"

        exit
    end
end

for i in $numbers
    set num (printf "%02d\n" $i)
    set output_dir "src/day_$num"
    set download_url "https://adventofcode.com/2025/day/$i/input"

    echo "Now downloading `$download_url` to `$output_dir/input`"

    mkdir --parent $output_dir
    curl --no-progress-meter --header "Cookie: $cookie" -o "$output_dir/input" $download_url
end
