FROM factual/docker-cdh5-base:java7

# for ruby 2.2
RUN apt-add-repository ppa:brightbox/ruby-ng


RUN apt-get update
RUN apt-get install -y git-core default-jdk maven build-essential zlib1g-dev libcurl4-gnutls-dev libncurses5-dev 
RUN apt-get install -y ruby2.2 ruby2.2-dev nodejs npm
RUN apt-get install -y ldap-utils libpam-ldap libnss-ldap nslcd
RUN apt-get install -y spark-core spark-python hive


#lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /bin/lein
ENV LEIN_ROOT=true
RUN chmod +x /bin/lein
RUN lein --version



#Drake
ADD https://raw.githubusercontent.com/Factual/drake/master/bin/drake /bin/drake
RUN chmod 755 /bin/drake

RUN gem install bundler --no-rdoc --no-ri

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD bootstrap.sh /etc/my_init.d/099_bootstrap
