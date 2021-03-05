//
//  RCIMTests.m
//  RongIMKit
//
//  Created by 杜立召 on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCIM.h"
#import <objc/runtime.h>
#import "RCTestHelper.h"

@interface RCIMClient (kittest)
- (void)handleAppSuspend;
@end

@interface RCIM (test)
- (void)resetNotificationQuietStatus;
- (BOOL)checkNoficationQuietStatus;
- (void)getNotificationInfo:(RCMessage *)message
                     result:(void (^)(NSString *senderName, NSString *formatedMessage))resultBlock;
- (NSString *)formatGroupNotification:(RCMessage *)message
                                group:(RCGroup *)groupInfo
                                 user:(RCUserInfo *)userInfo
                          showMessage:(NSString *)showMessage;

- (NSString *)formatDiscussionNotification:(RCMessage *)message
                                discussion:(RCDiscussion *)discussion
                               showMessage:(NSString *)showMessage;

- (NSString *)formatOtherNotification:(RCMessage *)message name:(NSString *)name showMessage:(NSString *)showMessage;

- (void)postLocalNotificationIfNeed:(RCMessage *)message;
@property (nonatomic, strong) NSDate *notificationQuietBeginTime;
@property (nonatomic, strong) NSDate *notificationQuietEndTime;

@end

@interface RCIMTests : XCTestCase
@property (nonatomic) long imageMessageId;
@end

@implementation RCIMTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[RCIM sharedRCIM] initWithAppKey:@"8luwapkvucoil"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testCase001_initWithAppKey {
//    [[RCIM sharedRCIM] initWithAppKey:@"test"];
}

- (void)testCase001_initWithAppKey_EdgeCase {
//    [[RCIM sharedRCIM] initWithAppKey:nil];
//    [[RCIM sharedRCIM] initWithAppKey:@""];
//    [[RCIM sharedRCIM] initWithAppKey:@"\\n"];
//    [[RCIM sharedRCIM] initWithAppKey:@"\\*#$%^^&Y*&(&*&&^^$%^%&%&*\""];
//    [[RCIM sharedRCIM] initWithAppKey:@"8luwapkvucoil"];
}

- (void)testCase003_connectWithToken_EdgeCase {
    //token格式非法，应该直接返回参数错误
//    [[RCIM sharedRCIM] connectWithToken:nil success:^(NSString *userId) {
//        XCTAssert(@"token格式非法，不应该connect成功!!!");
//    } error:^(RCConnectErrorCode status) {
//        XCTAssertEqual(RC_INVALID_ARGUMENT, status);
//    } tokenIncorrect:^{
//        XCTAssert(@"token格式非法，不应该去连接服务器才返回tokenIncorrect!!!");
//    }];
}


- (void)testAConnect {
//    [self Connect:nil isErrorCase:YES];
//    [self Connect:@"" isErrorCase:YES];
//    [self Connect:@"fhdh" isErrorCase:YES];
    [[RCIM sharedRCIM] initWithAppKey:@"8luwapkvucoil"];
    [self Connect:@"MCS/xTJVYgn1mYXt8hUgr8SkAMimzaj6nB20cRPaYWTXyVseRNXwW8pRsePzbG+WtJro0iBg7yHet9+n3vqzcw=="];
//    [self Connect:@"MCS/xTJVYgn1mYXt8hUgr8SkAMimzaj6nB20cRPaYWTXyVseRNXwW8pRsePzbG+WtJro0iBg7yHet9+n3vqzcw==" isErrorCase:NO];
//    [self Connect:@"ouhnVF1MD59bjfIAQLOAqHb+YOC+D34O5m6o8KS7umkitWateXu93K3qI7Nqy05+Hg8qIkKlvt/1nqyl5kCf5Qe2Wje2Owgs" isErrorCase:NO];
}

-(void)Connect:(NSString *)token{
    XCTestExpectation* expectation = [self expectationWithDescription:@"ConnectExpectation"];
     __block BOOL isConnectSuccess = NO;
     __block BOOL isTokenIncorrect = NO;
     __block dispatch_semaphore_t t = dispatch_semaphore_create(0);
    const char *_Nullable queueName= [token UTF8String];
    dispatch_queue_t queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block = dispatch_block_create(0, ^{
        if([[RCIM sharedRCIM]getConnectionStatus]==ConnectionStatus_Connected){
            [[RCIM sharedRCIM] disconnect];
        }
        [[RCIM sharedRCIM] connectWithToken:token
            success:^(NSString *userId) {
                [expectation fulfill];
                XCTAssert(userId.length > 0);
                isConnectSuccess = YES;
                dispatch_semaphore_signal(t);
            }
            error:^(RCConnectErrorCode status) {
                [expectation fulfill];
                isConnectSuccess = NO;
                dispatch_semaphore_signal(t);
            }
            tokenIncorrect:^{
                [expectation fulfill];
                isTokenIncorrect =  YES;
                dispatch_semaphore_signal(t);
            }];
        dispatch_semaphore_wait(t, DISPATCH_TIME_FOREVER);
    });
     dispatch_async(queue, block);
     [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {

     }];
}

- (void)testRegisterMessageType {
    [[RCIM sharedRCIM] registerMessageType:[RCTextMessage class]];
    [[RCIM sharedRCIM] registerMessageType:nil];
}


- (void)testSendMessage {
    //测试有效参数
    XCTestExpectation *sendMessageExp = [self expectationWithDescription:@"sendMessage"];
    
    if([[RCIM sharedRCIM]getConnectionStatus] !=ConnectionStatus_Connected){
        sleep(10);
    }
    [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE
                    targetId:@"111"
                     content:[RCTestHelper getTextMessage]
                 pushContent:nil
                    pushData:nil
                     success:^(long messageId) {
                         [sendMessageExp fulfill];
                         XCTAssertGreaterThan(messageId, 0, @"Send message successfully");
                     }
                       error:^(RCErrorCode nErrorCode, long messageId) {
                           [sendMessageExp fulfill];
                           NSLog(@"【Error】==================%ld", (long)nErrorCode);
                           XCTFail(@"Send message failed");
                       }];
    
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】sendTextMessageExp fulfilled");
    }];
    
}

- (void)testSendDirectionalMessage {
    XCTestExpectation *sendDirectionalMessageExp = [self expectationWithDescription:@"sendDirectionalMessageExp"];
    sleep(5);
    [[RCIM sharedRCIM] sendDirectionalMessage:ConversationType_GROUP targetId:@"11" toUserIdList:@[@"111"] content:[RCTestHelper getTextMessage] pushContent:nil pushData:nil success:^(long messageId) {
        [sendDirectionalMessageExp fulfill];
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"【Error】*******%ld",(long)nErrorCode);
        [sendDirectionalMessageExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】sendDirectionalMessageExp fulfilled");
    }];
}


- (void)testSendDirectionalMessageErrorBlock {
    XCTestExpectation *sendDirectionalMessageExp = [self expectationWithDescription:@"sendDirectionalMessageExp"];
    [[RCIM sharedRCIM] sendDirectionalMessage:ConversationType_GROUP targetId:@"111" toUserIdList:@[] content:[RCTestHelper getTextMessage] pushContent:nil pushData:nil success:^(long messageId) {

    } error:^(RCErrorCode nErrorCode, long messageId) {
        [sendDirectionalMessageExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】sendDirectionalMessageExp fulfilled");
    }];
}

- (void)testInvalidSendDirectionalMessage {
    XCTAssertNil([[RCIM sharedRCIM] sendDirectionalMessage:ConversationType_GROUP targetId:nil toUserIdList:nil content:nil pushContent:nil pushData:nil success:nil error:nil]);
    
    XCTAssertNil([[RCIM sharedRCIM] sendDirectionalMessage:ConversationType_GROUP targetId:@"222" toUserIdList:@[] content:[RCTestHelper getTextMessage] pushContent:nil pushData:nil success:nil error:nil]);
}

/**
 测试 sendMediaMessage（媒体消息）
 */
- (void)testSendMediaMessage {
    XCTestExpectation *sendMediaMessageExp = [self expectationWithDescription:@"sendMediaMessageExp"];
    sleep(1);
    [[RCIM sharedRCIM] sendMediaMessage:ConversationType_PRIVATE
                         targetId:@"111"
                          content:[RCTestHelper getImageMessage]
                      pushContent:nil
                         pushData:nil
                         progress:^(int progress, long messageId) {
                             
                         } success:^(long messageId) {
                             self.imageMessageId = messageId;
                             [sendMediaMessageExp fulfill];
                             XCTAssertGreaterThan(messageId, 0, @"Send image message successfully");
                         } error:^(RCErrorCode errorCode, long messageId) {
                             [sendMediaMessageExp fulfill];
                             NSLog(@"【Error】==================%ld", (long)errorCode);
                             XCTFail(@"Send image message failed");
                         } cancel:^(long messageId) {
                             [sendMediaMessageExp fulfill];
                         }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】sendMediaMessageExp fulfilled");
    }];
}

/**
 测试 cancelSendMediaMessage
 */
- (void)testCancelSendMediaMessage {
    RCMessage *message = [[RCIM sharedRCIM] sendMediaMessage:ConversationType_PRIVATE
                                              targetId:@"111"
                                               content:[RCTestHelper getImageMessage]
                                           pushContent:nil
                                              pushData:nil
                                              progress:^(int progress, long messageId) {
                                                  
                                              } success:^(long messageId) {
                                                  XCTFail(@"Cancel send image message failed");
                                              } error:^(RCErrorCode errorCode, long messageId) {
                                                  XCTFail(@"Send image message failed %ld",(long)errorCode);
                                              } cancel:^(long messageId) {
                                                  XCTAssertGreaterThan(messageId, 0, @"Cancel send image message successfully");
                                              }];
    BOOL isCancel = [[RCIM sharedRCIM] cancelSendMediaMessage:message.messageId];
    XCTAssertTrue(isCancel);
}

- (void)testSendMessage:(RCConversationType)conversationType targetId:(NSString *)targetId content:(RCMessageContent *)content exp:(XCTestExpectation *)exp{
    RCMessage *message = [[RCIM sharedRCIM] sendMessage:conversationType
                                         targetId:targetId
                                          content:content
                                      pushContent:nil
                                         pushData:nil
                                          success:^(long messageId) {
                                              [exp fulfill];
                                              XCTFail(@"Not expecting result");
                                          }
                                            error:^(RCErrorCode nErrorCode, long messageId) {
                                                [exp fulfill];
                                                XCTAssertEqual(messageId, 0);
                                                XCTAssertEqual(nErrorCode, INVALID_PARAMETER);
                                            }];
    XCTAssertNil(message);
}

- (void)testSendMediaMessage:(RCConversationType)conversationType targetId:(NSString *)targetId content:(RCMessageContent *)content exp:(XCTestExpectation *)exp{
    RCMessage *message = [[RCIM sharedRCIM] sendMediaMessage:conversationType
                                              targetId:targetId
                                               content:content
                                           pushContent:nil
                                              pushData:nil
                                              progress:^(int progress, long messageId) {
                                                  [exp fulfill];
                                                  XCTFail(@"Not expecting result");
                                              }
                                               success:^(long messageId) {
                                                   [exp fulfill];
                                                   XCTFail(@"Not expecting result");
                                               }
                                                 error:^(RCErrorCode errorCode, long messageId) {
                                                     [exp fulfill];
                                                     XCTAssertEqual(messageId, 0);
                                                     XCTAssertEqual(errorCode, INVALID_PARAMETER);
                                                 }
                                                cancel:^(long messageId) {
                                                    [exp fulfill];
                                                    XCTFail(@"Not expecting result");
                                                }];
    XCTAssertNil(message);
}


- (void)testSetCurrentUserInfo{
    RCUserInfo *currentUserInfo = [[RCUserInfo alloc]initWithUserId:@"" name:@"" portrait:@""];
    XCTAssertNotNil([[RCIM sharedRCIM]currentUserInfo]);
    [[RCIM sharedRCIM]setCurrentUserInfo:nil];
    [[RCIM sharedRCIM]setCurrentUserInfo:currentUserInfo];
    XCTAssertNotNil([[RCIM sharedRCIM]currentUserInfo]);
    currentUserInfo = [[RCUserInfo alloc]initWithUserId:nil name:nil portrait:@""];
    [[RCIM sharedRCIM]setCurrentUserInfo:currentUserInfo];
    XCTAssertNotNil([[RCIM sharedRCIM]currentUserInfo]);
}

-(void)testResetNotificationQuietStatus{
    [[RCIM sharedRCIM] resetNotificationQuietStatus];
    XCTAssertFalse([[RCIM sharedRCIM]checkNoficationQuietStatus]);// TODO：根据时间来计算
}

-(void)testGetNotificationInfo{
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getTextMessage]];
    [[RCIM sharedRCIM]getNotificationInfo:message result:^(NSString *senderName, NSString *formatedMessage) {
        XCTAssertNotNil(senderName);
        XCTAssertNotNil(formatedMessage);
    }];
}

- (void)testDownloadMediaMessage{
    XCTestExpectation *downloadMediaMessageExp = [self expectationWithDescription:@"downloadMediaMessageExp"];
    [[RCIM sharedRCIM]downloadMediaMessage:self.imageMessageId progress:^(int progress) {
        
    } success:^(NSString *mediaPath) {
        [downloadMediaMessageExp fulfill];
        XCTAssertNotNil(mediaPath);
    } error:^(RCErrorCode errorCode) {
        NSLog(@"【Error】downloadMediaMessageExp errorCode %ld",errorCode);
        [downloadMediaMessageExp fulfill];
    } cancel:^{
        [downloadMediaMessageExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】downloadMediaMessageExp fulfilled");
    }];
}

- (void)testCancelDownloadMediaMessage{
    [[RCIM sharedRCIM]cancelSendMediaMessage:self.imageMessageId];
}

- (void)testSendImageMessage{
    XCTestExpectation *sendMediaMessageExp = [self expectationWithDescription:@"sendMediaMessageExp"];
    sleep(1);
    [[RCIM sharedRCIM] sendImageMessage:ConversationType_PRIVATE
                         targetId:@"111"
                          content:[RCTestHelper getImageMessage]
                      pushContent:nil
                         pushData:nil
                         progress:^(int progress, long messageId) {
                             
                         } success:^(long messageId) {
                             self.imageMessageId = messageId;
                             [sendMediaMessageExp fulfill];
                             XCTAssertGreaterThan(messageId, 0, @"Send image message successfully");
                         } error:^(RCErrorCode errorCode, long messageId) {
                             [sendMediaMessageExp fulfill];
                             NSLog(@"【Error】==================%ld", (long)errorCode);
                             XCTFail(@"Send image message failed");
                         }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】sendMediaMessageExp fulfilled");
    }];
}

- (void)createDiscussion{
    XCTestExpectation *exp = [self expectationWithDescription:@"sendMediaMessageExp"];
    NSMutableArray *userList = [NSMutableArray new];
    [userList addObject:@"111"];
    [[RCIM sharedRCIM]createDiscussion:@"111" userIdList:userList success:^(RCDiscussion *discussion) {
        XCTAssertNotNil(discussion);
        [exp fulfill];
    } error:^(RCErrorCode status) {
        NSLog(@"【Error】==================%ld", (long)status);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】exp fulfilled");
    }];
}

- (void)addMemberToDiscussion{
    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];
    
    NSMutableArray *userList = [NSMutableArray new];
    [userList addObject:@"2222"];
    [[RCIM sharedRCIM]addMemberToDiscussion:@"111" userIdList:userList success:^(RCDiscussion *discussion) {
        XCTAssertNotNil(discussion);
        [exp fulfill];
    } error:^(RCErrorCode status) {
        NSLog(@"【Error】==================%ld", (long)status);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】exp fulfilled");
    }];
}

- (void)testAddMemberToDiscussionErrorBlock {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"addDiscussionMemberExp"];
    [[RCIM sharedRCIM]  addMemberToDiscussion:@"111" userIdList:@[@"444"] success:nil error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】addDiscussionMemberExp fulfilled");
    }];
}

- (void)testInvalidAddDiscussionMemeber {
//    __block int testValue = 0;
//    XCTestExpectation *discussionExp = [self expectationWithDescription:@"addDiscussionMemberExp"];
//    [[RCIM sharedRCIM] addMemberToDiscussion:nil userIdList:@[@"444"] success:^(RCDiscussion *discussion) {
//        [discussionExp fulfill];
//    } error:^(RCErrorCode status) {
//        [discussionExp fulfill];
//    }];
//    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
//        NSLog(@"【Error】addDiscussionMemberExp fulfilled");
//    }];
    
}

- (void)testRemoveMemberFromDiscussion {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"removeDiscussionMemberExp"];
    [[RCIM sharedRCIM] createDiscussion:@"111" userIdList:@[@"111",@"222",@"333"] success:^(RCDiscussion *discussion) {
        [[RCIM sharedRCIM] removeMemberFromDiscussion:discussion.discussionId userId:@"222" success:^(RCDiscussion *discussion) {
            NSLog(@"【Error】=======success %@",discussion.discussionName);
            [discussionExp fulfill];
        } error:^(RCErrorCode status) {
            NSLog(@"【Error】=====error %ld", (long)status);
            [discussionExp fulfill];
        }];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】removeDiscussionMemberExp fulfilled");
    }];
}

- (void)testRemoveMemberToDiscussionErrorBlock {
//    XCTestExpectation *discussionExp = [self expectationWithDescription:@"removeDiscussionMemberExp"];
    [[RCIM sharedRCIM] removeMemberFromDiscussion:@"111" userId:@"222" success:^(RCDiscussion *discussion) {
//        [discussionExp fulfill];
    } error:^(RCErrorCode status) {
//        [discussionExp fulfill];
    }];
//    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
//        NSLog(@"【Error】removeDiscussionMemberExp fulfilled");
//    }];
}

- (void)testInvalidRemoveDiscussionMemeber {
    [[RCIM sharedRCIM] removeMemberFromDiscussion:nil userId:@"111" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] removeMemberFromDiscussion:@"" userId:@"111" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] removeMemberFromDiscussion:@"111" userId:@"1" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
//        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] removeMemberFromDiscussion:@"111" userId:@"" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
}

- (void)testQuitDiscussion {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"quitDiscussionExp"];
    [[RCIM sharedRCIM] createDiscussion:@"1111" userIdList:@[@"111",@"222",@"333"] success:^(RCDiscussion *discussion) {
        [[RCIM sharedRCIM] quitDiscussion:discussion.discussionId success:^(RCDiscussion *discussion) {
            [discussionExp fulfill];
        } error:^(RCErrorCode status) {
            [discussionExp fulfill];
        }];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】quitDiscussionExp fulfilled");
    }];
}

- (void)testQuitDiscussionErrorBlock {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"quitDiscussionExp"];
    [[RCIM sharedRCIM] quitDiscussion:@"aaaa" success:^(RCDiscussion *discussion) {
        [discussionExp fulfill];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】quitDiscussionExp fulfilled");
    }];
}

- (void)testInvalidQuitDiscussion {
    [[RCIM sharedRCIM] quitDiscussion:nil success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] quitDiscussion:@"" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
}

- (void)testGetDiscussion {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"getDiscussionExp"];
    [[RCIM sharedRCIM] createDiscussion:@"1111" userIdList:@[@"111"] success:^(RCDiscussion *discussion) {
        [[RCIM sharedRCIM] getDiscussion:discussion.discussionId success:^(RCDiscussion *discussion) {
            [discussionExp fulfill];
        } error:^(RCErrorCode status) {
            [discussionExp fulfill];
        }];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】getDiscussionExp fulfilled");
    }];
}

- (void)testGetDiscussionErrorBlock {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"getDiscussionExp"];
    [[RCIM sharedRCIM] getDiscussion:@"aaa" success:^(RCDiscussion *discussion) {
        [discussionExp fulfill];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】getDiscussionExp fulfilled");
    }];
}

