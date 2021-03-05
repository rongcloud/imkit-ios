//
//  RCGIFImageTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCGIFImage.h"
#import "RCTestHelper.h"
#import <objc/runtime.h>

@interface RCGIFImageTests : XCTestCase

@end

@implementation RCGIFImageTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCGIFImage *image = [[RCGIFImage alloc]init];
    XCTAssertNil(image);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    RCGIFImage *animatedImage = [RCGIFImage animatedImageWithGIFData:data];

    XCTAssertNotNil(animatedImage);
    NSMutableDictionary *dic = [NSMutableDictionary new];
//    [dic setValue:@"initialize" forKey:@"initialize"];
    [dic setValue:@"didReceiveMemoryWarning:" forKey:@"didReceiveMemoryWarning:"];
    [RCTestHelper excuteClassMethod:[animatedImage class]  except:dic];
    sleep(1);
//    [RCTestHelper excuteInstanceMethod:animatedImage except:dic];
}

-(void)testInit{
    RCGIFImage *image = [[RCGIFImage alloc]initWithAnimatedGIFData:nil];
    XCTAssertNil(image);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    image = [[RCGIFImage alloc]initWithAnimatedGIFData:data];
    XCTAssertNotNil(image);
    CGSize size = [RCGIFImage sizeForImage:image];
    XCTAssertGreaterThan(size.height, 0,@"success");
    url = [[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"jpeg"];
    data = [NSData dataWithContentsOfURL:url];
    image = [[RCGIFImage alloc]initWithAnimatedGIFData:data];
    XCTAssertNil(image);
    
}

-(void)testFrameCacheSizeCurrent{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    RCGIFImage *image = [[RCGIFImage alloc]initWithAnimatedGIFData:data];
    XCTAssertNotNil(image);
    image.frameCacheSizeMax = 1;
    XCTAssertGreaterThan([image frameCacheSizeCurrent], 0,@"success");
    
}
- (void) testImageLazilyCachedAtIndex{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    RCGIFImage *image = [[RCGIFImage alloc]initWithAnimatedGIFData:data];
    XCTAssertNotNil([image imageLazilyCachedAtIndex:0]);
    XCTAssertNotNil(image.posterImage);
    XCTAssertGreaterThan(image.frameCount, 1,@"success");
    XCTAssertEqual(image.loopCount, 0,@"success");
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
