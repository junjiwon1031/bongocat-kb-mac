#!/bin/bash
set -euo pipefail

APP_NAME="BongoCatNoMouse"
BUNDLE_ID="com.bongocat.nomouse"
BUILD_DIR=".build/release"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
INSTALL_DIR="$HOME/Applications"

echo "Building..."
swift build -c release

echo "Creating app bundle..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
cp -R "${BUILD_DIR}/${APP_NAME}_${APP_NAME}.bundle" "${APP_DIR}/Contents/Resources/"
cp BongoCatNoMouse/Info.plist "${APP_DIR}/Contents/Info.plist"

echo "Installing to ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"
rm -rf "${INSTALL_DIR}/${APP_NAME}.app"
cp -R "${APP_DIR}" "${INSTALL_DIR}/${APP_NAME}.app"

echo "Resetting Accessibility permission..."
tccutil reset Accessibility com.bongocat.nomouse

echo "Done! App installed at: ${INSTALL_DIR}/${APP_NAME}.app"
echo "Run: open \"${INSTALL_DIR}/${APP_NAME}.app\""
