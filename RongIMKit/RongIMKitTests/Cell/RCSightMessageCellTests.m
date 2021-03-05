//
//  RCSightMessageCellTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCSightMessageCell.h"

@interface RCSightMessageCellTests : XCTestCase

@end

@implementation RCSightMessageCellTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testInit{
    RCSightMessageCell *item = [[RCSightMessageCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    XCTAssertNotNil(item);
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"textView:shouldChangeTextInRange:replacementText:" forKey:@"textView:shouldChangeTextInRange:replacementText:"];
    [RCTestHelper excuteMethodArgumentWithNil:item];
}

-(void)testSetDataModel{
    RCSightMessageCell *item = [[RCSightMessageCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    RCSightMessage *gif = [RCTestHelper getSightMessage];
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"11" direction:MessageDirection_SEND messageId:1 content:gif];
    RCMessageModel *model = [RCMessageModel modelWithMessage:msg];
    [item setDataModel:model];
    
    RCSightMessage *gif1 = [RCTestHelper getSightMessage];
    RCMessage *msg1 = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"11" direction:MessageDirection_RECEIVE messageId:1 content:gif1];
    model = [RCMessageModel modelWithMessage:msg1];
    [item setDataModel:model];
    
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
