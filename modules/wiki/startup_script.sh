
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 3000 -j ACCEPT

data_directory="/home/wiki"

mkdir -p "${data_directory}/db-data"
mkdir -p "${data_directory}/config"
mkdir -p "${data_directory}/wiki_data"

docker run \
	--name some-postgres \
	--rm \
	--env POSTGRES_USER="${postgres_username}" \
	--env POSTGRES_PASSWORD="${postgres_password}" \
	--detach \
	--volume "${data_directory}/db-data:/var/lib/postgresql/data" \
	--publish 5432:5432 \
	postgres

docker run \
	--name=wikijs \
	--rm \
	--volume "${data_directory}/config:/config" \
	--volume "${data_directory}/wiki_data:/data" \
	--detach \
	--network=host \
	--env DB_TYPE=postgres \
	--env DB_HOST=localhost \
	--env DB_PORT=5432 \
	--env DB_NAME=postgres \
	--env DB_USER="${postgres_username}" \
	--env DB_PASS="${postgres_password}" \
	requarks/wiki

