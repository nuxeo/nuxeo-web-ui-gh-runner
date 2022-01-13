# (C) Copyright 2021 Nuxeo (http://nuxeo.com/) and others.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM ubuntu:latest

ARG DESCRIPTION="Maven+NodeJS and Chrome image for the Nuxeo WebUI build"
ARG SCM_REPOSITORY=git@github.com:nuxeo/nuxeo-web-ui-gh-runner.git
ARG VERSION=unknown
ARG SCM_REF=unknown

LABEL description=${DESCRIPTION}
LABEL scm-url=${SCM_REPOSITORY}
LABEL version=${VERSION}
LABEL scm-ref=${SCM_REF}

# upgrade and install common software
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -yq update && apt-get install -yq software-properties-common curl wget git zip unzip nano

# Install Maven
ARG MAVEN_VERSION=3.8.3
RUN curl -f -L https://repo1.maven.org/maven2/org/apache/maven/apache-maven/$MAVEN_VERSION/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -C /opt -xzv
ENV M2_HOME /opt/apache-maven-${MAVEN_VERSION}
ENV maven.home ${M2_HOME}
ENV M2 ${M2_HOME}/bin
ENV PATH ${M2}:${PATH}

# Init settings.xml
RUN mkdir -p /root/.m2 && \
  touch /root/.m2/settings.xml

# Install Java and conversion tools
ARG JDK_VERSION=11
RUN apt-get install -yq openjdk-$JDK_VERSION-jdk-headless \
  imagemagick \
  poppler-utils \
  libreoffice \
  ffmpeg \
  libwpd-tools \
  ghostscript \
  exiftool

# remove policies that prevent PDF converters to work
RUN sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml

# set default JAVA_HOME
RUN echo 'export JAVA_HOME=$(readlink -f `which javac` | sed "s:/bin/javac::")/bin/java' >> ~/.bashrc

# Install Node.jx
ARG NODEJS_VERSION=10
RUN curl -f --location https://deb.nodesource.com/setup_$NODEJS_VERSION.x | bash - && \
    apt-get install -yq nodejs && \
    apt-get install -yq g++ build-essential
ENV NODE_OPTIONS --max-old-space-size=2048

# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list && \
  apt-get -yq update && \
  apt-get -yq install google-chrome-stable && \
  rm -r /etc/apt/sources.list.d/google.list

# Support Web UI LTS2019
RUN apt-get install -yq rsync && \
  npm install -g bower && \
  npm install -g gulp-cli

# Install GH Runner
ARG GH_RUNNER_VERSION="2.283.2"
WORKDIR /runner
RUN apt-get install -yq jq
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    ./bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/runner/entrypoint.sh"]