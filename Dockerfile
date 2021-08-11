FROM ubuntu:20.04

# ------------------------------------------------------
# --- Install required tools

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
RUN apt-get update -qq && \
    apt-get clean &&  \
    apt-get install -y cmake wget unzip openjdk-11-jdk python python3 curl sudo git && \
    apt-get clean -y 


ENV ANDROID_SDK_VERSION 7302050
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV ANDROID_SDK /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip &&      \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools &&      \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools &&      \
    rm *tools*linux*.zip


RUN yes | /opt/android-sdk/cmdline-tools/tools/bin/sdkmanager --licenses

RUN $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "tools" "platform-tools" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "build-tools;28.0.3" "build-tools;27.0.3" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "platforms;android-28" "platforms;android-27" "platforms;android-29" "platforms;android-30" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "cmake;3.10.2.4988404" && \
    $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "ndk;21.4.7075529" 

ENV ANDROID_NDK_HOME /opt/android-sdk/ndk/21.4.7075529/
ENV ANDROID_NDK $ANDROID_NDK_HOME


# ------------------------------------------------------
# --- Android NDK


# add to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}


# install gradle
ENV GRADLE_VERSION 6.9
ENV GRADLE_DIST bin
ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION}
ADD ./install_gradle.sh /opt/
RUN chmod +x /opt/install_gradle.sh && /opt/install_gradle.sh ${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin
