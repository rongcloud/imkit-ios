//
//  RCloudFMResultSetTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCFMDBTestBase.h"
#import "RCloudFMDatabase.h"
#import "RCloudFMResultSet.h"

#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface RCloudFMResultSetTests : RCFMDBTestBase

@end

@implementation RCloudFMResultSetTests

+ (void)populateDatabase:(RCloudFMDatabase *)db
{
    [db executeUpdate:@"create table test (a text, b text, c integer, d double, e double)"];
    
    [db beginTransaction];
    int i = 0;
    while (i++ < 20) {
        [db executeUpdate:@"insert into test (a, b, c, d, e) values (?, ?, ?, ?, ?)" ,
         @"hi'",
         [NSString stringWithFormat:@"number %d", i],
         [NSNumber numberWithInt:i],
         [NSDate date],
         [NSNumber numberWithFloat:2.2f]];
    }
    [db commit];
}

- (void)testNextWithError_WithoutError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    RCloudFMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=1"];
    XCTAssertNotNil(resultSet);
    NSError *error;
    XCTAssertTrue([resultSet nextWithError:&error]);
    XCTAssertNil(error);
    
    XCTAssertFalse([resultSet nextWithError:&error]);
    XCTAssertNil(error);
    
    [resultSet close];
}

- (void)testNextWithError_WithBusyError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    RCloudFMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=1"];
    XCTAssertNotNil(resultSet);
    
    RCloudFMDatabase *newDB = [RCloudFMDatabase databaseWithPath:self.databasePath];
    [newDB open];
    
    [newDB beginTransaction];
    NSError *error;
    XCTAssertFalse([resultSet nextWithError:&error]);
    [newDB commit];
    
    XCTAssertEqual(error.code, SQLITE_BUSY, @"SQLITE_BUSY should be the last error");
    [resultSet close];
}

- (void)testNextWithError_WithMisuseError
{
    [self.db executeUpdate:@"CREATE TABLE testTable(key INTEGER PRIMARY KEY, value INTEGER)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (1, 2)"];
    [self.db executeUpdate:@"INSERT INTO testTable (key, value) VALUES (2, 4)"];
    
    RCloudFMResultSet *resultSet = [self.db executeQuery:@"SELECT * FROM testTable WHERE key=9"];
    XCTAssertNotNil(resultSet);
    XCTAssertFalse([resultSet next]);
    NSError *error;
    XCTAssertFalse([resultSet nextWithError:&error]);

    XCTAssertEqual(error.code, SQLITE_MISUSE, @"SQLITE_MISUSE should be the last error");
}

@end
