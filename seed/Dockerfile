FROM alpine:3.20
RUN apk add --no-cache curl postgresql16-client
COPY seed.sh /seed.sh
RUN chmod +x /seed.sh
CMD ["/seed.sh"]
