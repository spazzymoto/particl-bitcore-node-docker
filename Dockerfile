FROM ubuntu:latest

LABEL maintainer="Robert Edwards (rob@particl.io)"

RUN apt update && apt -y upgrade && \
	apt install -y curl git libzmq3-dev gnupg2 build-essential wget nano lsof && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash -  && \
	apt install -y nodejs && \
	useradd --no-log-init -m insight && \
	mkdir /particl-data && chmod 777 /particl-data


USER insight

RUN mkdir ~/.npm-global && \
    npm config set prefix '~/.npm-global'

ENV PATH ~/.npm-global/bin:$PATH

RUN npm install -g git://github.com/particl/particl-bitcore-node

RUN cd ~/ && \
    ~/.npm-global/bin/bitcore-node create particl-insight

RUN cd ~/particl-insight/ && \
    npm install --save git://github.com/particl/particl-insight-api  && \
    npm install --save git://github.com/particl/particl-insight-ui && \
    npm install --save git://github.com/spazzymoto/particl-bitcore-lib.git#cold_staking && \
    rm -rf node_modules/particl-bitcore-message/node_modules/particl-bitcore-lib/ && \
    rm -rf node_modules/particl-bitcore-node/node_modules/particl-bitcore-lib/  && \
    rm -rf node_modules/particl-insight-api/node_modules/particl-bitcore-lib/   


RUN cd ~/ && \
    wget https://github.com/particl/particl-core/releases/download/v0.17.0.1/particl-0.17.0.1-x86_64-linux-gnu_nousb.tar.gz && \
    tar xvfz particl-0.17.0.1-x86_64-linux-gnu_nousb.tar.gz && \
    mv particl-0.17.0.1 particl-core && \
    rm particl-0.17.0.1-x86_64-linux-gnu_nousb.tar.gz
    
COPY start.sh /home/insight/start.sh
COPY bitcore-node.json /home/insight/particl-insight/bitcore-node.json

VOLUME /particl-data

CMD ["/home/insight/start.sh"]