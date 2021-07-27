[
    {
        "name": "${appName}",
        "image": "${appImage}:latest",
        "secrets": [],
        "environment": [],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/${appName}",
                "awslogs-region": "${region}",
                "awslogs-stream-prefix": "ecs"
            }
        },
        "portMappings": [
            {
                "containerPort": 3000
            }
        ]
    }
]