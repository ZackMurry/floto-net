FROM alpine:3.14

RUN apk install mosquitto-clients

# RUN apt-get update
# RUN apt-get install -y bash wget
# RUN wget https://github.com/hivemq/mqtt-cli/releases/download/v4.29.0/mqtt-cli-4.29.0.deb
# RUN apt-get install -y ./mqtt-cli-4.29.0.deb

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

CMD ['/bin/bash', './test_latency.sh']
