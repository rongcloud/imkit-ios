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

if [ ! -d "$BIN_DIR_TMP/${PLATFORM_NAME}.sdk" ]; then
mkdir -p "$BIN_DIR_TMP/${PLATFORM_NAME}.sdk"
fi

rm -rf  ${BIN_DIR}/RongCloud.bundle
cp -af ./${TARGET_NAME}/Resource/RongCloud.bundle ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/en.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/zh-Hans.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/ar.lproj ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/Emoji.plist ${BIN_DIR}/
cp -af ./${TARGET_NAME}/Resource/RCColor.plist ${BIN_DIR}/


cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR}/${TARGET_NAME}.framework
cp -af ${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.framework/ ${BIN_DIR_TMP}/${PLATFORM_NAME}.sdk/${TARGET_NAME}.framework
lipo -create $BIN_DIR_TMP/*.sdk/${TARGET_NAME}.framework/${TARGET_NAME} -output ${BIN_DIR}/${TARGET_NAME}.framework/${TARGET_NAME}

# 给 SDK 签名
codesign -fs - ${BIN_DIR}/${TARGET_NAME}.framework
# 打印签名信息
codesign -dvvv ${BIN_DIR}/${TARGET_NAME}.framework

# 确定是否编译 xcframework
if [ ${RC_BUILD_XCFRAMEWORK} ] && [ ${RC_BUILD_XCFRAMEWORK} = "true" ];then
    echo "▸ ${TARGET_NAME} build xcframework : YES"
else
    echo "▸ ${TARGET_NAME} build xcframework : NO"
    exit 0
fi

# xcframework 生成

FRAMEWORK_COUNT=`ls -lah ${BIN_DIR_TMP} | grep ".sdk" | wc -l`
echo "▸ match sdk count $FRAMEWORK_COUNT"

IOS_PATH=${BIN_DIR_TMP}/iphoneos.sdk/${TARGET_NAME}.framework
SIMULATOR_PATH=${BIN_DIR_TMP}/iphonesimulator.sdk/${TARGET_NAME}.framework

# 如果 xcframework 已经存在，那么就删除了，生成新的 xcframework
if [ -d "${BIN_DIR}/${TARGET_NAME}.xcframework" ]; then
    rm -rf "${BIN_DIR}/${TARGET_NAME}.xcframework"
fi

# 如果只有一种架构的情况下，默认真机架构，如果模拟器架构存在，那么说明只是模拟架构
if [ $FRAMEWORK_COUNT -eq 1 ]; then
    echo "▸ build xcframework for ${FRAMEWORK_COUNT} arch"

    EXIST_FRAMEWORK=${IOS_PATH}
    if [ -d ${SIMULATOR_PATH} ];then
        EXIST_FRAMEWORK=${SIMULATOR_PATH}
    fi

    echo "▸ exist framework ${EXIST_FRAMEWORK}"

    xcodebuild -create-xcframework \
        -framework "${EXIST_FRAMEWORK}" \
        -output "${BIN_DIR}/${TARGET_NAME}.xcframework"
fi

# 如果两种架构的情况下直接合并 xcframework
if [ $FRAMEWORK_COUNT -eq 2 ]; then
    echo "▸ build xcframework for ${FRAMEWORK_COUNT} arch"
    xcodebuild -create-xcframework \
        -framework ${IOS_PATH} \
        -framework ${SIMULATOR_PATH} \
        -output "${BIN_DIR}/${TARGET_NAME}.xcframework"
fi

#codesign xcframework
#codesign 真机
XCFRAMEWORK_IOS="$BIN_DIR/$TARGET_NAME.xcframework/ios-arm*/$TARGET_NAME.framework"

if [ -d $XCFRAMEWORK_IOS ]; then
echo "▸ codesign ${XCFRAMEWORK_IOS}"
# 给 SDK 签名
codesign -fs - ${XCFRAMEWORK_IOS}
echo "▸ codesign info ${XCFRAMEWORK_IOS}"
# 打印签名信息
codesign -dvvv ${XCFRAMEWORK_IOS}
fi

#codesign 模拟器
XCFRAMEWORK_SIMULATOR="$BIN_DIR/$TARGET_NAME.xcframework/ios-*simulator/$TARGET_NAME.framework"

if [ -d $XCFRAMEWORK_SIMULATOR ]; then
echo "▸ codesign ${XCFRAMEWORK_SIMULATOR}"
# 给 SDK 签名
codesign -fs - ${XCFRAMEWORK_SIMULATOR}
echo "▸ codesign info ${XCFRAMEWORK_SIMULATOR}"
# 打印签名信息
codesign -dvvv ${XCFRAMEWORK_SIMULATOR}
fi

echo "------imkit build end ----------------"
