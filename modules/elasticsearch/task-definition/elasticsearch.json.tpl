[
  {
    "name": "elasticsearch",
    "image": "${img}",
    "networkMode": "${network_mode}",
    "portMappings": [
      {
        "containerPort": ${container_port}
      },
      {
        "containerPort": 9300
      }
    ],
    "environment": [
      {
        "name": "ES_JAVA_OPTS",
        "value": "-Xms${elasticsearch_java_mem}m -Xmx${elasticsearch_java_mem}m"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${data_volume_name}",
        "containerPath": "/usr/share/elasticsearch/data",
        "readOnly": false
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group_name}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "collectionspace"
      }
    }
  }
]
