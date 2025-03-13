#!/bin/bash
set -e

# Change to the project directory
cd /app

# Install dependencies if not already installed
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm ci
fi

# Build TypeScript
echo "Building TypeScript..."
node --max_old_space_size=2048 ./node_modules/.bin/tsc

# Create deployment package
echo "Creating deployment package..."
cd dist
zip -r ../lambda-deployment.zip .
cd ..
zip -g lambda-deployment.zip node_modules/**

echo "Build completed successfully!"
