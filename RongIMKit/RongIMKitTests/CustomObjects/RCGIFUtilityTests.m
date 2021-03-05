//
//  RCGIFUtilityTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/6.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCGIFUtility.h"

@interface RCGIFUtilityTests : XCTestCase

@end

@implementation RCGIFUtilityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCalculatecollectionViewHeight {
    CGSize size = [RCGIFUtility calculatecollectionViewHeight:nil];
    XCTAssertTrue(size.height == 79 && size.width == 79);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    RCGIFMessage *gif = [RCGIFMessage messageWithGIFURI:url width:100 height:100];
    RCMessage *gifMsg = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                               targetId:@"111"
                                              direction:MessageDirection_SEND
                                              messageId:1
                                                content:gif];
    RCMessageModel *model = [[RCMessageModel alloc] initWithMessage:gifMsg];
    size = [RCGIFUtility calculatecollectionViewHeight:model];

    XCTAssertTrue(size.height == 79 && size.width == 79);
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
