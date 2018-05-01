build: TAG=latest
build:
	docker build -t gertcuykens/nginx-grpc:$(TAG) .
	docker push gertcuykens/nginx-grpc:$(TAG)

run: TLS=/Users/gert/go/src/github.com/gertcuykens/tls
run: TAG=latest
run:
	docker run --rm -it -v $(TLS):/run/secrets -p 8443:8443 gertcuykens/nginx-grpc:$(TAG) $(CMD)

config: TLS=/Users/gert/go/src/github.com/gertcuykens/tls
config:
	-docker secret create tls.crt $(TLS)/tls.crt
	-docker secret create tls.key $(TLS)/tls.key
	-docker config create nginx.conf nginx.conf

service:
	docker service create \
	  --name grpc \
	  --secret tls.key \
    --secret tls.crt \
	  --config source=nginx.conf,target=/etc/nginx/nginx.conf,mode=0440 \
	  --publish published=8443,target=8443 \
    gertcuykens/nginx-grpc

update:
	docker service update \
	  --secret-rm tls.key \
	  --secret-add tls.key \
    --secret-rm tls.crt \
    --secret-add tls.crt \
    --config-rm nginx.conf \
    --config-add source=nginx.conf,target=/etc/nginx/nginx.conf,mode=0440 \
    grpc

rm:
	docker service rm grpc

log:
	docker service logs grpc

stack:
# docker stack rm grpc
	docker stack deploy --compose-file docker-compose.yml grpc

.PHONY: build run

# make run CMD="/bin/ash"
# docker swarm leave --force
# docker swarm init
# docker swarm node ls
# docker swarm
# docker service ls
# docker service inspect
# docker node update --label-add <key>=<value> <node-id>