- (void)testInvalidGetDiscussion {
    [[RCIM sharedRCIM] getDiscussion:nil success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] getDiscussion:@"" success:^(RCDiscussion *discussion) {
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
}

- (void)testSetDiscussionName {
    XCTestExpectation *discussionExp = [self expectationWithDescription:@"setDiscussionNameExp"];
    [[RCIM sharedRCIM] setDiscussionName:@"aaa" name:nil success:^{
        [discussionExp fulfill];
    } error:^(RCErrorCode status) {
        [discussionExp fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】setDiscussionNameExp fulfilled");
    }];
}


- (void)testInvalidSetDiscussionName {
    [[RCIM sharedRCIM] setDiscussionName:nil name:@"11" success:^{
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] setDiscussionName:@"" name:nil success:^{
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
}

//- (void)testSetDiscussionInviteStatusYES {
//    XCTestExpectation *discussionExp = [self expectationWithDescription:@"setDiscussionInviteStatuseExp"];
//    [[RCIM sharedRCIM] setDiscussionInviteStatus:@"aaa" isOpen:YES success:^{
//        [discussionExp fulfill];
//    } error:^(RCErrorCode status) {
//        [discussionExp fulfill];
//    }];
//    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
//        NSLog(@"【Error】setDiscussionInviteStatuseExp fulfilled");
//    }];
//}

- (void)testSetDiscussionInviteStatusErrorBlock {
//    XCTestExpectation *discussionExp = [self expectationWithDescription:@"setDiscussionInviteStatuseExp"];
    [[RCIM sharedRCIM] setDiscussionInviteStatus:@"aaa" isOpen:NO success:^{
//        [discussionExp fulfill];
    } error:^(RCErrorCode status) {
//        [discussionExp fulfill];
    }];
//    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
//        NSLog(@"【Error】setDiscussionInviteStatuseExp fulfilled");
//    }];
}

- (void)testInvalidSetDiscussionInviteStatus {
    [[RCIM sharedRCIM] setDiscussionInviteStatus:nil isOpen:YES success:^{
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
    [[RCIM sharedRCIM] setDiscussionInviteStatus:@"" isOpen:YES success:^{
        XCTFail(@"应该走失败");
    } error:^(RCErrorCode status) {
        XCTAssertEqual(status, INVALID_PARAMETER);
    }];
}


- (void)testRefreshUserInfoCache{
    [[RCIM sharedRCIM]refreshUserInfoCache:nil withUserId:nil];
    XCTAssertNil([[RCIM sharedRCIM]getUserInfoCache:nil]);
    RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:nil name:@"1" portrait:@""];
    [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:nil];
    user.userId = @"1";
    [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:nil];
    XCTAssertNotNil([[RCIM sharedRCIM]getUserInfoCache:@"1"]);
    [[RCIM sharedRCIM]refreshUserInfoCache:user withUserId:@"1"];
    XCTAssertNotNil([[RCIM sharedRCIM]getUserInfoCache:@"1"]);
    [[RCIM sharedRCIM]clearUserInfoCache];
    XCTAssertNil([[RCIM sharedRCIM]getUserInfoCache:@"1"]);
}

- (void)testRefreshGroupInfoCache{
    [[RCIM sharedRCIM]refreshGroupInfoCache:nil withGroupId:nil];
    XCTAssertNil([[RCIM sharedRCIM]getGroupInfoCache:nil]);
    RCGroup *group = [[RCGroup alloc]initWithGroupId:nil groupName:nil portraitUri:nil];
    [[RCIM sharedRCIM]refreshGroupInfoCache:group withGroupId:nil];
    group.groupId = @"1";
    [[RCIM sharedRCIM]refreshGroupInfoCache:group withGroupId:nil];
    XCTAssertNotNil([[RCIM sharedRCIM]getGroupInfoCache:@"1"]);
    [[RCIM sharedRCIM]refreshGroupInfoCache:group withGroupId:@"1"];
    XCTAssertNotNil([[RCIM sharedRCIM]getGroupInfoCache:@"1"]);
    [[RCIM sharedRCIM]clearGroupInfoCache];
    XCTAssertNil([[RCIM sharedRCIM]getGroupInfoCache:@"1"]);
}

- (void)testRefreshGroupUserInfoCache{
    [[RCIM sharedRCIM]refreshGroupUserInfoCache:nil withUserId:nil withGroupId:@"1"];
    XCTAssertNil([[RCIM sharedRCIM]getGroupUserInfoCache:nil withGroupId:@"1"]);
    RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:nil name:@"1" portrait:@""];
    [[RCIM sharedRCIM]refreshGroupUserInfoCache:user withUserId:nil withGroupId:@"1"];
    user.userId = @"1";
    [[RCIM sharedRCIM]refreshGroupUserInfoCache:user withUserId:@"1" withGroupId:@"1"];
//    XCTAssertNotNil([[RCIM sharedRCIM]getGroupUserInfoCache:@"1" withGroupId:@"1"]);
    [[RCIM sharedRCIM]clearGroupInfoCache];
    XCTAssertNil([[RCIM sharedRCIM]getGroupUserInfoCache:@"1" withGroupId:@"1"]);
}

- (void)testFormatGroupNotification{
    XCTAssertNotNil([[RCIM sharedRCIM]formatGroupNotification:nil group:nil user:nil showMessage:nil]);
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getTextMessage]];
    
    NSString *str = [[RCIM sharedRCIM]formatGroupNotification:message group:nil user:nil showMessage:nil];
    XCTAssertNotNil(str);
    
    RCMentionedInfo *mention = [[RCMentionedInfo alloc]initWithMentionedType:RC_Mentioned_All userIdList:nil mentionedContent:@""];
    message.content.mentionedInfo = mention;
    str = [[RCIM sharedRCIM]formatGroupNotification:message group:nil user:nil showMessage:nil];
    XCTAssertNil(str);

}

- (void)testFormatDiscussionNotification{
    XCTAssertNotNil([[RCIM sharedRCIM]formatDiscussionNotification:nil discussion:nil showMessage:nil]);
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getTextMessage]];
    
    NSString *str = [[RCIM sharedRCIM]formatDiscussionNotification:message discussion:nil  showMessage:nil];
    XCTAssertNotNil(str);
    
    RCMentionedInfo *mention = [[RCMentionedInfo alloc]initWithMentionedType:RC_Mentioned_All userIdList:nil mentionedContent:@""];
    message.content.mentionedInfo = mention;
    
    str = [[RCIM sharedRCIM]formatDiscussionNotification:message discussion:nil  showMessage:nil];
    XCTAssertNil(str);
}

