FROM node:lts-hydrogen
COPY *.js *.json /opt/hugoalh/test/
RUN ["chmod", "+x", "/opt/hugoalh/test/pre.js"]
RUN ["chmod", "+x", "/opt/hugoalh/test/main.js"]
RUN ["chmod", "+x", "/opt/hugoalh/test/post.js"]
CMD ["/opt/hugoalh/test/main.js"]
