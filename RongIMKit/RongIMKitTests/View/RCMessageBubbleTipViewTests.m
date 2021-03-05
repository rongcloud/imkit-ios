//
//  RCMessageBubbleTipViewTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCMessageBubbleTipView.h"

@interface RCMessageBubbleTipViewTests : XCTestCase

@end

@implementation RCMessageBubbleTipViewTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCMessageBubbleTipView *view = [[RCMessageBubbleTipView alloc] init];

    XCTAssertNotNil(view);
    [RCTestHelper excuteMethodArgumentWithNil:view];
}

-(void)testDrawRect{
    RCMessageBubbleTipView *view = [[RCMessageBubbleTipView alloc] init];
    view.bubbleTipText = @"111";
    view.isShowNotificationNumber = YES;
    [view setBubbleTipNumber:111];
    view.bubbleTipPositionAdjustment = CGPointMake(0, 1);
    view.bubbleTipTextShadowOffset = CGSizeMake(0, 1);
    [view drawRect:CGRectZero];
    
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
