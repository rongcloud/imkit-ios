//
//  RCCombineMessageUtilityTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCCombineMessageUtility.h"
#import "RCMessageModel.h"

@interface RCCombineMessageUtilityTests : XCTestCase
@property(nonatomic,strong)RCCombineMessageUtility *instance;
@end

@implementation RCCombineMessageUtilityTests

- (void)setUp {
}

-(void)testGetCombineMessageSummaryTitle{
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryTitle:nil]);
    RCCombineMessage *msg = [[RCCombineMessage alloc]init];
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryTitle:msg]);
    msg.conversationType = ConversationType_GROUP;
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryTitle:msg]);
    msg.conversationType = ConversationType_PRIVATE;
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryTitle:msg]);
    
}

-(void)testGetCombineMessagePreviewVCTitle{
   XCTAssertNotNil([RCCombineMessageUtility getCombineMessagePreviewVCTitle:nil]);
   RCCombineMessage *msg = [[RCCombineMessage alloc]init];
   XCTAssertNotNil([RCCombineMessageUtility getCombineMessagePreviewVCTitle:msg]);
   msg.conversationType = ConversationType_GROUP;
   XCTAssertNotNil([RCCombineMessageUtility getCombineMessagePreviewVCTitle:msg]);
   msg.conversationType = ConversationType_PRIVATE;
   XCTAssertNotNil([RCCombineMessageUtility getCombineMessagePreviewVCTitle:msg]);
}

-(void)testGetCombineMessageSummaryContent{
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryContent:nil]);
    RCCombineMessage *msg = [[RCCombineMessage alloc]init];
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryContent:msg]);
    msg.conversationType = ConversationType_GROUP;
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryContent:msg]);
    msg.conversationType = ConversationType_PRIVATE;
    XCTAssertNotNil([RCCombineMessageUtility getCombineMessageSummaryContent:msg]);

}

-(void)testAllSelectedMessagesAreLegal{
//    XCTAssertFalse([RCCombineMessageUtility allSelectedMessagesAreLegal:nil]);
//    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"1" direction:MessageDirection_SEND messageId:1 content:nil];
//    RCMessageModel *model = [[RCMessageModel alloc]initWithMessage:msg];
//    XCTAssertFalse([RCCombineMessageUtility allSelectedMessagesAreLegal:@[model]]);
//    RCMessage *msg1 = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"1" direction:MessageDirection_RECEIVE messageId:1 content:[RCTextMessage messageWithContent:@""]];
//    RCMessageModel *model1 = [[RCMessageModel alloc]initWithMessage:msg1];
//    model1.objectName = [RCTextMessage getObjectName];
//    XCTAssertTrue([RCCombineMessageUtility allSelectedMessagesAreLegal:@[model1]]);
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

@end