- (void)testFormatOtherNotification{
    XCTAssertNotNil([[RCIM sharedRCIM]formatOtherNotification:nil name:nil showMessage:nil]);
     RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getTextMessage]];
    XCTAssertNotNil([[RCIM sharedRCIM]formatOtherNotification:message name:nil showMessage:nil]);
    
}

- (void)testPostLocalNotificationIfNeed{
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getTextMessage]];
    message.isOffLine = NO;
//    [RCIMClient sharedRCIMClient].sdkRunningMode = RCSDKRunningMode_Background;
    [[RCIM sharedRCIM]postLocalNotificationIfNeed:message];
    message.isOffLine = NO;
    [[RCIMClient sharedRCIMClient] handleAppSuspend];
    [[RCIM sharedRCIM]postLocalNotificationIfNeed:message];
    [[RCIM sharedRCIM]postLocalNotificationIfNeed:nil];
}
- (void)testSendMessageAttachCurrentUserInfo {
    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
    RCMessage *msg = [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE
                    targetId:@"111"
                     content:[RCTestHelper getTextMessage]
                 pushContent:nil
                    pushData:nil
                     success:^(long messageId) {
                     }
                       error:^(RCErrorCode nErrorCode, long messageId) {
                    }];
    XCTAssertNotNil(msg.content.senderUserInfo);
}



@end
