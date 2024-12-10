#!/bin/sh

if [[ -n "$AIS_FILE" && -f "$AIS_FILE" ]]; then
    # File mode
    INPUT_SOURCE="cat $AIS_FILE"
elif [[ -n "$AIS_HOSTNAME" && -n "$AIS_PORT" ]]; then
     # Socket TCP mode
    INPUT_SOURCE="nc ${AIS_HOSTNAME} ${AIS_PORT}"
else
    # Standard input mode
    INPUT_SOURCE="cat"
fi

eval "$INPUT_SOURCE" | awk -F'!' '{

    # New file with only the current line tag blocks
    system("echo '' > /tagblocks/last")
    print $1 > "/tagblocks/last"

    # Remove tag blocks in the flow (small optimization)
    print " !"$2

}' | gpsdecode -j | {  while read -r json; do
        # We have a complete message (last part of a multi-part or single-part)

        if [ -n "$json" ]; then

            # We take the possible "c" tag block and convert it to ISO 8601 date
            tagblocks="$(cat ${AIS_TAGBLOCKS_DIR}/last)"
            c_property=$(echo $tagblocks | awk -F'[\\,:*]' '{
                for(i=0 ; i<=NF ; i++)
                    if($i ~ /^c/) {
                        print $(i+1)
                        exit
                    }
                    print ""
            }')
            timestamp=$([[ ! -z "${c_property}" ]] && date -d "@$(echo ${c_property})" '+%Y-%m-%dT%H:%M:%S%z')

            # Json completed with the timestamp if present
            echo "$json" | jq -c --unbuffered --arg timestamp "${timestamp}" 'if $timestamp != "" then . + {timestamp:  $timestamp} else . end'
        fi
    done
}