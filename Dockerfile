FROM factual/docker-cdh5-base

ENV HADOOP_CONF_DIR=/etc/hadoop/conf

RUN apt-add-repository ppa:brightbox/ruby-ng \
  && add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" \
  && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update && apt-get install -y --no-install-recommends \
    git-core sudo build-essential unzip zlib1g-dev \
    liblzo2-dev libcurl4-gnutls-dev libncurses5-dev libpq-dev \
    vim emacs \
    ruby2.4 ruby2.4-dev uuid-runtime \
    postgresql-client-9.6 \
    openjdk-8-jdk-headless ant \
    nodejs npm \
    python3 python3-dev python3-pip \
    ldap-utils libpam-ldap libnss-ldap nslcd \
    s3cmd awscli \
    jq \
    virtualenv python3-venv python3-virtualenv \
    manpages manpages-dev man-db \
  && update-ca-certificates -f \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    matplotlib \
    numpy \
    pandas \
    scikit-learn \
    scipy \
  && gem install bundler --no-rdoc --no-ri

#maven
ENV MAVEN_VERSION=3.5.2
ENV MAVEN_PATH=/opt/apache-maven
RUN mkdir -p $MAVEN_PATH \
  && curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar xz --strip-components=1 -C $MAVEN_PATH \
  && ln -s $MAVEN_PATH/bin/mvn /usr/bin/mvn

#lein
ARG LEIN_ROOT=true
RUN curl -fsSL https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /bin/lein \
  && chmod 755 /bin/lein \
  && lein --version

#thrift
ENV THRIFT_VERSION=0.9.2
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    bison \
    flex \
    libboost-all-dev \
    libevent-dev \
  && curl -fsSL http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz \
    | tar xz -C /tmp/ \
  && cd /tmp/thrift-$THRIFT_VERSION \
  && ./configure --without-ruby --without-cpp --without-nodejs --without-python \
  && make install \
  && rm -rf /tmp/thrift-$THRIFT_VERSION \
  && apt-get purge -y --auto-remove automake bison flex libboost-all-dev libevent-dev

#Drake
RUN curl -fsSL https://raw.githubusercontent.com/Factual/drake/master/bin/drake -o /bin/drake \
  && chmod 755 /bin/drake

#Spark
ENV SPARK_VERSION=2.2.1
ENV SPARK_HOME=/opt/spark
RUN mkdir -p $SPARK_HOME \
  && curl -fsSL http://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.6.tgz \
    | tar xz -C /tmp/ \
  && rm -rf $SPARK_HOME && mv /tmp/spark-$SPARK_VERSION-bin-hadoop2.6 $SPARK_HOME \
  && mkdir -p /etc/spark/ \
  && ln -s $SPARK_HOME/conf /etc/spark/conf

#hive
ENV HIVE_VERSION=2.3.2
ENV HIVE_HOME=/opt/hive
RUN mkdir -p $HIVE_HOME \
  && curl -fsSL http://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz \
    | tar xz --strip-components=1 -C $HIVE_HOME \
  && mkdir -p /etc/hive/ \
  && ln -s $HIVE_HOME/conf /etc/hive/conf \
  && mv /etc/hive/conf/hive-default.xml.template /etc/hive/conf/hive-default.xml \
  && mv /etc/hive/conf/hive-env.sh.template /etc/hive/conf/hive-env.sh

#presto
ENV PRESTO_VERSION=0.190
RUN curl -fsSL https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$PRESTO_VERSION/presto-cli-$PRESTO_VERSION-executable.jar -o /usr/local/bin/presto \
  && chmod 755 /usr/local/bin/presto

#clean out typically conflicting files
RUN find /usr/lib/ -name "httpclient-*.jar" -type f -exec rm {} \; \
  && find /usr/lib/ -name "httpcore-*.jar" -type f -exec rm {} \;

ENV PATH="$HIVE_HOME/bin:$SPARK_HOME/bin:$PATH"
COPY bootstrap.sh /etc/my_init.d/099_bootstrap
VOLUME /var/lib/docker
