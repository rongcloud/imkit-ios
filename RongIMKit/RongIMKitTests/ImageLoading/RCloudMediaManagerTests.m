//
//  RCloudMediaManagerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCloudMediaManager.h"
#import "RCTestHelper.h"

@interface RCloudMediaManager (test)
//
//@property(nonatomic,assign)CGFloat destImageMaxSizeMB;
//@property(nonatomic,assign)CGFloat destImageTotalPixels;
@end

@interface RCloudMediaManagerTests : XCTestCase

@end

@implementation RCloudMediaManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCloudMediaManager *imageLoad = [RCloudMediaManager sharedManager];
    [RCTestHelper excuteMethodArgumentWithNil:imageLoad];
}

- (void)testDownsizeImage{
    UIImage *image = [[RCloudMediaManager sharedManager]downsizeImage:nil];
    XCTAssertNil(image);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"jpeg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *testImage = [UIImage imageWithData:data];
//    [RCloudMediaManager sharedManager].destImageMaxSizeMB = 0.1f;
//    [RCloudMediaManager sharedManager].destImageTotalPixels = 26214.4;
    image = [[RCloudMediaManager sharedManager]downsizeImage:testImage];
    XCTAssertNotNil(image);
    XCTestExpectation *exp = [self expectationWithDescription:@"downsizeImage"];
    
    [[RCloudMediaManager sharedManager]downsizeImage:testImage completionBlock:^(UIImage * _Nullable image, BOOL doNothing) {
        XCTAssertNotNil(image);
        [exp fulfill];
    } progressBlock:^(UIImage * _Nullable image, BOOL doNothing) {
        XCTAssertNotNil(image);
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"【Error】downsizeImage fulfilled");
    }];
    
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
