//
//  RCKitUtilityTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/3/9.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCKitUtility.h"
#import "RCConversationModel.h"

@interface RCKitUtilityTests : XCTestCase

@end

@implementation RCKitUtilityTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testMethodWithNil {
    RCKitUtility *instance = [[RCKitUtility alloc] init];
    XCTAssertNotNil(instance);
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"getDateFormatterString:" forKey:@"getDateFormatterString:"];
    [RCTestHelper excuteMethodArgumentWithNil:instance except:dic];
}

-(void)testconvertConversationTime{
    XCTAssertNotNil([RCKitUtility convertConversationTime:0]);
    
    XCTAssertNotNil([RCKitUtility convertConversationTime:111111111111111111]);
}

-(void)testconvertMessageTime{
    XCTAssertNotNil([RCKitUtility convertMessageTime:0]);
    
    XCTAssertNotNil([RCKitUtility convertMessageTime:111111111111111111]);

}

-(void)testImageNamed{
    XCTAssertNil([RCKitUtility imageNamed:@"11" ofBundle:nil]);
    XCTAssertNil([RCKitUtility imageNamed:nil ofBundle:nil]);
}

-(void)testGetTextDrawingSize{
    [RCKitUtility getTextDrawingSize:nil font:nil constrainedSize:CGSizeZero];
}

-(void)testFormatMessage{
    XCTAssertNotNil([RCKitUtility formatMessage:nil]);
}


-(void)testIsVisibleMessage{
    RCMessage *msg = [[RCMessage alloc]init];
    msg.content = [RCTextMessage messageWithContent:@""];
    XCTAssertTrue([RCKitUtility isVisibleMessage:msg]);
    XCTAssertFalse([RCKitUtility isVisibleMessage:nil]);
}

-(void)testLocalizedDescription{
    XCTAssertNotNil([RCKitUtility localizedDescription:[RCTextMessage messageWithContent:@"1"]]);
    XCTAssertNotNil([RCKitUtility localizedDescription:nil]);
}

-(void)testGetNotificationUserInfoDictionary{
    RCMessage *message = [[RCMessage alloc]initWithType:ConversationType_PRIVATE targetId:@"11" direction:MessageDirection_SEND messageId:1 content:nil];
    XCTAssertNotNil([RCKitUtility getNotificationUserInfoDictionary:message]);
}

-(void)testGetFileTypeIcon{
    XCTAssertNotNil([RCKitUtility getFileTypeIcon:@"txt"]);
    XCTAssertNotNil([RCKitUtility getFileTypeIcon:@"txtsdfd"]);
}
//
-(void)testGetReadableStringForFileSize{
    NSString *bSize = [RCKitUtility getReadableStringForFileSize:1111111];
    XCTAssertNotNil(bSize);
}
//
-(void)testDefaultConversationHeaderImage{
    RCConversation *conversation = [[RCConversation alloc]init];
    RCConversationModel *model = [[RCConversationModel alloc]initWithConversation:conversation extend:nil];
//    XCTAssertNotNil([RCKitUtility defaultConversationHeaderImage:model]);
}
//
-(void)testdefaultTitleForCollectionConversation{
    RCConversation *conversation = [[RCConversation alloc]init];
    RCConversationModel *model = [[RCConversationModel alloc]initWithConversation:conversation extend:nil];
    XCTAssertNil([RCKitUtility defaultTitleForCollectionConversation:model]);
    conversation = [[RCConversation alloc]init];
    conversation.conversationType = ConversationType_PRIVATE;
    model = [[RCConversationModel alloc]initWithConversation:conversation extend:nil];
    XCTAssertNil([RCKitUtility defaultTitleForCollectionConversation:model]);
}
//
//+ (int)getConversationUnreadCount:(RCConversationModel *)model;
//
//+ (BOOL)getConversationUnreadMentionedStatus:(RCConversationModel *)model;
//
//+ (void)syncConversationReadStatusIfEnabled:(RCConversation *)conversation;
//
//-(void)testgetPinYinUpperFirstLetters:(NSString *)hanZi;
//
//+ (void)openURLInSafariViewOrWebView:(NSString *)url base:(UIViewController *)viewController;
//
//-(void)testcheckOrAppendHttpForUrl:(NSString *)url;
//
//+ (BOOL)validateCellPhoneNumber:(NSString *)cellNum;
//
//+ (BOOL)validateEmail:(NSString *)email;
//
//+ (UIWindow *)getKeyWindow;
//
//+ (UIEdgeInsets)getWindowSafeAreaInsets;
//
-(void)testfixOrientation{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"test" withExtension:@"jpeg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    XCTAssertNotNil([RCKitUtility fixOrientation:image]);
}

-(void)testGetNotificationUserInfoDictionary1{
    XCTAssertNotNil([RCKitUtility getNotificationUserInfoDictionary:ConversationType_PRIVATE fromUserId:@"1" targetId:@"2" objectName:[RCTextMessage getObjectName]]);
    XCTAssertNotNil([RCKitUtility getNotificationUserInfoDictionary:ConversationType_PRIVATE fromUserId:@"1" targetId:@"2" messageContent:[RCTextMessage messageWithContent:@""]]);
}
//
//+ (BOOL)currentDeviceIsIPad;
//
//+ (void)showAlertController:(NSString *)title
//                    message:(NSString *)message
//             preferredStyle:(UIAlertControllerStyle)style
//                    actions:(NSArray<UIAlertAction *> *)actions
//           inViewController:(UIViewController *)controller;
//
//+ (UIColor *)generateDynamicColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;
//
//+ (BOOL)hasLoadedImage:(NSString *)imageUrl;
//
//+ (NSData *)getImageDataForURLString:(NSString *)imageUrl;
//
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
