FROM alpine

# Mode 1 : Standard input
# No ENV needed

# Mode 2 : TCP Socket
# Exemple : Norwegian Coastal Administration
# ENV AIS_HOSTNAME=153.44.253.27
# ENV AIS_PORT=5631
ENV AIS_HOSTNAME=
ENV AIS_PORT=

# Mode 3 : File
ENV AIS_FILE=

# Tag blocks directory (at run time, speedup with: "--mount type=tmpfs,destination=/tagblocks")
ENV AIS_TAGBLOCKS_DIR=/tagblocks

RUN apk add gpsd-clients jq &&\
  mkdir -p ${AIS_TAGBLOCKS_DIR}

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
