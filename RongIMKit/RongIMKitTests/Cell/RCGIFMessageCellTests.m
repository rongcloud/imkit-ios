//
//  RCGIFMessageCellTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCGIFMessageCell.h"

@interface RCGIFMessageCellTests : XCTestCase

@end

@implementation RCGIFMessageCellTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testInit{
    RCGIFMessageCell *item = [[RCGIFMessageCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    XCTAssertNotNil(item);
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"textView:shouldChangeTextInRange:replacementText:" forKey:@"textView:shouldChangeTextInRange:replacementText:"];
    [RCTestHelper excuteMethodArgumentWithNil:item];
}

-(void)testSetDataModel{
    RCGIFMessageCell *item = [[RCGIFMessageCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    RCGIFMessage *gif = [RCTestHelper getGifMessage];
    gif.destructDuration = 6;
    gif.remoteUrl = @"https://n.sinaimg.cn/tech/transform/781/w500h281/20200316/3686-iquxrui7804428.gif";
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"11" direction:MessageDirection_SEND messageId:1 content:gif];
    RCMessageModel *model = [RCMessageModel modelWithMessage:msg];
    [item setDataModel:model];
    
    RCGIFMessage *gif1 = [RCTestHelper getGifMessage];
    gif.destructDuration = 6;
    gif.remoteUrl = @"https://n.sinaimg.cn/tech/transform/781/w500h281/20200316/3686-iquxrui7804428.gif";
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
