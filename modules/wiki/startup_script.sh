
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I OUTPUT -p tcp --sport 443 -j ACCEPT

data_directory="/home/wiki"

mkdir -p "${data_directory}/db-data"
mkdir -p "${data_directory}/config"
mkdir -p "${data_directory}/wiki_data"

cat<<EOF>${data_directory}/pomerium_config.yaml
${pomerium_config}
EOF

docker run \
	--name some-postgres \
	--env POSTGRES_USER="${postgres_username}" \
	--env POSTGRES_PASSWORD="${postgres_password}" \
	--detach \
	--volume "${data_directory}/db-data:/var/lib/postgresql/data" \
	--publish 5432:5432 \
	postgres

docker run \
	--name=wikijs \
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

docker run \
	--name pomerium \
	--env IDP_PROVIDER="google" \
	--env IDP_CLIENT_ID="${pomerium_client_id}" \
	--env IDP_CLIENT_SECRET="${pomerium_client_secret}" \
	--detach \
	--volume "${data_directory}/pomerium_config.yaml:/pomerium/config.yaml:ro" \
	--network=host \
	pomerium/pomerium
