////
////  RCForwardManagerTests.m
////  RongIMKitTests
////
////  Created by 杜立召 on 2020/3/5.
////  Copyright © 2020 RongCloud. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import "RCForwardManager.h"
//#import "RCTestHelper.h"
//#import "RCMessageModel.h"
//#import "RCUserInfoCacheManager.h"
//
//@interface RCForwardManagerTests : XCTestCase
//@property(nonatomic,strong)RCForwardManager *instance;
//@end
//
//@implementation RCForwardManagerTests
//
//- (void)setUp {
//    // Put setup code here. This method is called before the invocation of each test method in the class.
////    self.instance = [RCForwardManager sharedInstance];
//    XCTAssertNotNil(self.instance);
//}
//
//- (void)testMethodWithNil {
////    [RCTestHelper excuteMethodArgumentWithNil:self.instance];
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
//-(void)testDoForwardMessageList{
//    [self.instance doForwardMessageList:nil conversationList:nil isCombine:YES forwardConversationType:ConversationType_PRIVATE completed:^(BOOL success) {
//        XCTAssertFalse(success);
//    }];
//    RCMessage *txtMsg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTextMessage messageWithContent:@"11"]];
//    RCMessageModel *txtMsgModel = [[RCMessageModel alloc]initWithMessage:txtMsg];
//    txtMsgModel.senderUserId = @"111";
//    txtMsgModel.objectName = [RCTextMessage getObjectName];
//    RCMessage *gifMsg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getGifMessage]];
//    RCMessageModel *gifMsgModel = [[RCMessageModel alloc]initWithMessage:gifMsg];
//    gifMsgModel.senderUserId = @"111";
//    gifMsgModel.objectName = [RCGIFMessage getObjectName];
//    RCMessage *fileMsg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getFileMessage]];
//    RCMessageModel *fileMsgModel = [[RCMessageModel alloc]initWithMessage:fileMsg];
//    fileMsgModel.senderUserId = @"111";
//    fileMsgModel.objectName = [RCFileMessage getObjectName];
//    RCMessage *sightMsg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getSightMessage]];
//    RCMessageModel *sightMsgModel = [[RCMessageModel alloc]initWithMessage:sightMsg];
//    sightMsgModel.senderUserId = @"111";
//    sightMsgModel.objectName = [RCSightMessage getObjectName];
//
//    RCMessage *imgMsg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getImageMessage]];
//    RCMessageModel *imgMsgModel = [[RCMessageModel alloc]initWithMessage:imgMsg];
//    imgMsgModel.senderUserId = @"111";
//    imgMsgModel.objectName = [RCImageMessage getObjectName];
//
//    RCConversation *conversation = [[RCConversation alloc]init];
//    conversation.conversationType = ConversationType_PRIVATE;
//    conversation.targetId = @"111";
//    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
//    [[RCUserInfoCacheManager sharedManager] setAppKey:@"8luwapkvucoil"];
//    [[RCUserInfoCacheManager sharedManager] setCurrentUserId:@"1111"];
//    RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:@"111" name:@"111" portrait:@"11"];
//    [[RCUserInfoCacheManager sharedManager]updateUserInfo:user forUserId:user.userId];
//    [self.instance doForwardMessageList:@[txtMsgModel,fileMsgModel,sightMsgModel,gifMsgModel] conversationList:@[conversation] isCombine:YES forwardConversationType:ConversationType_PRIVATE completed:^(BOOL success) {
//        XCTAssertTrue(success);
//    }];
//}
//
//- (void)testDoForwardMessageList_1{
//    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getGifMessage]];
//    RCMessageModel *model = [[RCMessageModel alloc]initWithMessage:msg];
//    NSMutableArray *msgs = [NSMutableArray new];
//    [msgs addObject:model];
//    [self.instance doForwardMessageList:nil conversationList:nil isCombine:YES forwardConversationType:ConversationType_PRIVATE completed:nil];
//}
//
//@end
