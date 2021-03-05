//
//  RCCustomerServiceMessageModelTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/3.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCCustomerServiceMessageModel.h"
#import "RCTestHelper.h"

@interface RCCustomerServiceMessageModelTests : XCTestCase

@end

@implementation RCCustomerServiceMessageModelTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_CUSTOMERSERVICE targetId:@"111" direction:MessageDirection_RECEIVE messageId:1111 content:[RCTextMessage messageWithContent:@"111"]];
    RCCustomerServiceMessageModel *model = [[RCCustomerServiceMessageModel alloc] initWithMessage:message];
    [RCTestHelper excuteMethodArgumentWithNil:model];
}

- (void)testInitWithMessage {
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_CUSTOMERSERVICE targetId:@"111" direction:MessageDirection_RECEIVE messageId:1111 content:[RCTextMessage messageWithContent:@"111"]];
    RCCustomerServiceMessageModel *model = [[RCCustomerServiceMessageModel alloc] initWithMessage:message];
    XCTAssertNotNil(model);
    RCCustomerServiceMessageModel *model1 = [[RCCustomerServiceMessageModel alloc] initWithMessage:nil];
    XCTAssertNotNil(model1);
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
