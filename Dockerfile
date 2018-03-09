FROM factual/docker-cdh5-base

# for ruby 2.4
RUN apt-add-repository ppa:brightbox/ruby-ng

# for updated postgres
RUN add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get clean
RUN apt-get install -y git-core sudo build-essential automake unzip zlib1g-dev \
                       liblzo2-dev libcurl4-gnutls-dev libncurses5-dev bison flex libpq-dev \
                       libboost-all-dev libevent-dev vim emacs \
                       ruby2.4 ruby2.4-dev uuid-runtime\
                       postgresql-client-9.6 \
                       nodejs npm \
                       python3 python3-dev python3-pip \
                       ldap-utils libpam-ldap libnss-ldap nslcd \
                       s3cmd awscli \
                       openjdk-8-jdk-headless ant \
                       jq \
                       virtualenv python3-venv python3-virtualenv && \
    apt-get upgrade -y && \
    apt-get clean

RUN update-ca-certificates -f

RUN gem install bundler --no-rdoc --no-ri

RUN pip3 install --upgrade pip
RUN pip3 install \
    matplotlib \
    numpy \
    pandas \
    scikit-learn \
    scipy

<<<<<<< HEAD
=======
RUN gem install bundler --no-rdoc --no-ri

RUN apt-get upgrade -y
RUN update-ca-certificates -f

>>>>>>> cweinberg/master
#maven
ARG MAVEN_VERSION=3.5.2
ARG MAVEN_PATH=/opt/apache-maven
ADD http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz /tmp/
RUN cd /tmp/ && tar xzf apache-maven-$MAVEN_VERSION-bin.tar.gz && mv apache-maven-$MAVEN_VERSION $MAVEN_PATH
RUN ln -s $MAVEN_PATH/bin/mvn /usr/bin/mvn
ENV MAVEN_PATH=$MAVEN_PATH
 
#lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /bin/lein
ENV LEIN_ROOT=true
RUN chmod 755 /bin/lein
RUN lein --version

#thrift
ARG THRIFT_VERSION=0.9.2 
ADD http://archive.apache.org/dist/thrift/$THRIFT_VERSION/thrift-$THRIFT_VERSION.tar.gz /tmp/
RUN cd /tmp/ && tar xzf thrift-$THRIFT_VERSION.tar.gz && cd thrift-$THRIFT_VERSION && ./configure --without-ruby --without-cpp --without-nodejs --without-python && make install
RUN rm -rf thrift-$THRIFT_VERSION*

#Drake
ADD https://raw.githubusercontent.com/Factual/drake/master/bin/drake /bin/drake
RUN chmod 755 /bin/drake

#Spark
ARG SPARK_VERSION=2.2.1
ARG SPARK_HOME=/opt/spark
ADD http://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz /tmp/
RUN cd /tmp/ && tar xzf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION $SPARK_HOME
RUN mkdir -p /etc/spark/ && ln -s $SPARK_HOME/conf /etc/spark/conf
ENV SPARK_HOME=$SPARK_HOME \
    PATH=$SPARK_HOME/bin:$PATH

#hive
ARG HIVE_VERSION=2.3.2 
ARG HIVE_HOME=/opt/hive 
ADD http://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz /tmp/
RUN cd /tmp/ && tar xzf apache-hive-$HIVE_VERSION-bin.tar.gz && mv apache-hive-$HIVE_VERSION-bin $HIVE_HOME
RUN mkdir -p /etc/hive/ && ln -s $HIVE_HOME/conf /etc/hive/conf
RUN mv /etc/hive/conf/hive-default.xml.template /etc/hive/conf/hive-default.xml
RUN mv /etc/hive/conf/hive-env.sh.template /etc/hive/conf/hive-env.sh
ENV HIVE_HOME=$HIVE_HOME \
    PATH=$HIVE_HOME/bin:$PATH
 
#presto
ARG PRESTO_VERSION=0.190 
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


