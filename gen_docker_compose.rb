require 'yaml'

APP_COUNT = 5
REDIS_COUNT = 1
CPUS = 0.25
NETWORK = 'load_balancing'

def common
  {
    'cpus' => CPUS,
    'networks' => [NETWORK],
  }
end

compose = {'version' => '2'}

services = {}

nginx = {
  'build' => './nginx',
  'ports' => ["3000:80"],
  'volumes' => ['./nginx/nginx.conf:/etc/nginx/conf.d/default.conf'],
}.merge(common)

postgres_master = {
  'image' => 'bitnami/postgresql',
  'restart' => 'always',
  'ports' => ['5432:5432'],
  'volumes' => %w[postgresql_master_data:/bitnami/postgresql ./db.sql:/docker-entrypoint-initdb.d/db.sql],
  'environment' => %w[
    POSTGRESQL_PGAUDIT_LOG=READ,WRITE
    POSTGRESQL_LOG_HOSTNAME=true
    POSTGRESQL_REPLICATION_MODE=master
    POSTGRESQL_REPLICATION_USER=repl_user
    POSTGRESQL_REPLICATION_PASSWORD=repl_user
    POSTGRESQL_USERNAME=postgres
    POSTGRESQL_PASSWORD=postgres
    POSTGRESQL_DATABASE=yaus_production
    ALLOW_EMPTY_PASSWORD=yes
  ],
}.merge(common)

postgres_slave = {
  'image' => 'bitnami/postgresql',
  'restart' => 'always',
  'ports' => ['5433:5432'],
  'depends_on' => ['postgresql-master'],
  'environment' => %w[
    POSTGRESQL_PASSWORD=postgres
    POSTGRESQL_MASTER_HOST=postgresql-master
    POSTGRESQL_PGAUDIT_LOG=READ
    POSTGRESQL_LOG_HOSTNAME=true
    POSTGRESQL_REPLICATION_MODE=slave
    POSTGRESQL_REPLICATION_USER=repl_user
    POSTGRESQL_REPLICATION_PASSWORD=repl_user
    POSTGRESQL_MASTER_PORT_NUMBER=5432
    ALLOW_EMPTY_PASSWORD=yes
  ],
}.merge(common)

redis_node_names = (0...REDIS_COUNT).map { |i| "redis-node-#{i}" }
redis_volume_names = (0...REDIS_COUNT).map { |i| "redis-cluster_data-#{i}" }

redis_other = (1...REDIS_COUNT).map do |index|
  ["redis-node-#{index}", {
    'image' => 'docker.io/bitnami/redis-cluster:7.2',
    'environment' => [
      'REDIS_PASSWORD=bitnami',
      "REDIS_NODES=#{redis_node_names.join(' ')}",
    ],
  }.merge(common)]
end.to_h

redis_zero = {
  'image' => 'bitnami/redis:latest',
  'depends_on' => redis_other.keys,
  'environment' => %w[
    REDIS_PASSWORD=bitnami
  ],
  'ports' => ["6379:6379"],
}.merge(common)

apps =
  (1..APP_COUNT)
    .map do |app_index|
    ["app-#{app_index}", {
      'build' => '.',
      'depends_on' => ["postgresql-master", redis_node_names[0]],
      'environment' => ['SECRET_KEY_BASE=ababababbabab8744756387465'],
    }.merge(common)]
  end.to_h

nginx['depends_on'] = apps.keys

services['nginx'] = nginx

services.merge!(apps)

services['postgresql-master'] = postgres_master
services['postgresql-slave'] = postgres_slave

services[redis_node_names[0]] = redis_zero
services.merge!(redis_other)

compose['services'] = services

compose['networks'] = {NETWORK => nil}

compose['volumes'] = (['postgresql_master_data']).map do |name|
  [name, {'driver' => 'local'}]
end.to_h

puts compose.to_yaml
