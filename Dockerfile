FROM alpine

# ref: https://stackoverflow.com/a/52903112
RUN apk --no-cache add openfortivpn \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN apk --no-cache add openssh
RUN apk --no-cache add tmux

CMD ["tail", "-f", "/dev/null"]
