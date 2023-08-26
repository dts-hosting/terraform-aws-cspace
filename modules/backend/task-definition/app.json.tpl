[
  {
    "name": "app",
    "image": "${img}",
    "networkMode": "awsvpc",
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port}
      }
    ],
    "environment": [
      {
        "name": "CATALINA_OPTS",
        "value": "-Djava.awt.headless=true -Dfile.encoding=UTF-8 -server -Duser.timezone=${timezone} -Xmx${cspace_memory}m -Xms${cspace_memory}m -XX:MaxPermSize=384m"
      },
      {
        "name": "CREATE_DB",
        "value": "${create_db}"
      },
      {
        "name": "CSPACE_UI_BUILD",
        "value": "${cspace_ui_build}"
      },
      {
        "name": "ES_HOST",
        "value": "http://localhost:9200"
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
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 9200
      },
      {
        "containerPort": 9300
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
        "sourceVolume": "${es_efs_name}",
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
