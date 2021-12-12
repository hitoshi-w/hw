FROM ruby:3.0.2

ENV APP_ROOT /opt/app

ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y build-essential apt-transport-https default-mysql-client --no-install-recommends

# Node のインストール
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# Yarn のインストール
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt install -y yarn

# Bundlerのインストール
RUN gem install bundler

RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT
COPY . $APP_ROOT

EXPOSE 3000

