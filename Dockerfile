# syntax=docker/dockerfile:1

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root/cups

RUN apt-get update -y && apt-get upgrade --fix-missing -y && \
    apt-get install -y autoconf build-essential \
    avahi-daemon libavahi-client-dev \
    libssl-dev libkrb5-dev libnss-mdns libpam-dev \
    libsystemd-dev libusb-1.0-0-dev zlib1g-dev \
    openssl sudo git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/OpenPrinting/cups.git .

RUN ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var && \
    make clean && make && make install

RUN groupadd lpadmin && \
    useradd -G sudo,lpadmin -m -d /home/admin -s /bin/bash admin && \
    echo "admin:admin" | chpasswd

RUN sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf

EXPOSE 631

CMD ["/usr/sbin/cupsd", "-f"]