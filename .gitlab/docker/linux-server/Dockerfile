# This builds a docker image to run a Godot linux server instance in

FROM ubuntu

ARG TYPE
ARG PLATFORM
ARG EXTENSION

ENV TYPE=$TYPE
ENV PLATFORM=$PLATFORM
ENV EXTENSION=$EXTENSION

COPY Scramble-${TYPE}-${PLATFORM}.${EXTENSION} Scramble-${TYPE}-${PLATFORM}.pck /app/

# Disable buffering so that Godot actually prints something here
ENTRYPOINT stdbuf -i 0 -o 0 -e 0 /app/Scramble-$TYPE-$PLATFORM.$EXTENSION

