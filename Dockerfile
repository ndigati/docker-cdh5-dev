FROM factual/docker-cdh5-base

# for ruby 2.4
RUN apt-add-repository ppa:brightbox/ruby-ng

ARG MAVEN_VERSION=3.5.2
ARG THRIFT_VERSION=0.9.2
ARG SPARK_VERSION=2.2.0-bin-hadoop2.6
ARG SPARK_HOME=/opt/spark
ARG HIVE_VERSION=2.3.2
ARG PRESTO_VERSION=0.190
ARG HIVE_HOME=/opt/hive
ARG MAVEN_PATH=/opt/apache-maven
ARG HADOOP_CONF_DIR=/etc/hadoop/conf

RUN apt-get update
RUN apt-get install -y git-core sudo build-essential automake unzip zlib1g-dev liblzo2-dev libcurl4-gnutls-dev libncurses5-dev bison flex libboost-all-dev libevent-dev
RUN apt-get install -y vim emacs
RUN apt-get install -y ruby2.4 ruby2.4-dev nodejs npm python3 python3-dev
RUN gem install bundler --no-rdoc --no-ri

RUN apt-get install -y ldap-utils libpam-ldap libnss-ldap nslcd

RUN apt-get install -y openjdk-8-jdk-headless ant

RUN apt-get upgrade -y

#maven
ADD http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz /tmp/
RUN cd /tmp/ && tar xzf apache-maven-$MAVEN_VERSION-bin.tar.gz && mv apache-maven-$MAVEN_VERSION $MAVEN_PATH
RUN ln -s $MAVEN_PATH/bin/mvn /usr/bin/mvn

RUN update-ca-certificates -f

#lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /bin/lein
ENV LEIN_ROOT=true
RUN chmod 755 /bin/lein
RUN lein --version

#thrift
ADD http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz /tmp/
RUN cd /tmp/ && tar xzf thrift-$THRIFT_VERSION.tar.gz && cd thrift-$THRIFT_VERSION && ./configure --without-ruby --without-cpp --without-nodejs --without-python && make install
RUN rm -rf thrift-$THRIFT_VERSION*

#Drake
ADD https://raw.githubusercontent.com/Factual/drake/master/bin/drake /bin/drake
RUN chmod 755 /bin/drake

#Spark
ADD http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz /tmp/
RUN cd /tmp/ && tar xzf spark-$SPARK_VERSION.tgz && mv spark-$SPARK_VERSION $SPARK_HOME
RUN echo "export PATH=$SPARK_HOME/bin:\$PATH" >> /etc/profile
RUN echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" >> /etc/profile
RUN echo "export SPARK_HOME=$SPARK_HOME" >> /etc/profile
RUN mkdir -p /etc/spark/ && ln -s $SPARK_HOME/conf /etc/spark/conf

#hive
ADD http://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz /tmp/
RUN cd /tmp/ && tar xzf apache-hive-$HIVE_VERSION-bin.tar.gz && mv apache-hive-$HIVE_VERSION-bin $HIVE_HOME
RUN echo "export PATH=$HIVE_HOME/bin:\$PATH" >> /etc/profile
RUN echo "export HIVE_HOME=$HIVE_HOME" >> /etc/profile
RUN mkdir -p /etc/hive/ && ln -s $HIVE_HOME/conf /etc/hive/conf
RUN mv /etc/hive/conf/hive-default.xml.template /etc/hive/conf/hive-default.xml
RUN mv /etc/hive/conf/hive-env.sh.template /etc/hive/conf/hive-env.sh

#presto
ADD https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$PRESTO_VERSION/presto-cli-$PRESTO_VERSION-executable.jar /usr/local/bin/presto
RUN chmod 755 /usr/local/bin/presto

#clean out typically conflicting files
RUN find /usr/lib/ -name "httpclient-*.jar" -type f -exec rm {} \;
RUN find /usr/lib/ -name "httpcore-*.jar" -type f -exec rm {} \;

#man
RUN apt-get purge -y manpages manpages-dev man-db
RUN apt-get install -y manpages manpages-dev man-db

#cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ADD bootstrap.sh /etc/my_init.d/099_bootstrap
