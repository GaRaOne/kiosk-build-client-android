FROM ubuntu:trusty

ARG QT=5.7.0
ARG QTM=5.7

ENV DEBIAN_FRONTEND noninteractive
ENV QT_PATH /opt/qt
ENV QT_ANDROID ${QT_PATH}/${QTM}/android_armv7
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT ${ANDROID_HOME}
ENV ANDROID_NDK_ROOT /opt/android-ndk
ENV ANDROID_NDK_TOOLCHAIN_PREFIX arm-linux-androideabi
ENV ANDROID_NDK_TOOLCHAIN_VERSION 4.9
ENV ANDROID_NDK_HOST linux-x86_64
ENV ANDROID_NDK_PLATFORM android-21
ENV ANDROID_NDK_TOOLS_PREFIX ${ANDROID_NDK_TOOLCHAIN_PREFIX}
ENV QMAKESPEC android-g++
ENV PATH=${PATH}:${QT_ANDROID}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN sudo dpkg --add-architecture i386 && \
    apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        ant \
        build-essential \
        ca-certificates \
        curl \
        default-jdk \
        git \
        libavahi-common-dev \
        libavahi-client-dev \
        libc6:i386 \
        libfontconfig1 \
        libglu1-mesa-dev \
        libice6 \
        libncurses5:i386 \
        libsm6 \
        libstdc++6:i386 \
        libX11-xcb1 \
        libxext6 \
        libxrender1 \
        libz1:i386 \        
        mesa-common-dev \
        openssh-client \
        p7zip \
        xvfb \
    && apt-get clean

# download & install qt
ADD qt-installer-noninteractive.qs /tmp/qt/script.qs
ADD http://download.qt.io/official_releases/qt/${QTM}/${QT}/qt-opensource-linux-x64-android-${QT}.run /tmp/qt/installer.run

RUN chmod +x /tmp/qt/installer.run \
    && xvfb-run /tmp/qt/installer.run --script /tmp/qt/script.qs \
     | egrep -v '\[[0-9]+\] Warning: (Unsupported screen format)|((QPainter|QWidget))' \
    && rm -rf /tmp/qt

RUN echo /opt/qt/${QTM}/android_armv7/lib > /etc/ld.so.conf.d/qt-${QTM}.conf
RUN locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

# download & unpack android sdk
RUN mkdir /tmp/android \
    && curl -Lo /tmp/android/sdk.tgz 'http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz' \
    && tar --no-same-owner -xf /tmp/android/sdk.tgz -C /opt \
    && rm -rf /tmp/android \
    && echo "y" | android update sdk -u -a -t tools,platform-tools,build-tools-21.1.2,build-tools-23.0.3,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository,extra-google-play_apk_expansion,$ANDROID_NDK_PLATFORM

# download & unpack android ndk
RUN mkdir /tmp/android \
    && cd /tmp/android \
    && curl -Lo ndk.bin 'http://dl.google.com/android/ndk/android-ndk-r10e-linux-x86_64.bin' \
    && chmod +x ndk.bin \
    && ./ndk.bin > /dev/null \
    && mv android-ndk-r10e $ANDROID_NDK_ROOT \
    && chmod -R +rX $ANDROID_NDK_ROOT \
    && rm -rf /tmp/android

# CLEAN CACHE
RUN rm -rf /var/lib/apt/lists/*
