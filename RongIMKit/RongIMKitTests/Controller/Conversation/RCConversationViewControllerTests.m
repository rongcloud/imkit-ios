//
//  RCConversationViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/18.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCConversationViewController.h"
#import "RCTextMessageCell.h"
#import "RCTestHelper.h"

@interface RCConversationViewController (test)
@property (nonatomic) BOOL isIPad;
@property (nonatomic, assign) NSInteger unReadMessage;
- (void)didTapMessageCell:(RCMessageModel *)model;
- (void)onSelectCustomerServiceGroup:(NSArray *)groupList result:(void (^)(NSString *groupId))resultBlock;
- (void)rightBarButtonItemClicked:(id)sender;
- (void)setupUnReadMessageView;
- (void)currentViewFrameChange:(NSNotification *)notification;
- (void)didTipUnReadButton:(UIButton *)sender;
@end

@interface RCConversationViewControllerTests : XCTestCase
@property (nonatomic, strong) RCConversationViewController *vc;
@end

@implementation RCConversationViewControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.vc = [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(self.vc);
    self.vc.conversationType = ConversationType_PRIVATE;
    NSString *userId = [RCIM sharedRCIM].currentUserInfo.userId;
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [[RCIMClient sharedRCIMClient] insertIncomingMessage:ConversationType_PRIVATE
                                                targetId:@"111"
                                            senderUserId:userId
                                          receivedStatus:ReceivedStatus_UNREAD
                                                 content:[RCTestHelper getTextMessage]
                                                sentTime:nowTime];
    self.vc.targetId = @"111";
    self.vc.isIPad = YES;
}

- (void)testMethodWithNil {
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"inputTextView:shouldChangeTextInRange:replacementText:" forKey:@"inputTextView:shouldChangeTextInRange:replacementText:"];
    [dic setValue:@"uploadMedia:uploadListener:" forKey:@"uploadMedia:uploadListener:"];
    [dic setValue:@"registerClass:forMessageClass:" forKey:@"registerClass:forMessageClass:"];
    [dic setValue:@"rcUnkownConversationCollectionView:cellForItemAtIndexPath:" forKey:@"rcUnkownConversationCollectionView:cellForItemAtIndexPath:"];
    [dic setValue:@"rcConversationCollectionView:cellForItemAtIndexPath:" forKey:@"rcConversationCollectionView:cellForItemAtIndexPath:"];
    [dic setValue:@"collectionView:cellForItemAtIndexPath:" forKey:@"collectionView:cellForItemAtIndexPath:"];
    [dic setValue:@"collectionView:layout:sizeForItemAtIndexPath:" forKey:@"collectionView:layout:sizeForItemAtIndexPath:"];
    [RCTestHelper excuteMethodArgumentWithNil:self.vc except:dic];
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

- (void)testInitWithCoder {
    RCConversationViewController *viewCon = [[RCConversationViewController alloc] initWithCoder:nil];
    XCTAssertNotNil(viewCon);
}

- (void)testInitWithNibName {
    RCConversationViewController *viewCon = [[RCConversationViewController alloc] initWithNibName:@"" bundle:nil];
    XCTAssertNotNil(viewCon);
}

- (void)testScrollToBottomAnimated {
    [self.vc scrollToBottomAnimated:YES];
}

- (void)testLeftBarButtonItemPressed {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_CHATROOM;
    viewController.targetId = @"111";
    [viewController leftBarButtonItemPressed:nil];
}

- (void)testSendMessage {
    [self.vc sendMessage:nil pushContent:nil];
}

- (void)testSendMediaMessage {
//    [self.vc sendMediaMessage:nil pushContent:nil appUpload:YES];
    [self.vc sendMediaMessage:[RCTestHelper getTextMessage] pushContent:nil appUpload:NO];
    [self.vc sendMediaMessage:[RCTestHelper getImageMessage] pushContent:nil appUpload:NO];
}

- (void)testUploadMedia {
    RCUploadMediaStatusListener *block = [[RCUploadMediaStatusListener alloc] initWithMessage:nil
        uploadProgress:^(int progress) {

        }
        uploadSuccess:^(RCMessageContent *content) {

        }
        uploadError:^(RCErrorCode errorCode) {

        }
        uploadCancel:^{

        }];
    [self.vc uploadMedia:nil uploadListener:block];
}

- (void)testCancelUploadMedia {
    [self.vc cancelUploadMedia:nil];
}

- (void)resendMessage {
    [self.vc resendMessage:nil];
}

- (void)testSendImageMessage {
    [self.vc sendImageMessage:nil pushContent:nil];
    [self.vc sendImageMessage:nil pushContent:nil appUpload:nil];
    [self.vc sendImageMessage:[RCTestHelper getImageMessage] pushContent:nil appUpload:NO];
    [self.vc sendImageMessage:[RCTestHelper getTextMessage] pushContent:nil appUpload:NO];
    [self.vc sendImageMessage:[RCTestHelper getFileMessage] pushContent:nil appUpload:NO];
}

- (void)testSendMediaMessage_001 {
    [self.vc sendMediaMessage:nil pushContent:nil];
    [self.vc sendMediaMessage:[RCTestHelper getImageMessage] pushContent:nil];
}
- (void)testAppendAndDisplayMessage {
    [self.vc appendAndDisplayMessage:nil];
}

- (void)testDeleteMessage {
    [self.vc deleteMessage:nil];
}

- (void)testRecallMessage {
    [self.vc recallMessage:-1];
}

- (void)testWillSendMessage {
    [self.vc willSendMessage:nil];
}

