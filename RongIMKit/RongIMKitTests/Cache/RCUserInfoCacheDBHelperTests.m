//
//  RCUserInfoCacheDBHelperTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/3.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCUserInfoCacheDBHelper.h"
#import "RCTestHelper.h"

@interface RCUserInfoCacheDBHelperTests : XCTestCase
@property(nonatomic,copy) NSString *testDbPath ;// @"/tmp/tmp.db";
@property(nonatomic,strong) RCUserInfoCacheDBHelper *instance ;// @"/tmp/tmp.db";
@end

@implementation RCUserInfoCacheDBHelperTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.testDbPath = @"/tmp/tmp.db";
    self.instance = [[RCUserInfoCacheDBHelper alloc]initWithPath:self.testDbPath];
    XCTAssertNotNil(self.instance );
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
    RCUserInfoCacheDBHelper *viewCon = [[RCUserInfoCacheDBHelper alloc] initWithPath:nil];
    [RCTestHelper excuteMethodArgumentWithNil:viewCon];
}

- (void)testInitWithPath{
    RCUserInfoCacheDBHelper *dbHelper = [[RCUserInfoCacheDBHelper alloc]initWithPath:nil];
    XCTAssertNotNil(dbHelper);
    
}

- (void)testSelectConversationInfoFromDB{
    RCConversationInfo * conversation = [self.instance selectConversationInfoFromDB:nil targetId:nil];
    XCTAssertNil(conversation);
    RCConversationInfo *info = [[RCConversationInfo alloc]initWithConversationId:@"111" conversationType:ConversationType_PRIVATE name:@"11" portraitUri:nil];
    [self.instance replaceConversationInfoFromDB:nil conversationType:nil targetId:nil];
    [self.instance replaceConversationInfoFromDB:info conversationType:ConversationType_PRIVATE targetId:@"111"];
    RCConversationInfo * conversation1 = [self.instance selectConversationInfoFromDB:ConversationType_PRIVATE targetId:@"111"];
    XCTAssertNotNil(conversation1);
}
- (void)testSelectAllConversationInfoFromDB{
}

- (void)testReplaceConversationInfoFromDB{
    RCConversationInfo *info = [[RCConversationInfo alloc]initWithConversationId:@"111" conversationType:ConversationType_PRIVATE name:@"11" portraitUri:nil];
    [self.instance replaceConversationInfoFromDB:nil conversationType:nil targetId:nil];
}

- (void)testDeleteConversationInfoFromDB{
    [self.instance deleteConversationInfoFromDB:ConversationType_PRIVATE targetId:@"111"];
    RCConversationInfo * conversation1 = [self.instance selectConversationInfoFromDB:ConversationType_PRIVATE targetId:@"111"];
    XCTAssertNil(conversation1);
}
- (void)testDeleteAllConversationInfoFromDB{
    RCConversationInfo *info = [[RCConversationInfo alloc]initWithConversationId:@"111" conversationType:ConversationType_PRIVATE name:@"11" portraitUri:nil];
    [self.instance replaceConversationInfoFromDB:info conversationType:ConversationType_PRIVATE targetId:@"111"];
    
    RCConversationInfo * conversation1 = [self.instance selectConversationInfoFromDB:ConversationType_PRIVATE targetId:@"111"];
    XCTAssertNotNil(conversation1);
    [self.instance deleteAllConversationInfoFromDB];
    conversation1 = [self.instance selectConversationInfoFromDB:ConversationType_PRIVATE targetId:@"111"];
    XCTAssertNil(conversation1);

}

- (void)testSelectUserInfoFromDB{
    RCUserInfo * userInfo = [self.instance selectUserInfoFromDB:@"111"];
    XCTAssertNotNil(userInfo);
    RCUserInfo *info = [[RCUserInfo alloc]initWithUserId:@"111" name:@"1111" portrait:@"1111"];
    [self.instance replaceUserInfoFromDB:info forUserId:@"111"];
    RCUserInfo * user = [self.instance selectUserInfoFromDB:@"111"];
    XCTAssertNotNil(user);
}

- (void)testSelectAllConversationUserInfoFromDB{
    RCConversationInfo *info1 = [[RCConversationInfo alloc]initWithConversationId:@"111" conversationType:ConversationType_PRIVATE name:@"11" portraitUri:nil];
    [self.instance replaceConversationInfoFromDB:info1 conversationType:ConversationType_PRIVATE targetId:@"111"];
    RCConversationInfo *info2 = [[RCConversationInfo alloc]initWithConversationId:@"121" conversationType:ConversationType_PRIVATE name:@"11" portraitUri:nil];
    [self.instance replaceConversationInfoFromDB:info2 conversationType:ConversationType_PRIVATE targetId:@"121"];
    NSArray *list = [self.instance selectAllConversationInfoFromDB];
    XCTAssertGreaterThan(list.count, 2, @"Success");
    
}


- (void)testDeleteConversationUserInfoFromDB{
    [self.instance deleteConversationUserInfoFromDB:@"111" conversationType:ConversationType_PRIVATE targetId:@"111"];
}

- (void)testDeleteAllConversationUserInfoFromDB{
    [self.instance deleteAllConversationUserInfoFromDB];
}


- (void)testSelectAllUserInfoFromDB{
    RCUserInfo *info1 = [[RCUserInfo alloc]initWithUserId:@"111" name:@"1111" portrait:@"1111"];
    RCUserInfo *info2 = [[RCUserInfo alloc]initWithUserId:@"121" name:@"1111" portrait:@"1111"];
    [self.instance replaceUserInfoFromDB:info1 forUserId:info1.userId];
    [self.instance replaceUserInfoFromDB:info2 forUserId:info2.userId];
    NSArray *list = [self.instance selectAllUserInfoFromDB];
    XCTAssertGreaterThan(list.count, 1, @"Success");
}

- (void)testDeleteUserInfoFromDB{
    [self.instance deleteUserInfoFromDB:@"111"];
}

- (void)testDeleteAllUserInfoFromDB{
    [self.instance deleteAllUserInfoFromDB];
}

- (void)replaceUserInfoFromDB1{
    RCUserInfo *info2 = [[RCUserInfo alloc]initWithUserId:@"121" name:@"1111" portrait:@"1111"];
    [self.instance replaceUserInfoFromDB:info2 forUserId:info2.userId conversationType:ConversationType_PRIVATE targetId:@"111"];
    RCUserInfo *info = [self.instance selectUserInfoFromDB:@"121" conversationType:ConversationType_PRIVATE targetId:@"111"];
    XCTAssertTrue([info.name isEqualToString:info2.name]);
}

@end
