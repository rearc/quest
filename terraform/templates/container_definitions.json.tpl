[
    {
        "name": "${appName}",
        "image": "${appImage}:latest",
        "secrets": [],
        "environment": [
            {
                "name": "SECRET_WORD",
                "value": "${secretWord}"
            }
        ],
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