//
//  RCFMDBTestBase.h
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "RCloudFMDatabase.h"

@protocol FMDBTempDBTests <NSObject>

@optional
+ (void)populateDatabase:(RCloudFMDatabase *)database;

@end

@interface RCFMDBTestBase : XCTestCase <FMDBTempDBTests>

@property RCloudFMDatabase *db;
@property (readonly) NSString *databasePath;

@end

