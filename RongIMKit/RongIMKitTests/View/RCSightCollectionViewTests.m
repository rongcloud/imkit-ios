//
//  RCSightCollectionViewTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/3.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCSightCollectionView.h"
#import "RCTestHelper.h"

@interface RCSightCollectionViewTests : XCTestCase

@end

@implementation RCSightCollectionViewTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

- (void)testMethodWithNil {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    RCSightCollectionView *viewCon = [[RCSightCollectionView alloc] initWithFrame:CGRectMake(1, 1, 1, 1) collectionViewLayout:layout];
    [RCTestHelper excuteMethodArgumentWithNil:viewCon];
}
@end
