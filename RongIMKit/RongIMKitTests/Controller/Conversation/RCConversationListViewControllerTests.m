//
//  RCConversationListViewControllerTests.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/24.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RCConversationListViewController.h"
#import "RCTestHelper.h"

@interface RCConversationListViewController (test)
- (void)loadMore;
- (void)updateCellIfNeed:(NSNotification *)notification;
- (void)sendReadReceiptIfNeed:(RCConversationModel *)model;
- (void)onMessageDestructing:(NSNotification *)notification;
- (void)setEmptyConversationView:(UIView *)emptyConversationView;
- (void)setShowConnectingStatusOnNavigatorBar:(BOOL)showConnectingStatusOnNavigatorBar;
@end

@interface RCConversationListViewControllerTests : XCTestCase
@property (nonatomic, strong) RCConversationListViewController *vc;
@end

@implementation RCConversationListViewControllerTests
- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    //    self.vc = [[RCConversationListViewController alloc] initWithCoder:nil];
    //    XCTAssertNotNil(self.vc);
}

- (void)testMethodWithNil {
    RCConversationListViewController *viewCon = [[RCConversationListViewController alloc] initWithCoder:nil];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setValue:@"refreshConversationTableViewWithConversationModel:" forKey:@"refreshConversationTableViewWithConversationModel:"];
    [dic setValue:@"tableView:cellForRowAtIndexPath:" forKey:@"tableView:cellForRowAtIndexPath:"];
    [dic setValue:@"tableView:didSelectRowAtIndexPath:" forKey:@"tableView:didSelectRowAtIndexPath:"];
    [dic setValue:@"rcConversationCollectionView:cellForItemAtIndexPath:" forKey:@"rcConversationCollectionView:cellForItemAtIndexPath:"];
    [dic setValue:@"tableView:heightForRowAtIndexPath:" forKey:@"tableView:heightForRowAtIndexPath:"];
    [RCTestHelper excuteMethodArgumentWithNil:viewCon except:dic];
}

- (void)testViewDidLoad_001 {
    [self.vc viewDidLoad];
}
- (void)testViewDidLoad_002 {
    RCConversationListViewController *viewController =
        [[RCConversationListViewController alloc] initWithDisplayConversationTypes:nil collectionConversationType:nil];
    XCTAssertNotNil(viewController);
    [viewController viewDidLoad];
    [viewController viewWillAppear:YES];
    [viewController viewDidLayoutSubviews];
    [viewController viewDidAppear:YES];
    [viewController viewWillDisappear:YES];
    [viewController viewDidDisappear:YES];
}
- (void)testViewDidLoad_003 {
    NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:-1]];
    RCConversationListViewController *viewController =
        [[RCConversationListViewController alloc] initWithDisplayConversationTypes:array
                                                        collectionConversationType:array];
    XCTAssertNotNil(viewController);
    [viewController viewDidLoad];
}
//
//- (void)testUpdateCellAtIndexPath {
//    [self.vc updateCellAtIndexPath:nil];
//}
//
//- (void)testUpdateCellIfNeed {
//    [self.vc updateCellIfNeed:nil];
//}
//
//- (void)testLoadMore {
//    [self.vc loadMore];
//}
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
//
- (void)testInitWithCoder {
    RCConversationListViewController *viewCon = [[RCConversationListViewController alloc] initWithCoder:nil];
    XCTAssertNotNil(viewCon);
    viewCon =
        [[RCConversationListViewController alloc] initWithDisplayConversationTypes:nil collectionConversationType:nil];
    XCTAssertNotNil(viewCon);
}

- (void)testInitWithNibName {
    RCConversationListViewController *viewCon =
        [[RCConversationListViewController alloc] initWithNibName:@"" bundle:nil];
    XCTAssertNotNil(viewCon);
}

- (void)testSetDisplayConversationTypes {
    NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:-1]];
    [self.vc setDisplayConversationTypes:array];
    [self.vc setDisplayConversationTypes:nil];
}

- (void)testSetCollectionConversationType {
    NSArray *array = [NSArray arrayWithObject:[NSNumber numberWithInt:-1]];
    [self.vc setCollectionConversationType:array];
    [self.vc setCollectionConversationType:nil];
}

- (void)testSetConversationAvatarStyle {
    [self.vc setConversationAvatarStyle:nil];
}

- (void)testSetConversationPortraitSize {
    [self.vc setConversationPortraitSize:CGSizeMake(0, 0)];
}

- (void)testSendReadReceiptIfNeed {
    [self.vc sendReadReceiptIfNeed:nil];
    RCConversationModel *model = [[RCConversationModel alloc] init];
    model.conversationType = ConversationType_PRIVATE;
    model.targetId = @"111";
    [self.vc sendReadReceiptIfNeed:model];
}
- (void)testOnMessageDestructing {
    [self.vc onMessageDestructing:nil];
    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_PRIVATE
                                                targetId:@"111"
                                               direction:MessageDirection_RECEIVE
                                               messageId:-1
                                                 content:nil];
    NSNotification *notif = [[NSNotification alloc] initWithName:nil
                                                          object:nil
                                                        userInfo:@{
                                                            @"message" : message,
                                                            @"remainDuration" : @(1)
                                                        }];
    [self.vc onMessageDestructing:notif];
}
-(void)testSetEmptyConversationView{
    [self.vc setEmptyConversationView:nil];
    [self.vc setEmptyConversationView:[[UIView alloc]initWithFrame:CGRectZero]];
}

- (void)testSetShowConnectingStatusOnNavigatorBar{
    [self.vc setShowConnectingStatusOnNavigatorBar:YES];
    [self.vc setShowConnectingStatusOnNavigatorBar:NO];
}
- (void)testRefreshConversationTableViewWithConversationModel{
    RCConversationModel *model = [[RCConversationModel alloc] init];
    model.conversationType = ConversationType_PRIVATE;
    model.targetId = @"111";
    [self.vc refreshConversationTableViewWithConversationModel:model];
    [self.vc refreshConversationTableViewWithConversationModel:model];
}

- (void)testDidReceiveMessageNotification{
    NSDictionary *dic_left = @{ @"left" : @(1) };
    NSNotification *ntf = [[NSNotification alloc]initWithName:@"" object:nil userInfo:dic_left];
    [self.vc didReceiveMessageNotification:ntf];
    dic_left = @{ @"left" : @(31) };
    ntf = [[NSNotification alloc]initWithName:@"" object:nil userInfo:dic_left];
    [self.vc didReceiveMessageNotification:ntf];
    dic_left = @{ @"left" : @(0) };
    ntf = [[NSNotification alloc]initWithName:@"" object:nil userInfo:dic_left];
    [self.vc didReceiveMessageNotification:ntf];
}
@end
