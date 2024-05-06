# Compile Image
FROM alpine:latest as nd-build

ARG COMMITTISH=HEAD

WORKDIR /home/netdisco

RUN apk add --no-cache \
      ca-certificates \
      curl \
      g++ \
      gcc \
      git \
      libc6-compat \
      musl-dev \
      musl-obstack-dev \
      make \
      net-snmp-perl \
      openssl-dev \
      perl-crypt-rijndael \
      perl-dbd-pg \
      perl-dev \
      perl-io-socket-ssl \
      perl-ldap \
      postgresql-client \
      tzdata \
      openssh-client \
      wget && \
      apk fix --no-cache perl perl-dev

RUN curl -sL -o /tmp/cpanm https://cpanmin.us/ && \
      chmod +x /tmp/cpanm && \
      PERL5LIB='.' /tmp/cpanm --quiet --notest --local-lib ./ \
      "https://github.com/netdisco/netdisco.git@${COMMITTISH}" \
      Dancer::Debug \
      URL::Encode \
      REST::Client

# REMCO
FROM golang:alpine3.19 as build-remco

RUN apk add --no-cache git make && \
      git clone https://github.com/HeavyHorst/remco && \
      cd remco && make 
# RUN apk add --no-cache git && \
#     go install github.com/HeavyHorst/remco/cmd/remco@latest

# Base image
FROM alpine:latest

RUN   apk add --no-cache \
      curl \
      libssl3 \
      libcrypto3 \
      libc6-compat \
      musl-dev \
      musl-obstack-dev \
      net-snmp-perl \
      expect \
      expect-dev \
      perl-crypt-rijndael \
      perl-dbd-pg \
      perl-io-socket-ssl \
      perl-ldap \
      perl-json \
      perl-lwp-protocol-https \
      perl-file-slurp \
      perl-regexp-common \
      perl-regexp-common-net-cidr \
      perl-regexp-ipv6 \
      perl-file-sharedir \
      postgresql-client \
      tzdata \
      shadow && \
      useradd -U -m -d /home/netdisco -s /bin/ash netdisco

USER netdisco:netdisco

COPY --chown=netdisco:netdisco --from=nd-build /home/netdisco /home/netdisco/
ADD --chown=netdisco:netdisco scripts /home/netdisco/bin

RUN chmod +x /home/netdisco/bin/*

RUN for tgt in bin environments nd-site-local logs; \
      do mkdir /home/netdisco/$tgt; done && \
      ln -s /dev/stdout /home/netdisco/logs/netdisco.log

# Get remco
COPY --from=build-remco /go/remco/bin/remco /bin/remco
ADD remco /etc/remco

WORKDIR /home/netdisco
ENV PATH "/home/netdisco/bin:$PATH"
ENV SHELL /bin/ash

ENTRYPOINT ["/bin/remco"]