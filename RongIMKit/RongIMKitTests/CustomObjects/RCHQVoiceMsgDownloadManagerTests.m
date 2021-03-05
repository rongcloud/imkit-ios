//
//  RCHQVoiceMsgDownloadManagerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCHQVoiceMsgDownloadManager.h"

@interface RCHQVoiceMsgDownloadManagerTests : XCTestCase

@end

@implementation RCHQVoiceMsgDownloadManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCHQVoiceMsgDownloadManager *manager = [RCHQVoiceMsgDownloadManager defaultManager];
    XCTAssertNotNil(manager);
    [RCTestHelper excuteMethodArgumentWithNil:manager];
}

- (void)testPushVoiceMsgs{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"wavDec" withExtension:@"wav"];
    RCHQVoiceMessage *hqMsg = [RCHQVoiceMessage messageWithPath:[url absoluteString] duration:1];
    XCTAssertNotNil(hqMsg);
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_RECEIVE messageId:1 content:hqMsg];
    [[RCHQVoiceMsgDownloadManager defaultManager] pushVoiceMsgs:@[ msg ] priority:YES];
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

@end
