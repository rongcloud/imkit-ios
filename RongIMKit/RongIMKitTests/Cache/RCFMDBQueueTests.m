//
//  RCFMDBQueueTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/2.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCloudFMDatabase.h"
#import "RCloudFMDatabaseQueue.h"
#import "RCFMDBTestBase.h"
#if FMDB_SQLITE_STANDALONE
#import <sqlite3/sqlite3.h>
#else
#import <sqlite3.h>
#endif

@interface RCFMDBQueueTests : RCFMDBTestBase

@property RCloudFMDatabaseQueue *queue;

@end

@implementation RCFMDBQueueTests

+ (void)populateDatabase:(RCloudFMDatabase *)db
{
    [db executeUpdate:@"create table easy (a text)"];
    
    [db executeUpdate:@"create table qfoo (foo text)"];
    [db executeUpdate:@"insert into qfoo values ('hi')"];
    [db executeUpdate:@"insert into qfoo values ('hello')"];
    [db executeUpdate:@"insert into qfoo values ('not')"];
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.queue = [RCloudFMDatabaseQueue databaseQueueWithPath:self.databasePath];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testURLOpenNoPath {
    RCloudFMDatabaseQueue *queue = [[RCloudFMDatabaseQueue alloc] init];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
}


- (void)testInvalidPath {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *folderURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSURL *fileURL = [folderURL URLByAppendingPathComponent:@"test.sqlite"];
    
    RCloudFMDatabaseQueue *queue = [[RCloudFMDatabaseQueue alloc] initWithPath:fileURL.path];
    XCTAssertNil(queue, @"Database queue should not be returned for invalid path");
    queue = nil;
}

- (void)testReopenFailure {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *folderURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    BOOL success = [manager createDirectoryAtURL:folderURL withIntermediateDirectories:true attributes:nil error:nil];
    NSAssert(success, @"Unable to create folder");
    
    NSURL *fileURL = [folderURL URLByAppendingPathComponent:@"test.sqlite"];
    
    RCloudFMDatabaseQueue *queue = [[RCloudFMDatabaseQueue alloc] initWithPath:[fileURL absoluteString] ];
    XCTAssert(queue, @"Database queue was unable to be created");
    
    [queue close];
    
    success = [manager removeItemAtURL:fileURL error:nil];
    XCTAssert(success, @"Unable to remove database");
    
    success = [manager removeItemAtURL:folderURL error:nil];
    XCTAssert(success, @"Unable to remove folder");
    
    [queue inDatabase:^(RCloudFMDatabase *db) {
        XCTAssertNil(db, @"Should be `nil` or never have reached here because database couldn't be reopened");
    }];
    
    queue = nil;
}

- (void)testURLOpen {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    RCloudFMDatabaseQueue *queue = [RCloudFMDatabaseQueue databaseQueueWithPath:[fileURL absoluteString]];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
}

- (void)testURLOpenInit {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    RCloudFMDatabaseQueue *queue = [[RCloudFMDatabaseQueue alloc] initWithPath:[fileURL absoluteString]];
    XCTAssert(queue, @"Database queue should be returned");
    queue = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
}

- (void)testURLOpenWithOptions {
    NSURL *tempFolder = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *fileURL = [tempFolder URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    
    RCloudFMDatabaseQueue *queue = [RCloudFMDatabaseQueue databaseQueueWithPath:[fileURL absoluteString] flags:SQLITE_OPEN_READWRITE];
    XCTAssertNil(queue, @"Database queue should not have been created");
}


- (void)testQueueSelect
{
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        int count = 0;
        RCloudFMResultSet *rsl = [adb executeQuery:@"select * from qfoo where foo like 'h%'"];
        while ([rsl next]) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
        
        count = 0;
        rsl = [adb executeQuery:@"select * from qfoo where foo like ?", @"h%"];
        while ([rsl next]) {
            count++;
        }
        
        XCTAssertEqual(count, 2);
    }];
}

