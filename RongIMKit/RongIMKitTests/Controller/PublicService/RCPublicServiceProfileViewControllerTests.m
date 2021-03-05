//
//  RCPublicServiceProfileViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCPublicServiceProfileViewController.h"

@interface RCPublicServiceProfileViewControllerTests : XCTestCase

@end

@implementation RCPublicServiceProfileViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCPublicServiceProfileViewController *vc = [[RCPublicServiceProfileViewController alloc]init];
    [vc viewDidLoad];
    [vc viewWillAppear:YES];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"tableView:heightForRowAtIndexPath:" forKey:@"tableView:heightForRowAtIndexPath:"];
    [dic setValue:@"tableView:cellForRowAtIndexPath:" forKey:@"tableView:cellForRowAtIndexPath:"];
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
