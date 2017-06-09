#!/bin/sh

./wait.sh -t 300 -h es -p 9200 #wait for elasticsearch
./wait.sh -t 15 -h logstash -p 5044 # wait for logstash

ES_USER=elastic
ES_PASS=changeme

#Add role that is configured for logstash indexer named logstash_writer
curl -k \
   --user ${ES_USER}:${ES_PASS} \
   -X POST \
   -H "Content-Type: application/json"\
   -d "{ \"cluster\": [\"manage_index_templates\", \"monitor\"], \"indices\": [{ \"names\": [\"logstash-*\", \"filebeat-*\", \"winlogbeat-*\", \"appbeat-*\", \"apachebeat-*\", \"firebeat-*\"], \"privileges\": [\"write\", \"delete\", \"create_index\"]}]}" \
   https://es:9200/_xpack/security/role/logstash_writer

# Add user with role logstash writer
curl -k \
   --user ${ES_USER}:${ES_PASS} \
   -X POST \
   -H "Content-Type: application/json"\
   -d "{ \"password\" : \"changeme\",\"roles\" : [ \"logstash_writer\"],\"full_name\" : \"Internal Logstash User\"}"\
   https://es:9200/_xpack/security/user/logstash_internal

# curl -k \
#  --user ${ES_USER}:${ES_PASS} \
#  -X PUT \
#  "https://es:9200/_template/${INDEX_NAME}?pretty" \
#  -d@/usr/share/filebeat/filebeat.template.json

/etc/init.d/filebeat start -e

mkdir /var/log/filebeat
touch /var/log/filebeat/filebeat.log
tail -f /var/log/filebeat/filebeat.log & wait
