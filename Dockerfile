FROM xjbcode/ci_docker_android_ndk:mybuntu_v6

# ------------------------------------------------------
# --- Install required tools

RUN apt-get update -qq
RUN apt-get install -y cmake wget unzip && apt-get clean


# ------------------------------------------------------
# --- Android NDK

# download
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION=r22
ADD install_ndk.sh /opt/
RUN chmod +x /opt/install_ndk.sh && /opt/install_ndk.sh ${ANDROID_NDK_HOME} ${ANDROID_NDK_VERSION}

ENV ANDROID_NDK ${ANDROID_NDK_HOME} 
ENV PATH ${PATH}:${ANDROID_NDK_HOME}:${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/

# add to PATH

# support multiarch: i386 architecture
# install Java
# install essential tools
# install Qt
ARG JDK_VERSION=17
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends libc6:i386 libstdc++6:i386 libgcc-s1:i386 libncurses6:i386 zlib1g:i386 && \
    apt-get install -y --no-install-recommends openjdk-${JDK_VERSION}-jdk && \
    apt-get install -y --no-install-recommends git wget unzip && \
    apt-get install -y --no-install-recommends qt5-default vim zsh

# download and install Gradle
# https://services.gradle.org/distributions/
ENV GRADLE_VERSION 8.2
ENV GRADLE_DIST bin
ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION}
ADD install_gradle.sh /opt/
RUN chmod +x /opt/install_gradle.sh && /opt/install_gradle.sh ${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin

# download and install Kotlin compiler
# https://github.com/JetBrains/kotlin/releases/latest
ARG KOTLIN_VERSION=1.5.0
RUN cd /opt && \
    wget -q https://github.com/JetBrains/kotlin/releases/download/v${KOTLIN_VERSION}/kotlin-compiler-${KOTLIN_VERSION}.zip && \
    unzip *kotlin*.zip && \
    rm *kotlin*.zip

# download and install Android SDK
# https://developer.android.com/studio#command-tools
ENV ANDROID_SDK_HOME /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_SDK /opt/android-sdk
ENV ANDROID_SDK_ROOT /opt/android-sdk
ARG ANDROID_SDK_VERSION=7302050
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip && \
    unzip *tools*linux*.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/tools && \
    rm *tools*linux*.zip

# set the environment variables
ENV JAVA_HOME /usr/lib/jvm/java-${JDK_VERSION}-openjdk-amd64
ENV KOTLIN_HOME /opt/kotlinc
ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator
ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
# WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
ENV LD_LIBRARY_PATH ${ANDROID_SDK_ROOT}/emulator/lib64:${ANDROID_SDK_ROOT}/emulator/lib64/qt/lib
# patch emulator issue: Running as root without --no-sandbox is not supported. See https://crbug.com/638180.
# https://doc.qt.io/qt-5/qtwebengine-platform-notes.html#sandboxing-support
ENV QTWEBENGINE_DISABLE_SANDBOX 1

# accept the license agreements of the SDK components
ADD license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_SDK_ROOT

# setup adb server
EXPOSE 5037

