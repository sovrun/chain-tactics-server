ROOT_DIR=$(pwd)

CTSC_PATH="$ROOT_DIR/tactics-war-sc/"
CTSC_DEPLOY_PATH="$ROOT_DIR/tactics-war-sc/packages/contracts"

# Install packages and run deploy contract
echo "Running pnpm install in $CTSC_PATH..."
cd "$CTSC_PATH" || { echo "Failed to navigate to $CTSC_PATH"; exit 1; }
npm install -g pnpm@8.15.8
pnpm install || { echo "pnpm install failed"; exit 1; }

echo "Deploying contract $CTSC_DEPLOY_PATH..."
cd "$CTSC_DEPLOY_PATH" || { echo "Failed to navigate to $CTSC_DEPLOY_PATH"; exit 1; }
pnpm run dev
