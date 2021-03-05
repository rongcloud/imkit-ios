//
//  RCloudImageLoadConnectionTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCloudImageLoadConnection.h"
#import "RCTestHelper.h"

@interface RCloudImageLoadConnectionTests : XCTestCase
@property(nonatomic,strong)RCloudImageLoadConnection *instance;
@end

@implementation RCloudImageLoadConnectionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCloudImageLoadConnection *imageLoad = [[RCloudImageLoadConnection alloc] initWithImageURL:nil delegate:nil];
    [RCTestHelper excuteMethodArgumentWithNil:imageLoad];
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
