FROM node:0.10

ENV APP_HOME /smartbot
RUN mkdir $APP_HOME

WORKDIR $APP_HOME

COPY . $APP_HOME

RUN npm install

CMD bin/hubot -a slack -n smartbot
