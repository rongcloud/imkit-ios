#!/bin/sh
echo "------imkit build start ----------------"

KIT_FRAMEWORKER_PATH="./framework"
if [ ! -d "$KIT_FRAMEWORKER_PATH" ]; then
    mkdir -p "$KIT_FRAMEWORKER_PATH"
fi

#copy imlib
IMLIB_PATH="../imlib"
if [ -d ${IMLIB_PATH}/bin ]; then
   echo "imkit build: copy imlib"
   cp -af ${IMLIB_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

#copy imlibcore
IMLIBCORE_PATH="../imlibcore"
if [ -d ${IMLIBCORE_PATH}/ ]; then
   echo "imkit build: copy imlibcore"
   cp -af ${IMLIBCORE_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
   cp -af ${IMLIBCORE_PATH}/RongIMLibCore/RCDownloadHelper.h "./RongIMKit/Utility/RCloudImageLoading/"
fi

#copy chatroom
CHATROOM_PATH="../chatroom"
if [ -d ${CHATROOM_PATH}/bin ]; then
   echo "imkit build: copy chatroom"
   cp -af ${CHATROOM_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

#copy discussion
DISCUSSION_PATH="../discussion"
if [ -d ${DISCUSSION_PATH}/bin ]; then
   echo "imkit build: copy discussion"
   cp -af ${DISCUSSION_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

#copy publicservice
PUBLICSERVICE_PATH="../publicservice"
if [ -d ${PUBLICSERVICE_PATH}/bin ]; then
   echo "imkit build: copy publicservice"
   cp -af ${PUBLICSERVICE_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

#copy customerservice
CUSTOMERSERVICE_PATH="../customerservice"
if [ -d ${CUSTOMERSERVICE_PATH}/bin ]; then
   echo "imkit build: copy customerservice"
   cp -af ${CUSTOMERSERVICE_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

#copy location
REALTIMELOCATION_PATH="../location"
if [ -d ${REALTIMELOCATION_PATH}/bin ]; then
   echo "imkit build: copy location"
   cp -af ${REALTIMELOCATION_PATH}/bin/* ${KIT_FRAMEWORKER_PATH}/
fi

rm -rf ${KIT_FRAMEWORKER_PATH}/*.xcframework
