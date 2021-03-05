//
//  RCPublicServiceSearchViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/10.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCPublicServiceSearchViewController.h"

@interface RCPublicServiceSearchViewControllerTests : XCTestCase
@property (nonatomic, strong) RCPublicServiceSearchViewController *vc;
@end

@implementation RCPublicServiceSearchViewControllerTests

- (void)setUp {
    self.vc = [[RCPublicServiceSearchViewController alloc] init];
    XCTAssertNotNil(self.vc);
    [self.vc viewDidLoad];
    [self.vc didReceiveMemoryWarning];
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
