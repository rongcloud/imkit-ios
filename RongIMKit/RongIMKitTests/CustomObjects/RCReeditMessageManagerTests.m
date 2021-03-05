//
//  RCReeditMessageManagerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCReeditMessageManager.h"

@interface RCReeditMessageManagerTests : XCTestCase

@end

@implementation RCReeditMessageManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)testInit{
    RCReeditMessageManager *item = [RCReeditMessageManager defaultManager];
    XCTAssertNotNil(item);
    [RCTestHelper excuteMethodArgumentWithNil:item];
}

/// 添加发送时间距离当前时间的时间
- (void)testAddReeditDuration{
    [[RCReeditMessageManager defaultManager] addReeditDuration:0 messageId:-1];
}

/// 重置撤回再编辑的时间并释放 timer
- (void)testResetAndInvalidateTimer{
    [[RCReeditMessageManager defaultManager]resetAndInvalidateTimer];
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
