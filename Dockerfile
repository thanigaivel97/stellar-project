FROM alpine:latest
RUN apt-get update
# All compilation requirements above
RUN apt-get install -y git
RUN apt-get install clang-8 -y
RUN apt-get install software-properties-common -y 
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN apt-get update
RUN apt-get install git build-essential pkg-config autoconf automake libtool bison flex libpq-dev parallel -y
COPY . /usr/src
WORKDIR /usr/src
RUN git submodule init && git submodule update
RUN ./autogen.sh && ./configure
RUN make
FROM stellar/base:latest
COPY --from=builder /usr/src/src/stellar-core /usr/local/bin/stellar-core
MAINTAINER Mat Schaffer <mat@stellar.org>
ENV STELLAR_CORE_VERSION 15.0.0rc2-1379-8d6e6d74
EXPOSE 11625
EXPOSE 11626
VOLUME /data
VOLUME /postgresql-unix-sockets
VOLUME /heka
ADD docker/install /
RUN /install
ADD docker/heka /heka
ADD docker/confd /etc/confd
ADD docker/utils /utils
ADD docker/start /
CMD ["/start"]
