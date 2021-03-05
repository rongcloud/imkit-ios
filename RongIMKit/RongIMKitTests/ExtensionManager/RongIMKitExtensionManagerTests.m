//
//  RongIMKitExtensionManagerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RongIMKitExtensionManager.h"

@interface RongIMKitExtensionManagerTests : XCTestCase
@property(nonatomic,strong)RongIMKitExtensionManager *instance;
@end

@implementation RongIMKitExtensionManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.instance = [RongIMKitExtensionManager sharedManager];
    XCTAssertNotNil(self.instance);
}

- (void)testMethodWithNil {
    [RCTestHelper excuteMethodArgumentWithNil:self.instance];
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
