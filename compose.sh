#!/bin/sh

CONTAINER_UID=${UID} CONTAINER_GID=${GID} docker compose $@
