
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 3000 -j ACCEPT

mkdir -p /home/wiki/db-data
mkdir -p /home/wiki/config
mkdir -p /home/wiki/wiki_data

docker run \
	--name some-postgres \
	--rm \
	--env POSTGRES_PASSWORD=mysecretpassword \
	--detach \
	--volume /home/wiki/data/db-data:/var/lib/postgresql/data \
	--publish 5432:5432 \
	postgres

docker run \
	--name=wikijs \
	--rm \
	--volume /home/wiki/data/config:/config \
	--volume /home/wiki/data/wiki_data:/data \
	--detach \
	--network=host \
	--env PUID=1000 \
	--env PGID=1000 \
	--env TZ=Etc/UTC \
	--env DB_TYPE=postgres \
	--env DB_HOST=localhost \
	--env DB_PORT=5432 \
	--env DB_NAME=postgres \
	--env DB_USER=postgres \
	--env DB_PASS=mysecretpassword \
	lscr.io/linuxserver/wikijs:latest			    
