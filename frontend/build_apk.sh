#!/bin/bash
set -e

echo "🚀 Building Muse APK"
echo "===================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed!${NC}"
    echo "Install from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Environment (default: prod)
ENV=${1:-prod}
API_URL=${2:-}

echo -e "${YELLOW}Environment: $ENV${NC}"
if [ -n "$API_URL" ]; then
    echo -e "${YELLOW}API URL: $API_URL${NC}"
fi

echo -e "${YELLOW}Step 1: Cleaning previous builds...${NC}"
flutter clean

echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get

echo -e "${YELLOW}Step 3: Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

echo -e "${YELLOW}Step 4: Building release APK...${NC}"
if [ -n "$API_URL" ]; then
    flutter build apk --release --dart-define=ENV=$ENV --dart-define=API_URL=$API_URL
else
    flutter build apk --release --dart-define=ENV=$ENV
fi

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo ""
    echo -e "${GREEN}✓ Build successful!${NC}"
    echo -e "${GREEN}✓ APK: $APK_PATH${NC}"
    echo -e "${GREEN}✓ Size: $APK_SIZE${NC}"
    echo ""
    echo "Install on device:"
    echo "  adb install $APK_PATH"
    echo ""
    echo "Or copy to phone and install manually."
else
    echo -e "${RED}✗ Build failed!${NC}"
    exit 1
fi
