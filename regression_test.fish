#!/bin/env fish

set passed 0
set total 0

for out in src/day_*/output
    set day (string match -r 'day_[0-9]+' $out)
    set total (math $total+1)

    echo "Now testing $day..."
    if diff (zig build run-$day 2> /dev/null | psub) $out
        echo "> Passed!"

        set passed (math $passed+1)
    end
end

echo -e "===\nResults: $passed / $total passed"

if test $passed -ne $total
    exit 1
end
