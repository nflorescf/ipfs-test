FROM ubuntu:18.04
# Autor
MAINTAINER Nicolas Flores

RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        python \
        g++ \
        make

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update && \
    apt-get install -y \
        nodejs

RUN npm config set unsafe-perm true

WORKDIR /usr/src/app
RUN ls -ltr 
COPY package.json ./
COPY webpack.config.js ./
COPY package-lock.json ./
COPY webpack.config.js ./
RUN mkdir REPO
RUN npm install -g
RUN npm install babel-jest@26.6.0 -g
RUN npm install babel-loader@8.1.0 jest@26.6.0 webpack@4.44.2 -g
RUN npm install webpack@4.44.2 -g

CMD ["ls","-ltr;","npm","run","build"]
##CMD ["node", "--max-old-space-size=4096", "node_modules/@angular/cli/bin/ng", "build"]
