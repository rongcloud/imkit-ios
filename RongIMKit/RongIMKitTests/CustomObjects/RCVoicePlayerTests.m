//
//  RCVoicePlayerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/4.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCVoicePlayer.h"
#import "RCTestHelper.h"

@interface RCVoicePlayerTests : XCTestCase

@end

@implementation RCVoicePlayerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)testInit{
    RCVoicePlayer *item = [RCVoicePlayer defaultPlayer];
    XCTAssertNotNil(item);
    item.conversationType = ConversationType_PRIVATE;
    item.messageId = 111;
    item.targetId = @"11";
    NSMutableDictionary *dic =[NSMutableDictionary new];
    [dic setValue:@"sendPlayFinishNotification" forKey:@"sendPlayFinishNotification"];
    [dic setValue:@"audioPlayerDidFinishPlaying:successfully:" forKey:@"audioPlayerDidFinishPlaying:successfully:"];
    [dic setValue:@"audioPlayerDecodeErrorDidOccur:error:" forKey:@"audioPlayerDecodeErrorDidOccur:error:"];
    [RCTestHelper excuteMethodArgumentWithNil:item except:dic];
}

-(void)testPlay{
    BOOL result = [[RCVoicePlayer defaultPlayer]playVoice:ConversationType_PRIVATE targetId:nil messageId:1 direction:MessageDirection_SEND voiceData:nil observer:nil];
    XCTAssertFalse(result);
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"wavDec" withExtension:@"wav"];
    NSData *data = [NSData dataWithContentsOfURL:url];

    result = [[RCVoicePlayer defaultPlayer]playVoice:ConversationType_PRIVATE targetId:@"111" messageId:1 direction:MessageDirection_SEND voiceData:data observer:nil];
    XCTAssertTrue(result);
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
