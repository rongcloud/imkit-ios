//
//  RCActionSheetViewTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/26.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCActionSheetView.h"
#import "RCTestHelper.h"

@interface RCActionSheetViewTests : XCTestCase
@property (nonatomic, strong) RCActionSheetView *instance;
@end

@implementation RCActionSheetViewTests

- (void)setUp {
    self.instance = [[RCActionSheetView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    XCTAssertNotNil(self.instance);
    self.instance = [[RCActionSheetView alloc] initWithCellArray:nil viewBounds:CGSizeZero cancelTitle:nil selectedBlock:nil cancelBlock:nil];
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
