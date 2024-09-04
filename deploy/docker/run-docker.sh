#!/usr/bin/env bash

# Run this from root directory

# Exit on error and print the command that causes the failure
set -euo pipefail

# Define variables for directories
SOURCE_DIR="${PWD}/source"
BUILD_DIR="${PWD}/build"
DOCKER_IMAGE="qgc-ubuntu-docker"
DOCKER_FILE="./deploy/docker/Dockerfile-build-ubuntu"

# Ensure the directories exist
mkdir -p "$BUILD_DIR"
mkdir -p "$SOURCE_DIR"

# Build the Docker image
echo "Building Docker image from $DOCKER_FILE..."
docker build --file "$DOCKER_FILE" -t "$DOCKER_IMAGE" .

# Run the Docker container with reduced privileges
# Only add the SYS_ADMIN and FUSE capabilities if absolutely necessary
echo "Running Docker container..."
docker run --rm \
    --cap-add=SYS_ADMIN \
    --device=/dev/fuse \
    --security-opt apparmor=unconfined \
    -v "$PWD:/project/source" \
    -v "$BUILD_DIR:/project/build" \
    "$DOCKER_IMAGE"

# Check if the run was successful
if [ $? -eq 0 ]; then
    echo "Docker container executed successfully."
else
    echo "Docker container failed to execute." >&2
    exit 1
fi

