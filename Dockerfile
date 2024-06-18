FROM ubuntu:22.04

RUN wget https://github.com/hivemq/mqtt-cli/releases/download/v4.29.0/mqtt-cli-4.29.0.deb
RUN apt install ./mqtt-cli-4.29.0.deb
