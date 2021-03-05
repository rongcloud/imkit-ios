//
//  RCFilePreviewViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCFilePreviewViewController.h"

@interface RCFilePreviewViewControllerTests : XCTestCase

@end

@implementation RCFilePreviewViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCFilePreviewViewController *cell = [[RCFilePreviewViewController alloc]init];
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"constraintCenterInSuperview:" forKey:@"constraintCenterInSuperview:"];
//    [dic setValue:@"constrainView:toSize:" forKey:@"constrainView:toSize:"];
    [RCTestHelper excuteMethodArgumentWithNil:cell except:dic];
}

- (void)testViewDidAppear {
    RCFilePreviewViewController *vc = [[RCFilePreviewViewController alloc]init];
    RCImageMessage *imageMsg = [RCTestHelper getImageMessage];
    imageMsg.imageUrl = @"http://figurefree.soopat.com/Thumbnails/Figure/A213D503526EA095B04DF13C21594CFC6719AB218D0BCB8191571B7BBEAAF8E6.gif";
    RCMessage *msg = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"111" direction:MessageDirection_RECEIVE messageId:1 content:imageMsg];
    RCMessageModel *model = [[RCMessageModel alloc]initWithMessage:msg];
    vc.messageModel = model;
    
    [vc viewWillAppear:YES];
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
