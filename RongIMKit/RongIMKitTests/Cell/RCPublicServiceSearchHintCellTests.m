//
//  RCPublicServiceSearchHintCellTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCPublicServiceSearchHintCell.h"

@interface RCPublicServiceSearchHintCellTests : XCTestCase

@end

@implementation RCPublicServiceSearchHintCellTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testInit{
    RCPublicServiceSearchHintCell *item = [[RCPublicServiceSearchHintCell alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    XCTAssertNotNil(item);
//    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"textView:shouldChangeTextInRange:replacementText:" forKey:@"textView:shouldChangeTextInRange:replacementText:"];
    [RCTestHelper excuteMethodArgumentWithNil:item];
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
