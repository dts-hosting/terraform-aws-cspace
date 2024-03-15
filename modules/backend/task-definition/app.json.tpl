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
        "value": "${elasticsearch_url}"
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
    },
    "mountPoints": [
      {
        "sourceVolume": "${name}-apachetmp",
        "containerPath": "/apache-tomcat-8.5.51/temp"
      },
      {
        "sourceVolume": "${name}-nuxeoserver",
        "containerPath": "/apache-tomcat-8.5.51/nuxeo-server"
      }
    ]
  }
]
