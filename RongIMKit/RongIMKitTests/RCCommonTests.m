//
//  RCCommonTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCTestHelper.h"

@interface RCCommonTests : XCTestCase

@end

@implementation RCCommonTests

- (void)testAllViewController {
    NSMutableDictionary *exceptDic = [NSMutableDictionary new];
    [exceptDic setValue:@"RCImageSlideController" forKey:@"RCImageSlideController"];
    NSArray<NSString *> *allClassname = [[RCTestHelper getAllRongCloudClasses] objectForKey:@"ViewController"];
    for (NSString *className in allClassname) {
        if ([exceptDic.allKeys containsObject:className]) {
            break;
        }
        Class moduleClass = NSClassFromString(className);
        if (moduleClass) {
            NSLog(@"name  %@", [moduleClass class]);
            UIViewController *vc = [[moduleClass alloc] init];
            if ([vc respondsToSelector:@selector(viewDidLoad)]) {
                [vc performSelector:@selector(viewDidLoad)];
            }
            if ([vc respondsToSelector:@selector(viewWillAppear:)]) {
                [vc performSelector:@selector(viewWillAppear:) withObject:@(YES)];
            }
            if ([vc respondsToSelector:@selector(viewDidAppear:)]) {
                [vc performSelector:@selector(viewDidAppear:) withObject:@(YES)];
            }
            if ([vc respondsToSelector:@selector(viewWillDisappear:)]) {
                [vc performSelector:@selector(viewWillDisappear:) withObject:@(YES)];
            }
            if ([vc respondsToSelector:@selector(viewDidDisappear:)]) {
                [vc performSelector:@selector(viewDidDisappear:) withObject:@(YES)];
            }
        }
    }
}

- (void)testAllCell {
    NSArray<NSString *> *allClassname = [[RCTestHelper getAllRongCloudClasses] objectForKey:@"Cell"];
    for (NSString *className in allClassname) {
        Class moduleClass = NSClassFromString(className);
        if (moduleClass) {
            NSLog(@"name  %@", [moduleClass class]);
            UICollectionViewCell *vc = [[moduleClass alloc] init];
            if ([vc respondsToSelector:@selector(setAutoLayout)]) {
                [vc performSelector:@selector(setAutoLayout)];
            }
            if ([vc respondsToSelector:@selector(setDataModel:)]) {
                [vc performSelector:@selector(setDataModel:) withObject:nil];
            }
            //            if([vc respondsToSelector:@selector(viewDidAppear:)]){
            //                [vc performSelector:@selector(viewDidAppear:)withObject:@(YES)];
            //            }
            //            if([vc respondsToSelector:@selector(viewWillDisappear:)]){
            //                [vc performSelector:@selector(viewWillDisappear:)withObject:@(YES)];
            //            }
            //            if([vc respondsToSelector:@selector(viewDidDisappear:)]){
            //                [vc performSelector:@selector(viewDidDisappear:)withObject:@(YES)];
            //            }
        }
    }
}

@end
