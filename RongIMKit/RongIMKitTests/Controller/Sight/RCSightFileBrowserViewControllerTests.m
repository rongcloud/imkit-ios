//
//  RCSightFileBrowserViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCSightFileBrowserViewController.h"
#import "RCTestHelper.h"
#import "RCMethodModel.h"

@interface RCSightFileBrowserViewController (test)
- (void)refreshAction:(UIRefreshControl *)refreshControl;
- (NSArray<RCMessageModel *> *)getLaterMessagesThanModel:(RCMessageModel *)model count:(NSInteger)count;

- (NSArray<RCMessageModel *> *)getOlderMessagesThanModel:(RCMessageModel *)model count:(NSInteger)count;

- (void)getMessageFromModel:(RCMessageModel *)model;

@end

@interface RCSightFileBrowserViewControllerTests : XCTestCase
@property (nonatomic, strong) RCSightFileBrowserViewController *vc;
@end

@implementation RCSightFileBrowserViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    self.vc = [[RCSightFileBrowserViewController alloc] initWithMessageModel:nil];
    XCTAssertNotNil(self.vc);
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

- (void)testRefreshAction {
    [self.vc refreshAction:nil];
}

- (void)testGetLaterMessagesThanModel {
    XCTAssertNil([self.vc getLaterMessagesThanModel:nil count:10]);
}

- (void)testGetOlderMessagesThanModel {
    XCTAssertNil([self.vc getOlderMessagesThanModel:nil count:10]);
}

- (void)testGetMessageFromModel {
//    [self.vc getMessageFromModel:nil];
}


@end
