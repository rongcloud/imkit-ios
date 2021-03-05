//
//  RCDestructGIFPreviewViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCDestructGIFPreviewViewController.h"

@interface RCDestructGIFPreviewViewControllerTests : XCTestCase
@property (nonatomic, strong) RCDestructGIFPreviewViewController *vc;
@end

@implementation RCDestructGIFPreviewViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.vc = [[RCDestructGIFPreviewViewController alloc]init];
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    RCGIFMessage *gif = [RCGIFMessage messageWithGIFURI:url width:100 height:100];
    RCMessage *gifMsg = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                               targetId:@"111"
                                              direction:MessageDirection_SEND
                                              messageId:1
                                                content:gif];
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"11" direction:MessageDirection_SEND messageId:1 content:gifMsg];
    self.vc.messageModel = [RCMessageModel modelWithMessage:msg];
    
}

- (void)testMethodWithNil {
    [RCTestHelper excuteMethodArgumentWithNil:self.vc];
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