- (void)testReadOnlyQueue
{
    RCloudFMDatabaseQueue *queue2 = [RCloudFMDatabaseQueue databaseQueueWithPath:self.databasePath flags:SQLITE_OPEN_READONLY];
    XCTAssertNotNil(queue2);

    {
        [queue2 inDatabase:^(RCloudFMDatabase *db2) {
            RCloudFMResultSet *rs1 = [db2 executeQuery:@"SELECT * FROM qfoo"];
            XCTAssertNotNil(rs1);

            [rs1 close];
            
            XCTAssertFalse(([db2 executeUpdate:@"insert into easy values (?)", [NSNumber numberWithInt:3]]), @"Insert should fail because this is a read-only database");
        }];
        
        [queue2 close];
        
        // Check that when we re-open the database, it's still read-only
        [queue2 inDatabase:^(RCloudFMDatabase *db2) {
            RCloudFMResultSet *rs1 = [db2 executeQuery:@"SELECT * FROM qfoo"];
            XCTAssertNotNil(rs1);
            
            [rs1 close];
            
            XCTAssertFalse(([db2 executeUpdate:@"insert into easy values (?)", [NSNumber numberWithInt:3]]), @"Insert should fail because this is a read-only database");
        }];
    }
}

- (void)testStressTest
{
    size_t ops = 16;
    
    dispatch_queue_t dqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(ops, dqueue, ^(size_t nby) {
        
        // just mix things up a bit for demonstration purposes.
        if (nby % 2 == 1) {
            [NSThread sleepForTimeInterval:.01];
            
            [self.queue inTransaction:^(RCloudFMDatabase *adb, BOOL *rollback) {
                RCloudFMResultSet *rsl = [adb executeQuery:@"select * from qfoo where foo like 'h%'"];
                while ([rsl next]) {
                    ;// whatever.
                }
            }];
            
        }
        
        if (nby % 3 == 1) {
            [NSThread sleepForTimeInterval:.01];
        }
        
        [self.queue inTransaction:^(RCloudFMDatabase *adb, BOOL *rollback) {
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('1')"]);
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('2')"]);
            XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('3')"]);
        }];
    });
    
    [self.queue close];
    
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        XCTAssertTrue([adb executeUpdate:@"insert into qfoo values ('1')"]);
    }];
}

- (void)testTransaction
{
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        [adb executeUpdate:@"create table transtest (a integer)"];
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (1)"]);
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (2)"]);
        
        int rowCount = 0;
        RCloudFMResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertEqual(rowCount, 2);
    }];
    
    [self.queue inTransaction:^(RCloudFMDatabase *adb, BOOL *rollback) {
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (3)"]);
        
        if (YES) {
            // uh oh!, something went wrong (not really, this is just a test
            *rollback = YES;
            return;
        }
        
        XCTFail(@"This shouldn't be reached");
    }];
    
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        
        int rowCount = 0;
        RCloudFMResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertFalse([adb hasOpenResultSets]);
        
        XCTAssertEqual(rowCount, 2);
    }];
    
}

- (void)testSavePoint
{
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        [adb executeUpdate:@"create table transtest (a integer)"];
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (1)"]);
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (2)"]);
        
        int rowCount = 0;
        RCloudFMResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertEqual(rowCount, 2);
    }];
    
    [self.queue inSavePoint:^(RCloudFMDatabase *adb, BOOL *rollback) {
        XCTAssertTrue([adb executeUpdate:@"insert into transtest values (3)"]);
        
        if (YES) {
            // uh oh!, something went wrong (not really, this is just a test
            *rollback = YES;
            return;
        }
        
        XCTFail(@"This shouldn't be reached");
    }];
    
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        
        int rowCount = 0;
        RCloudFMResultSet *ars = [adb executeQuery:@"select * from transtest"];
        while ([ars next]) {
            rowCount++;
        }
        
        XCTAssertFalse([adb hasOpenResultSets]);
        
        XCTAssertEqual(rowCount, 2);
    }];
    
}

- (void)testClose
{
    [self.queue inDatabase:^(RCloudFMDatabase *adb) {
        XCTAssertTrue([adb executeUpdate:@"CREATE TABLE close_test (a INTEGER)"]);
        XCTAssertTrue([adb executeUpdate:@"INSERT INTO close_test VALUES (1)"]);
        
        [adb close];
    }];
 }

@end

