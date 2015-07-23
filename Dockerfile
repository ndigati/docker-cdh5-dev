FROM factual/docker-cdh5-base

# for ruby 2.2
RUN apt-add-repository ppa:brightbox/ruby-ng

RUN apt-get update && apt-get install -y git-core default-jdk maven ruby2.2 ruby2.2-dev build-essential  zlib1g-dev libcurl4-gnutls-dev libncurses5-dev

#lein
ADD https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein /bin/lein
ENV LEIN_ROOT=true
RUN chmod +x /bin/lein
RUN lein --version

ADD bootstrap.sh /etc/my_init.d/099_bootstrap
