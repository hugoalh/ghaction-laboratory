FROM node:lts-hydrogen
COPY *.js *.json /opt/hugoalh/test/
CMD ["/opt/hugoalh/test/main.js"]
