FROM jenkins/agent:4.11-1-alpine-jdk11

LABEL maintainer="EDP Team"

ENV BASH_VERSION=5.1.16-r0 \
    BC_VERSION=1.07.1-r1 \
    BZIP2_VERSION=1.0.8-r1 \
    COREUTILS_VERSION=8.32-r2 \
    CURL_VERSION=8.0.1-r0 \
    GCC_VERSION=10.3.1_git20210424-r2 \
    GCOMPAT_VERSION=1.0.0-r2 \
    GETTEXT_VERSION=0.21-r0 \
    GIT_VERSION=2.32.7-r0 \
    GREP_VERSION=3.7-r0 \
    HOME=/home/jenkins \
    JQ_VERSION=1.6-r1 \
    KUBECTL_VERSION=v1.24.3\
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LSOF_VERSION=4.94.0-r0 \
    MAKE_VERSION=4.3-r0 \
    MUSL_VERSION=1.0.3-r2 \
    OC_VERSION=v3.11.0 \
    OPENJDK11_VERSION=11.0.14_p9-r0 \
    OPENJDK8_VERSION=8.302.08-r1 \
    RSYNC_VERSION=3.2.5-r0 \
    TAR_VERSION=1.34-r1 \
    UNZIP_VERSION=6.0-r9 \
    WHICH_VERSION=2.21-r1 \
    ZIP_VERSION=3.0-r9 \
    ZLIB_VERSION=1.2.12-r3

USER root

#Copy jenkins agent
COPY jenkins-agent /usr/local/bin/jenkins-agent

RUN chmod +x /usr/local/bin/jenkins-agent && \
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave && \
    adduser \
    --disabled-password \
    --gecos "" \
    --uid "1001" \
    "1001"

RUN apk -U upgrade

RUN apk add --no-cache bc=$BC_VERSION gettext=$GETTEXT_VERSION git=$GIT_VERSION coreutils=$COREUTILS_VERSION grep=$GREP_VERSION \
    gcc=$GCC_VERSION openjdk8-jre=$OPENJDK8_VERSION openjdk11-jre=$OPENJDK11_VERSION make=$MAKE_VERSION lsof=$LSOF_VERSION \
    rsync=$RSYNC_VERSION tar=$TAR_VERSION unzip=$UNZIP_VERSION which=$WHICH_VERSION zip=$ZIP_VERSION \
    bzip2=$BZIP2_VERSION jq=$JQ_VERSION musl-nscd-dev=$MUSL_VERSION curl=$CURL_VERSION bash=$BASH_VERSION gcompat=$GCOMPAT_VERSION zlib=$ZLIB_VERSION && \
    mkdir -p /home/jenkins && \
    chown -R 1001:0 /home/jenkins && \
    chmod -R g+w /home/jenkins && \
    chmod -R 775 /usr/lib/jvm && \
    chmod 775 /usr/bin && \
    mkdir -p /var/lib/origin && \
    chmod 775 /var/lib/origin


# Install kubectl
RUN curl -fsSLo /tmp/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /tmp/kubectl && \
    mv /tmp/kubectl /usr/local/bin/kubectl

# Install oc
RUN curl -Lo /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit.tar.gz \
    https://github.com/openshift/origin/releases/download/${OC_VERSION}/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit.tar.gz && \
    tar -zxvf /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit.tar.gz -C /tmp/ && \
    chmod +x /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit/oc && \
    mv /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit/oc /usr/local/bin/oc && \
    rm -rf /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit.tar.gz \
    /tmp/openshift-origin-client-tools-${OC_VERSION}-0cbc58b-linux-64bit/


USER 1001

# Run the Jenkins JNLP client
ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
