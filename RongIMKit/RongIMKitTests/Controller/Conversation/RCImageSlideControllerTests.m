//
//  RCImageSlideControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCImageSlideController.h"
#import "RCMessageModel.h"

@interface RCImageSlideControllerTests : XCTestCase

@end

@implementation RCImageSlideControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCImageSlideController *vc = [[RCImageSlideController alloc]init];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"showAlertController:message:cancelTitle:" forKey:@"showAlertController:message:cancelTitle:"];
    [dic setValue:@"doubleTap:" forKey:@"doubleTap:"];
    [dic setValue:@"setImageCenter:" forKey:@"setImageCenter:"];
    [RCTestHelper excuteMethodArgumentWithNil:vc except:dic];
}

- (void)testImageArray {
    RCImageSlideController *vc = [[RCImageSlideController alloc]init];
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_SEND messageId:1 content:[RCTestHelper getImageMessage]];
    vc.messageModel = [RCMessageModel modelWithMessage:msg];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"showAlertController:message:cancelTitle:" forKey:@"showAlertController:message:cancelTitle:"];
    [dic setValue:@"doubleTap:" forKey:@"doubleTap:"];
    [dic setValue:@"setImageCenter:" forKey:@"setImageCenter:"];
    [RCTestHelper excuteMethodArgumentWithNil:vc except:dic];
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
