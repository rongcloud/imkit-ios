//
//  RCSightCollectionViewCellTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCSightCollectionViewCell.h"

@interface RCSightCollectionViewCellTests : XCTestCase

@end

@implementation RCSightCollectionViewCellTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCSightCollectionViewCell *cell = [[RCSightCollectionViewCell alloc]init];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"constraintCenterInSuperview:" forKey:@"constraintCenterInSuperview:"];
    [dic setValue:@"constrainView:toSize:" forKey:@"constrainView:toSize:"];
    [dic setValue:@"strechToSuperview:" forKey:@"strechToSuperview:"];
    [RCTestHelper excuteMethodArgumentWithNil:cell except:dic];
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
