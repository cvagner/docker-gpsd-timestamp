# gpsdecode with a timestamp from `c` tag block

[gpsdecode](https://gpsd.gitlab.io/gpsd/gpsdecode.html) is a utility that can decode GPS, RTCM or **AIS streams into a readable format**, in particular json.

⏰ **But it does not manage tag blocks** and in some cases, it is interesting to load the timestamps of certain messages that are only present in the tag blocks.

This project proposes a solution to load the timestamp obtained from the block `c` tag from AIS content, into a timestamp property in the `json` output.

😎 As a result, you can use `docker` to quickly get this **structured data with an ISO 8601 timestamp**:
```json
{"class":"AIS","device":"stdin","type":1,"repeat":0,"mmsi":219164000,"scaled":true,"status":0,"status_text":"Under way using engine","turn":0,"speed":10.0,"accuracy":false,"lon":10.825043,"lat":57.027050,"course":152.1,"heading":153,"second":28,"maneuver":0,"raim":false,"radio":49355,"timestamp":"2024-12-10T09:00:27+0000"}
```

Build docker image:
```sh
docker build . -t gpsd-timestamp
```

Some examples:
```sh
# Analyze a TCP socket (Norwegian Coastal Administration)
docker run -it --rm \
    --mount type=tmpfs,destination=/tagblocks \
    -e AIS_HOSTNAME="153.44.253.27" -e AIS_PORT=5631 \
    gpsd-timestamp

# File with bind mount
docker run -it --rm --entrypoint="" \
    --mount type=tmpfs,destination=/tagblocks \
    -v ${PWD}/data/norwegian.raw:/data.raw -e AIS_FILE=/data.raw \
    gpsd-timestamp

# Standard input from file
docker run -i --rm \
    --mount type=tmpfs,destination=/tagblocks \
    gpsd-timestamp < data/norwegian.raw

# Standard input from command's pipe, here a socket reading
nc 153.44.253.27 5631 | docker run -i --rm \
    --mount type=tmpfs,destination=/tagblocks \
    gpsd-timestamp

# Standard input from command's pipe, here reading from a tgz
# For memory, compression: tar --directory=data -cvzf data/norwegian.raw.tgz norwegian.raw
tar -xOzf data/norwegian.raw.tgz norwegian.raw | docker run -i --rm \
    --mount type=tmpfs,destination=/tagblocks \
    gpsd-timestamp
```

Note: at runtime, speed up with `--mount type=tmpfs,destination=/tagblocks`
