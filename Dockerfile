FROM gcr.io/jenkinsxio/builder-base:0.0.72

# Set directory for BDD tests
WORKDIR /home/bdd

# Install Firefox 70.0.1
RUN curl -sL http://ftp.mozilla.org/pub/firefox/releases/70.0.1/linux-x86_64/en-US/firefox-70.0.1.tar.bz2 | tar -xj \
    && mv firefox /usr/local \
    && ln -s /usr/local/firefox/firefox /usr/bin/firefox

# Install geckodriver
RUN curl -sL https://github.com/mozilla/geckodriver/releases/download/v0.26.0/geckodriver-v0.26.0-linux64.tar.gz | tar -xz \
    && mv /home/bdd/geckodriver /usr/bin/geckodriver

# JDK 12
RUN curl -sL https://download.java.net/java/GA/jdk12.0.2/e482c34c86bd4bf8b56c0b35558996b9/10/GPL/openjdk-12.0.2_linux-x64_bin.tar.gz | tar -xz \
    && mv /home/bdd/jdk-12.0.2 /usr/java \
    && ln -s /usr/java/bin/java /usr/bin/java \
    && ln -s /usr/java/bin/javac /usr/bin/javac \
    && ln -s /usr/java/bin/javadoc /usr/bin/javadoc
ENV JAVA_HOME /usr/java

# Set DISPLAY
ENV DISPLAY :99

# Install X Utils for xdpyinfo for use in checking Xvfb status
RUN yum -y install xorg-x11-utils

# Install gcsfuse
COPY gcsfuse.repo /etc/yum.repos.d/
RUN yum -y update && yum -y install gcsfuse

# Common configuration for BDD
ENV SERENITY_OUTPUT_BUCKET build-reports.k8s.alevat.com
COPY init.gradle /root/.gradle/init.gradle
COPY run-tests.sh ./

# Run tests
CMD ["./run-tests.sh"]
