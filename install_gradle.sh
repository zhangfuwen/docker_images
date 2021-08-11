GRADLE_VERSION=$1

export GRADLE_DIST=bin
ZIP_FILE=gradle-${GRADLE_VERSION}-${GRADLE_DIST}.zip
cd /opt && \
    wget https://services.gradle.org/distributions/${ZIP_FILE} && \
    unzip $ZIP_FILE && \
    rm $ZIP_FILE 
