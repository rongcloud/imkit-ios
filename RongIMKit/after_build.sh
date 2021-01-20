#!/bin/sh

echo "imkit build: copy framework to bin"

BIN_DIR="bin"
if [ ! -d "$BIN_DIR" ]; then
mkdir -p "$BIN_DIR"
fi

BIN_DIR_TMP="bin_tmp"
if [ ! -d "$BIN_DIR_TMP" ]; then
mkdir -p "$BIN_DIR_TMP"
fi

rm -rf  ${BIN_DIR}/RongCloud.bundle
cp -af ./${TARGET_NAME}/Resource/RongCloud.bundle ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/en.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/zh-Hans.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ar.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/Emoji.plist ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/RCColor.plist ${BIN_DIR}/
cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR_TMP}/${PLATFORM_NAME}-${TARGET_NAME}.framework
cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR}/${TARGET_NAME}.framework
lipo -create $BIN_DIR_TMP/*-${TARGET_NAME}.framework/${TARGET_NAME} -output ${BIN_DIR}/${TARGET_NAME}.framework/${TARGET_NAME}

# 给 SDK 签名
codesign -fs - ${BIN_DIR}/${TARGET_NAME}.framework
# 打印签名信息
codesign -dvvv ${BIN_DIR}/${TARGET_NAME}.framework

echo "------imkit build end ----------------"
