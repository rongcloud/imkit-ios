//
//  RCLocalNotificationTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCLocalNotification.h"
#import "RCTestHelper.h"

@interface RCLocalNotificationTests : XCTestCase

@end

@implementation RCLocalNotificationTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCLocalNotification *ntf = [[RCLocalNotification alloc]init];
//    [RCTestHelper excuteMethodArgumentWithNil:ntf];
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
