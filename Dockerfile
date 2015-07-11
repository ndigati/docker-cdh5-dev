FROM factual/docker-cdh5-base

# for ruby 2.2
RUN apt-add-repository ppa:brightbox/ruby-ng


RUN apt-get update && apt-get install -y git-core default-jdk ruby2.2 ruby2.2-dev build-essential

ADD bootstrap.sh /etc/my_init.d/099_bootstrap