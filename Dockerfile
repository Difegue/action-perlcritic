FROM pipelinecomponents/perl-critic:0.12.4

RUN apk add bash ca-certificates coreutils jq 

COPY "entrypoint.sh" "/entrypoint.sh"
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
