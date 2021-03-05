//
//  RCActiveWheelTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCActiveWheel.h"

@interface RCActiveWheelTests : XCTestCase

@end

@implementation RCActiveWheelTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
- (void)testMethodWithNil {
    RCActiveWheel *view = [[RCActiveWheel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    XCTAssertNotNil(view);
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [RCTestHelper excuteClassMethod:[view class] except:dic];
    
}

- (void)testInitWithView {
    UIView *view = [[UIView alloc]init];
    XCTAssertNotNil([[RCActiveWheel alloc]initWithView:view]);
}

- (void)testInitWithWindow{
    UIWindow *view = [[UIWindow alloc]init];
    XCTAssertNotNil([[RCActiveWheel alloc]initWithWindow:view]);
}

- (void)testSetWarningString{
    RCActiveWheel *view = [[RCActiveWheel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [view setWarningString:nil];
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
