FROM cockroachdb/cockroach

ADD run.sh /run.sh
ADD store /store

ENTRYPOINT ["/run.sh"]
