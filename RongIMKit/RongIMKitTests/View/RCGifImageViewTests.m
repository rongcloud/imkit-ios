//
//  RCGifImageViewTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCTestHelper.h"
#import "RCGIFImage.h"
#import "RCGifImageView.h"

@interface RCGifImageViewTests : XCTestCase

@end

@implementation RCGifImageViewTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCGIFImageView *imageView = [[RCGIFImageView alloc]init];
    XCTAssertNotNil(imageView);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    RCGIFImage *animatedImage = [RCGIFImage animatedImageWithGIFData:data];
    imageView.animatedImage = animatedImage;
    XCTAssertNotNil(animatedImage);
    [RCTestHelper excuteMethodArgumentWithNil:imageView];
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
