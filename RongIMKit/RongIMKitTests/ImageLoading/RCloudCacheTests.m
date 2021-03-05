//
//  RCloudCacheTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/23.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCloudCache.h"

@interface RCloudCacheTests : XCTestCase

@end

@implementation RCloudCacheTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCloudCache *cache = [RCloudCache currentCache];
    XCTAssertNotNil(cache);
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"imageLoadConnectionDidFinishLoading:" forKey:@"imageLoadConnectionDidFinishLoading:"];
    [dic setValue:@"plistForKey:" forKey:@"plistForKey:"];
    [RCTestHelper excuteMethodArgumentWithNil:cache except:dic];
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
