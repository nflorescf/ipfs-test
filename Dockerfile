FROM ubuntu:18.04
# Autor
MAINTAINER Nicolas Flores

ENV TZ America/Argentina/Buenos_Aires

RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

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
COPY package.json ./
COPY webpack.config.js ./
COPY package-lock.json ./
COPY webpack.config.js ./
COPY . .

RUN npm install
RUN npm install babel-jest@26.6.0
RUN npm install babel-loader@8.1.0 jest@26.6.0 webpack@4.44.2
RUN npm install webpack@4.44.2

CMD ["npm", "run", "build"]
##CMD ["node", "--max-old-space-size=4096", "node_modules/@angular/cli/bin/ng", "build"]
