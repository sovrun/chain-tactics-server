##!/bin/bash

# Define paths
## Store the root directory
ROOT_DIR=$(pwd)

CTCOMMON_PATH="$ROOT_DIR/tactics-war-server/CTCommon"
CTHEADLESS_PATH="$ROOT_DIR/tactics-war-server/CTHeadless"
CTSERVER_PATH="$ROOT_DIR/tactics-war-server/CTServer"

# Run dotnet build
echo "Building $CTCOMMON_PATH..."
cd "$CTCOMMON_PATH" || { echo "Failed to navigate to $CTCOMMON_PATH"; exit 1; }
dotnet build || { echo "dotnet build failed"; exit 1; }

# Run dotnet build
echo "Building $CTHEADLESS_PATH..."
cd "$CTHEADLESS_PATH" || { echo "Failed to navigate to $CTHEADLESS_PATH"; exit 1; }
dotnet build || { echo "dotnet build failed"; exit 1; }

echo "Building $CTSERVER_PATH..."
cd "$CTSERVER_PATH" || { echo "Failed to navigate to $CTSERVER_PATH"; exit 1; }
dotnet run 127.0.0.1:8545 || { echo "dotnet build failed"; exit 1; }
