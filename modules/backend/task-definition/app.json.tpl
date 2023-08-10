[
  {
    "name": "app",
    "image": "${img}",
    "networkMode": "awsvpc",
    "essential": true,
    "cpu": ${cpu},
    "memoryReservation": ${total_memory},
    "portMappings": [
      {
        "containerPort": ${container_port}
      }
    ],
    "environment": [
      {
        "name": "CREATE_DB",
        "value": "${create_db}"
      },
      {
        "name": "CSPACE_UI_BUILD",
        "value": "${cspace_ui_build}"
      },
      {
        "name": "S3_BINARY_MANAGER_ENABLED",
        "value": "true"
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
  },
  {
    "name": "elasticsearch",
    "image": "elasticsearch:5.6.16",
    "portMappings": [
      {
        "containerPort": 9200,
        "hostPort": 9200
      },
      {
        "containerPort": 9300,
        "hostPort": 9300
      }
    ],
    "environment": [
      {
        "name": "ES_JAVA_OPTS",
        "value": "-Xms${elasticsearch_memory}m -Xmx${elasticsearch_memory}m"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${efs_name}",
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
