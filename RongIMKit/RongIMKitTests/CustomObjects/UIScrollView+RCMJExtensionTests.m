//
//  UIScrollView+RCMJExtensionTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIScrollView+RCMJExtension.h"

@interface UIScrollView_RCMJExtensionTests : XCTestCase

@end

@implementation UIScrollView_RCMJExtensionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)testInit{
    UIScrollView *_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_scrollView setBackgroundColor:[UIColor blackColor]];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setContentSize:CGSizeMake(100, 0)];

    XCTAssertNotNil(_scrollView);
     NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"rcmj_inset" forKey:@"rcmj_inset"];
    [dic setValue:@"PDFKitDocumentVisibleRectIncludingContentInsets" forKey:@"PDFKitDocumentVisibleRectIncludingContentInsets"];
    [dic setValue:@"contentInset" forKey:@"contentInset"];
    [dic setValue:@"adjustedContentInset" forKey:@"adjustedContentInset"];
//    [RCTestHelper excuteMethodArgumentWithNil:_scrollView except:dic];
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
