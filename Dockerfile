FROM ubuntu:22.04

RUN apt update
RUN apt install -y bash wget
RUN wget https://github.com/hivemq/mqtt-cli/releases/download/v4.29.0/mqtt-cli-4.29.0.deb
RUN apt install -y ./mqtt-cli-4.29.0.deb

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

CMD ['/bin/bash', './test_latency.sh']
