//
//  RCConversationCellTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCConversationCell.h"

@interface RCConversationCellTests : XCTestCase

@end

@implementation RCConversationCellTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)testInit{
    RCConversationCell *item = [[RCConversationCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    XCTAssertNotNil(item);
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"textView:shouldChangeTextInRange:replacementText:" forKey:@"textView:shouldChangeTextInRange:replacementText:"];
    [RCTestHelper excuteMethodArgumentWithNil:item];
}

-(void)testSetDataModel{
    RCConversationCell *item = [[RCConversationCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    RCConversationModel *model = [[RCConversationModel alloc] init];
    model.conversationType = ConversationType_PRIVATE;
    model.targetId = @"111";
    [item setDataModel:model];
    model.conversationType = ConversationType_GROUP;
//    model.targetId = @"111";
    [item setDataModel:model];
    model.conversationType = RC_CONVERSATION_MODEL_TYPE_COLLECTION;
        model.targetId = @"111";
    [item setDataModel:model];
    model.conversationType = RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE;
        model.targetId = @"111";
    [item setDataModel:model];
    model.conversationType = ConversationType_DISCUSSION;
        model.targetId = @"111";
    [item setDataModel:model];
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
