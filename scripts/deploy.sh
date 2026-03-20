#!/bin/bash
set -e

ENV=${1:-dev}
COMPOSE_FILE="/home/ec2-user/Expadox-devops-project-3/gitops/${ENV}/docker-compose.yml"

echo "Deploying ${ENV} environment..."
docker compose -f ${COMPOSE_FILE} pull
docker compose -f ${COMPOSE_FILE} up -d --remove-orphans

echo "Deploy complete. Running containers:"
docker compose -f ${COMPOSE_FILE} ps
