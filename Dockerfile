FROM node:20-slim

WORKDIR /opt
ADD . /opt
RUN npm install
ENTRYPOINT npm run start