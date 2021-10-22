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
FROM centos:7

ARG DESCRIPTION="Maven+NodeJS and Chrome image for the Nuxeo WebUI build"
ARG SCM_REPOSITORY=git@github.com:nuxeo/nuxeo-web-ui-gh-runner.git
ARG VERSION=unknown
ARG SCM_REF=unknown

LABEL description=${DESCRIPTION}
LABEL scm-url=${SCM_REPOSITORY}
LABEL version=${VERSION}
LABEL scm-ref=${SCM_REF}

# Add Yum repositories
COPY nuxeo.repo /etc/yum.repos.d/
COPY google-chrome.repo /etc/yum.repos.d/

# Install Maven
ARG MAVEN_VERSION=3.8.3
RUN curl -f -L https://repo1.maven.org/maven2/org/apache/maven/apache-maven/$MAVEN_VERSION/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -C /opt -xzv
ENV M2_HOME /opt/apache-maven-${MAVEN_VERSION}
ENV maven.home ${M2_HOME}
ENV M2 ${M2_HOME}/bin
ENV PATH ${M2}:${PATH}

# Install Java and conversion tools
ARG JDK_VERSION=11
RUN yum -y update && yum -y install epel-release && yum -y --setopt=skip_missing_names_on_install=False --enablerepo nuxeo install \
  ccextractor \
  ffmpeg-nuxeo \
  ghostscript \
  ImageMagick-6.9.10.68-3.el7 \
  java-$JDK_VERSION-openjdk java-$JDK_VERSION-openjdk-devel \
  libreoffice-calc libreoffice-headless libreoffice-impress libreoffice-writer \
  libwpd-tools \
  # required by perl-Image-ExifTool to extract binary metadata from open office document
  perl-Archive-Zip \
  perl-Image-ExifTool \
  poppler-utils \
  ufraw

# Set $JDK_VERSION as default Java (libreoffice adds Java 8)
RUN alternatives --set java java-${JDK_VERSION}-openjdk.x86_64

# Install Node.jx
ARG NODEJS_VERSION=10
RUN curl -f --silent --location https://rpm.nodesource.com/setup_$NODEJS_VERSION.x | bash - && \
    yum install -y nodejs && \
    yum install -y gcc-c++ make

# Install Git and Bower (for Web UI 10.10)
RUN yum install -y git \
  && npm install -g bower \
  && npm install -g gulp-cli

# Install Chrome
RUN yum install -y google-chrome-stable \
  && yum clean all

CMD ["google-chrome","-version"]

# Install GH Runner
ARG GH_RUNNER_VERSION="2.283.2"
WORKDIR /runner
RUN yum -y install jq
RUN curl -o actions.tar.gz --location "https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-x64-${GH_RUNNER_VERSION}.tar.gz" && \
    tar -zxf actions.tar.gz && \
    rm -f actions.tar.gz && \
    ./bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/runner/entrypoint.sh"]