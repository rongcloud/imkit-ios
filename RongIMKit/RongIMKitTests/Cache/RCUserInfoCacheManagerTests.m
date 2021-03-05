//
//  RCUserInfoCacheManagerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCUserInfoCacheManager.h"
#import "RCTestHelper.h"

@interface RCUserInfoCacheManagerTests : XCTestCase
@property (nonatomic, strong) RCUserInfoCacheManager *instance;
@end

@implementation RCUserInfoCacheManagerTests

- (void)setUp {
    self.instance = [RCUserInfoCacheManager sharedManager];
    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
    [self.instance setAppKey:@"8luwapkvucoil"];
    [self.instance setCurrentUserId:@"1111"];
    XCTAssertNotNil(self.instance);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"moveFile:fromPath:toPath:" forKey:@"moveFile:fromPath:toPath:"];
    [RCTestHelper excuteMethodArgumentWithNil:self.instance except:dic];
}

- (void)testGetUserInfoinGroupId{
    self.instance.groupUserInfoEnabled = YES;
    RCUserInfo *userInfo = [self.instance getUserInfo:@"11" inGroupId:@"11"];
    XCTAssertNil(userInfo);
    RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:@"11" name:@"test" portrait:@""];
    [self.instance updateUserInfo:user forUserId:user.userId inGroup:@"11"];
    userInfo = [self.instance getUserInfo:@"11" inGroupId:@"11"];
    XCTAssertNotNil(userInfo);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


@end
