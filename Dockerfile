FROM centos
RUN yum -y install epel-release
RUN yum -y install git which gcc-c++ libtool make autoconf automake openssl-devel libevent-devel boost-devel libdb4-devel libdb4-cxx-devel python34
RUN git clone https://github.com/bitcoin/bitcoin.git
WORKDIR /bitcoin
RUN git checkout -b 0.16 origin/0.16
RUN ./autogen.sh && ./configure && make
RUN strip src/bitcoind

FROM alpine
COPY --from=0 /bitcoin/src/bitcoind /
COPY --from=0 /lib64 /lib64
VOLUME ["/bitcoin"]
CMD ["/bitcoind", "-data-dir=/bitcoin"]
