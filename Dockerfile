FROM ubuntu:noble

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get -y install python3 python-is-python3 xvfb x11vnc xdotool wget tar supervisor net-tools fluxbox gnupg2 xz-utils && \
    echo 'echo -n $HOSTNAME' > /root/x11vnc_password.sh && chmod +x /root/x11vnc_password.sh && \
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    echo 'deb https://dl.winehq.org/wine-builds/ubuntu/ noble main' | tee /etc/apt/sources.list.d/winehq.list && \
    apt-get update && apt-get -y install winehq-stable
RUN mkdir -p /opt/wine-stable/share/wine/mono && wget -qO /tmp/wine-mono-10.0.0-x86.tar.xz https://dl.winehq.org/wine/wine-mono/10.0.0/wine-mono-10.0.0-x86.tar.xz && tar -xJvf /tmp/wine-mono-10.0.0-x86.tar.xz -C /opt/wine-stable/share/wine/mono && rm /tmp/wine-mono-10.0.0-x86.tar.xz

RUN mkdir /opt/wine-stable/share/wine/gecko && wget -qO /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi && wget -qO /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86_64.msi && \
    apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD supervisord-wine.conf /etc/supervisor/conf.d/supervisord-wine.conf

ENV WINEPREFIX /root/prefix32
ENV WINEARCH win32
ENV DISPLAY :0

WORKDIR /root/
RUN wget -O - https://github.com/novnc/noVNC/archive/v1.6.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.6.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html && \
    wget -O - https://github.com/novnc/websockify/archive/v0.13.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.13.0 /root/novnc/utils/websockify

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