- (void)testDidSendMessage {
    [self.vc didSendMessage:0 content:nil];
}

- (void)testRegisterClass {
    [self.vc registerClass:[RCTextMessage class] forMessageClass:[RCTextMessage class]];
    [self.vc registerClass:[RCTextMessageCell class] forMessageClass:[RCTextMessage class]];
}

- (void)testRegisterClassForCellWithReuseIdentifier {
    [self.vc registerClass:nil forCellWithReuseIdentifier:nil];
    [self.vc registerClass:[RCTextMessage class] forCellWithReuseIdentifier:@""];
    [self.vc registerClass:[RCTextMessageCell class] forCellWithReuseIdentifier:@"text"];
}
- (void)testViewDidLoad_001 {
    [self.vc viewDidLoad];
}
- (void)testViewDidLoad_002 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_CHATROOM;
    [viewController viewDidLoad];
    viewController.conversationType = ConversationType_CHATROOM;
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}
- (void)testViewDidLoad_003 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_GROUP;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_004 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_Encrypted;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_005 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_SYSTEM;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_006 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_RTC;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}
- (void)testViewDidLoad_007 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_DISCUSSION;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_008 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_INVALID;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_009 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_APPSERVICE;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}

- (void)testViewDidLoad_010 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_PUBLICSERVICE;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}
- (void)testViewDidLoad_011 {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_CUSTOMERSERVICE;
    [viewController viewDidLoad];
    viewController.targetId = @"111";
    [viewController viewDidLoad];
}
- (void)testDidCancelMessage {
    [self.vc didCancelMessage:nil];
}

- (void)testWillAppendAndDisplayMessage {
    RCMessage *result = [self.vc willAppendAndDisplayMessage:nil];
    XCTAssertNil(result);
}

- (void)testWillDisplayMessageCell {
    [self.vc willDisplayMessageCell:nil atIndexPath:nil];
}

- (void)testWillSelectMessage {
    [self.vc willSelectMessage:nil];
}

- (void)testViewDidLayoutSubviews {
    [self.vc viewDidLayoutSubviews];
}

- (void)testDidTapMessageCell {
    [self.vc didTapMessageCell:nil];
}

- (void)testDidLongTouchMessageCell {
    [self.vc didLongTouchMessageCell:nil inView:nil];
}

- (void)testDidTapUrlInMessageCell {
    [self.vc didTapUrlInMessageCell:nil model:nil];
}

- (void)testDidTapReedit {
    [self.vc didTapReedit:nil];
}

- (void)testDidTapPhoneNumberInMessageCell {
    [self.vc didTapPhoneNumberInMessageCell:nil model:nil];
}

- (void)testDidTapCellPortrait {
    [self.vc didTapCellPortrait:nil];
}

- (void)testDidLongPressCellPortrait {
    [self.vc didLongPressCellPortrait:nil];
}

- (void)testPresentImagePreviewController {
    [self.vc presentImagePreviewController:nil];
}

- (void)testPresentLocationViewController {
    [self.vc presentLocationViewController:nil];
}

- (void)testPresentFilePreviewViewController {
    [self.vc presentFilePreviewViewController:nil];
}

- (void)testDidTapUrlInPublicServiceMessageCell {
    [self.vc didTapUrlInPublicServiceMessageCell:nil model:nil];
}

- (void)testViewWillLayoutSubviews {
    [self.vc viewWillLayoutSubviews];
}

- (void)testOnSelectCustomerServiceGroup {
    [self.vc onSelectCustomerServiceGroup:nil result:nil];
    RCCustomerServiceGroupItem *item = [[RCCustomerServiceGroupItem alloc] init];
    item.online = YES;
    [self.vc onSelectCustomerServiceGroup:@[ item ] result:nil];
    [self.vc onSelectCustomerServiceGroup:@[ item ]
                                   result:^(NSString *groupId){

                                   }];
}

- (void)testAlertErrorAndLeft {
    [self.vc alertErrorAndLeft:nil];
}

- (void)testRightBarButtonItemClicked {
    RCConversationViewController *viewController =
        [[RCConversationViewController alloc] initWithConversationType:-1 targetId:@""];
    XCTAssertNotNil(viewController);
    viewController.conversationType = ConversationType_PUBLICSERVICE;
    viewController.targetId = @"111";
    [viewController rightBarButtonItemClicked:nil];
    viewController.conversationType = ConversationType_PRIVATE;
    viewController.targetId = @"111";
    [viewController rightBarButtonItemClicked:nil];
}

- (void)testViewWillAppear {
    RCMessage *msg = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                            targetId:@"111"
                                           direction:MessageDirection_SEND
                                           messageId:111111
                                             content:[RCTestHelper getTextMessage]];
    RCMessageModel *model = [RCMessageModel modelWithMessage:msg];
    [self.vc.conversationDataRepository addObject:model];
    self.vc.locatedMessageSentTime = model.sentTime;
    [self.vc viewWillAppear:YES];
}
- (void)testSetupUnReadMessageView {
    [self.vc setupUnReadMessageView];
}

- (void)testCurrentViewFrameChange {
    [self.vc currentViewFrameChange:nil];
}

- (void)testDidTipUnReadButton {
    [self.vc didTipUnReadButton:nil];
}

- (void)testDisappear {
    [self.vc viewDidAppear:YES];
    [self.vc viewDidDisappear:YES];
    [self.vc viewWillDisappear:YES];
}

- (void)testUnReadNewMessageLabel {
    XCTAssertNotNil([self.vc unReadNewMessageLabel]);
}

- (void)testForwardMessage {
    [self.vc forwardMessage:-1 completed:nil];
}
@end
