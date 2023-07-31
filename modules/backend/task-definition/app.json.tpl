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
        "name": "ECS_FARGATE_ENABLED",
        "value": "true"
      },
      {
        "name": "S3_BINARY_MANAGER_BUCKET",
        "value": "${s3_storage_bucket}"
      },
      {
        "name": "S3_BINARY_MANAGER_ENABLED",
        "value": "true"
      }
    ],
    "secrets": [
      {
        "name": "S3_BINARY_MANAGER_ID",
        "valueFrom": "${aws_storage_key}"
      },
      {
        "name": "S3_BINARY_MANAGER_SECRET",
        "valueFrom": "${aws_storage_secret_key}"
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
        "value": "-Xms{$elasticsearch_memory}m -Xmx${elasticsearch_memory}m"
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${searchstore}",
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
    ]
  }
]
