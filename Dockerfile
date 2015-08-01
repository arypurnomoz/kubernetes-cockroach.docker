FROM cockroachdb/cockroach

ADD run.sh /run.sh
ADD store /store
ADD discovery /discovery

ENTRYPOINT ["/run.sh"]
