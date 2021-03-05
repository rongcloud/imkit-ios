//
//  RCConversationModelTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/5.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCConversationModel.h"
#import "RCTestHelper.h"

@interface RCConversationModelTests : XCTestCase

@end

@implementation RCConversationModelTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCConversationModel *model = [[RCConversationModel alloc]init];
    XCTAssertNotNil(model);
    [RCTestHelper excuteMethodArgumentWithNil:model];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


@end
