//
//  RCConversationListViewController.m
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCConversationListViewController.h"
#import "RCConversationCell.h"
#import "RCConversationCellUpdateInfo.h"
#import "RCConversationViewController.h"
#import "RCIM.h"
#import "RCKitCommonDefine.h"
#import "RCKitUtility.h"
#import "RCNetworkIndicatorView.h"
#import "RCIMClient+Destructing.h"
#import "RCMJRefresh.h"
#define PagingCount 100
@interface UIImage (RCDynamicImage)
+ (UIImage *)rc_imageWithLocalPath:(NSString *)path;
@property (nonatomic, copy) NSString *rc_imageLocalPath;
- (BOOL)rc_needReloadImage;
@end

@interface RCConversationListViewController () <UITableViewDataSource, UITableViewDelegate, RCConversationCellDelegate>

@property (nonatomic, assign) BOOL isConverstaionListAppear;
@property (nonatomic, assign) BOOL isWaitingForForceRefresh;
@property (nonatomic, strong) UIView *connectionStatusView;
@property (nonatomic, strong) UIView *navigationTitleView;
@property (nonatomic, strong) dispatch_queue_t updateEventQueue;
@property (nonatomic, strong) RCMJRefreshAutoNormalFooter *footer;
@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, strong) NSMutableDictionary *collectedModelDict;
@property (nonatomic, copy) void(^throttleReloadAction)(void);
@end

@implementation RCConversationListViewController

#pragma mark - 初始化
- (instancetype)initWithDisplayConversationTypes:(NSArray *)displayConversationTypeArray
                      collectionConversationType:(NSArray *)collectionConversationTypeArray {
    self = [super init];
    if (self) {
        self.displayConversationTypeArray = displayConversationTypeArray;
        self.collectionConversationTypeArray = collectionConversationTypeArray;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (void)rcinit {
    self.updateEventQueue = dispatch_queue_create("cn.rongcloud.conversation.updateEventQueue", NULL);
    self.isConverstaionListAppear = NO;
    self.isEnteredToCollectionViewController = NO;
    self.isShowNetworkIndicatorView = YES;
    self.showConversationListWhileLogOut = YES;
    self.cellBackgroundColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0xffffff)
                                                        darkColor:[HEXCOLOR(0x1c1c1e) colorWithAlphaComponent:0.4]];
    self.topCellBackgroundColor = [RCKitUtility generateDynamicColor:HEXCOLOR(0xf2faff)
                                                           darkColor:[HEXCOLOR(0x171717) colorWithAlphaComponent:0.8]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setExtendedLayoutIncludesOpaqueBars:)]) {
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    self.conversationListDataSource = [[NSMutableArray alloc] init];
    self.conversationListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.conversationListTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.conversationListTableView.backgroundColor = RCDYCOLOR(0xffffff, 0x000000);
    if ([self.conversationListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.conversationListTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    if ([self.conversationListTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.conversationListTableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    self.conversationListTableView.dataSource = self;
    self.conversationListTableView.delegate = self;
    
    self.currentCount = 0;
    self.footer = [RCMJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    self.footer.refreshingTitleHidden = YES;
    self.conversationListTableView.rcmj_footer = self.footer;
    [self.view addSubview:self.conversationListTableView];
    [self registerObserver];
}

- (void)loadMore {
    __block RCConversationModel *lastModel;
    __block long long sentTime = 0;
    __weak typeof(self) ws = self;
    dispatch_async(self.updateEventQueue, ^{
        NSMutableArray *modelList = [[NSMutableArray alloc] init];
        if (ws.showConversationListWhileLogOut || [[RCIM sharedRCIM] getConnectionStatus] != ConnectionStatus_SignOut) {
            lastModel = ws.conversationListDataSource.lastObject;
            if (lastModel && lastModel.sentTime > 0) {
                sentTime = lastModel.sentTime;
            }
            NSArray *conversationList =
                [[RCIMClient sharedRCIMClient] getConversationList:ws.displayConversationTypeArray
                                                             count:PagingCount
                                                         startTime:sentTime];
            self.currentCount += conversationList.count;
            for (RCConversation *conversation in conversationList) {
                RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
                if (![self containInCurrentDataSource:model]) {
                    model.topCellBackgroundColor = ws.topCellBackgroundColor;
                    model.cellBackgroundColor = ws.cellBackgroundColor;
                    [modelList addObject:model];
                }
            }
        }
        if (modelList.count > 0) {
            modelList = [ws willReloadTableData:modelList];
            modelList = [ws collectConversation:modelList collectionTypes:ws.collectionConversationTypeArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws.conversationListDataSource addObjectsFromArray:modelList.copy];
                [ws.conversationListTableView reloadData];
                [ws updateEmptyConversationView];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.footer endRefreshing];
        });
    });
}

- (BOOL)containInCurrentDataSource:(RCConversationModel *)model {
    for (RCConversationModel *tmpModel in self.conversationListDataSource) {
        if (tmpModel.conversationType == model.conversationType && [tmpModel.targetId isEqualToString:model.targetId]) {
            return YES;
        }
    }
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateNetworkIndicatorView];
    [self refreshConversationTableViewIfNeeded];
    self.isConverstaionListAppear = YES;
    [self layoutSubview:CGSizeZero];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutSubview:size];
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context){

        }];
}

- (void)layoutSubview:(CGSize)size {
    if (![RCKitUtility currentDeviceIsIPad]) {
        return;
    }
    self.conversationListTableView.frame = self.view.bounds;
    [self.conversationListTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateConnectionStatusView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.isConverstaionListAppear = NO;
    [self.conversationListTableView setEditing:NO];
}

#pragma mark - 监听
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onConnectionStatusChangedNotification:)
                                                 name:RCKitDispatchConnectionStatusChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveReadReceiptNotification:)
                                                 name:RCLibDispatchReadReceiptNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRecallMessageNotification:)
                                                 name:RCKitDispatchRecallMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshConversationTableViewIfNeeded)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageSentStatusUpdate:)
                                                 name:@"RCKitSendingMessageNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCellIfNeed:)
                                                 name:RCKitConversationCellUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageDestructing:)
                                                 name:RCKitMessageDestructingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conversationStatusChanged:)
                                                 name:RCKitDispatchConversationStatusChangeNotification
                                               object:nil];
}

- (void)updateCellIfNeed:(NSNotification *)notification {
    RCConversationCellUpdateInfo *updateInfo = notification.object;
    dispatch_main_async_safe(^{
        for (int i = 0; i < self.conversationListDataSource.count; i++) {
            RCConversationModel *model = self.conversationListDataSource[i];
            if ([updateInfo.model isEqual:model]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                [self updateCellAtIndexPath:indexPath];
                break;
            }
        }
    });
}

#pragma mark - Private

- (void)sendReadReceiptIfNeed:(RCConversationModel *)model {
    if ((model.conversationType == ConversationType_PRIVATE || model.conversationType == ConversationType_Encrypted) &&
        [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(model.conversationType)] &&
        model.lastestMessageDirection == MessageDirection_RECEIVE) {
        RCMessage *latestMsg = [[RCIMClient sharedRCIMClient] getMessage:model.lastestMessageId];
        if (latestMsg.receivedStatus == ReceivedStatus_UNREAD) {
            [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:latestMsg.conversationType
                                                         targetId:latestMsg.targetId
                                                             time:latestMsg.sentTime
                                                          success:nil
                                                            error:nil];
        }
    }
}

- (void(^)(void))getThrottleActionWithTimeInteval:(double)timeInteval action:(void(^)(void))action {
    __block BOOL canAction = NO;
    return ^{
        if (canAction == NO) {
            canAction = YES;
        } else {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeInteval * NSEC_PER_SEC)), self.updateEventQueue, ^{
            canAction = NO;
            action();
        });
    };
}

#pragma mark - 消息阅后即焚

/**
 阅后即焚消息正在焚烧的回调

 @param notification 通知对象
 notification的object为nil，userInfo为NSDictionary对象，
 其中key值分别为@"message"、@"remainDuration"
 对应的value为焚烧的消息对象、该消息剩余的焚烧时间。

 @discussion
 该方法即RCKitMessageDestructingNotification通知方法，如果继承该类则不需要注册RCKitMessageDestructingNotification通知，直接实现该方法即可
 @discussion 如果您使用IMLib请参考RCIMClient的RCMessageDestructDelegate
 */
- (void)onMessageDestructing:(NSNotification *)notification {

    NSDictionary *dataDict = notification.userInfo;
    RCMessage *message = dataDict[@"message"];
    NSInteger duration = [dataDict[@"remainDuration"] integerValue];

    if (duration <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *refreshTargetId = message.targetId;
            NSInteger refreshIndex = -1;
            RCConversationModelType modelType = RC_CONVERSATION_MODEL_TYPE_NORMAL;
            for (RCConversationModel *model in self.conversationListDataSource) {
                if ([model.targetId isEqualToString:refreshTargetId]) {
                    modelType = model.conversationModelType;
                    refreshIndex = [self.conversationListDataSource indexOfObject:model];
                    break;
                }
            }

            if (self.conversationListDataSource.count <= 0) {
                [self refreshConversationTableViewIfNeeded];
                return;
            }

            if (refreshIndex < 0) {
                return;
            }
            RCConversation *conversation =
                [[RCIMClient sharedRCIMClient] getConversation:message.conversationType targetId:message.targetId];
            RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
            model.topCellBackgroundColor = self.topCellBackgroundColor;
            model.cellBackgroundColor = self.cellBackgroundColor;
            model.conversationModelType = modelType;
            self.conversationListDataSource[refreshIndex] = model;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:refreshIndex inSection:0];
            [self.conversationListTableView reloadRowsAtIndexPaths:@[ indexPath ]
                                                  withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self messageDestructing:notification];
    });
}

- (void)onConnectionStatusChangedNotification:(NSNotification *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateConnectionStatusView];
        [self updateNetworkIndicatorView];
        if (ConnectionStatus_Connected == [status.object integerValue]) {
            if (self.conversationListDataSource.count == 0) {
                [self refreshConversationTableViewIfNeeded];
            }
        }
    });
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    dispatch_async(self.updateEventQueue, ^{
        int left = [notification.userInfo[@"left"] intValue];
        if (self.isConverstaionListAppear) {
            self.throttleReloadAction();
        }
        if (left == 0) {
            [self notifyUpdateUnreadMessageCount];
        }
    });
}

- (void)didReceiveReadReceiptNotification:(NSNotification *)notification {
    dispatch_async(self.updateEventQueue, ^{
        RCConversationType conversationType = (RCConversationType)[notification.userInfo[@"cType"] integerValue];
        long long readTime = [notification.userInfo[@"messageTime"] longLongValue];
        NSString *targetId = notification.userInfo[@"tId"];
        NSString *senderUserId = notification.userInfo[@"fId"];

        if ([self.displayConversationTypeArray containsObject:@(conversationType)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                for (RCConversationModel *model in self.conversationListDataSource) {
                    if ([model isMatching:conversationType targetId:targetId]) {

                        if ([senderUserId isEqualToString:[RCIMClient sharedRCIMClient]
                                                              .currentUserInfo
                                                              .userId]) { //由于多端阅读消息数同步而触发通知执行该方法时
                            if (model.unreadMessageCount != 0) {
                                NSInteger unreadMessageCount;
                                if (model.lastestMessageDirection == MessageDirection_RECEIVE &&
                                    model.sentTime <= readTime) {
                                    unreadMessageCount = 0;
                                } else {
                                    unreadMessageCount = [RCKitUtility getConversationUnreadCount:model];
                                }

                                if (unreadMessageCount != model.unreadMessageCount) {
                                    model.unreadMessageCount = unreadMessageCount;
                                    RCConversationCellUpdateInfo *updateInfo =
                                        [[RCConversationCellUpdateInfo alloc] init];
                                    updateInfo.model = model;
                                    updateInfo.updateType = RCConversationCell_UnreadCount_Update;
                                    [[NSNotificationCenter defaultCenter]
                                        postNotificationName:RCKitConversationCellUpdateNotification
                                                      object:updateInfo
                                                    userInfo:nil];
                                }
                            }

                            if (model.hasUnreadMentioned) {
                                BOOL hasUnreadMentioned = [RCKitUtility getConversationUnreadMentionedStatus:model];
                                if (hasUnreadMentioned != model.hasUnreadMentioned) {
                                    if (hasUnreadMentioned) {
                                        model.mentionedCount += 1;
                                    }
                                    RCConversationCellUpdateInfo *updateInfo =
                                        [[RCConversationCellUpdateInfo alloc] init];
                                    updateInfo.model = model;
                                    updateInfo.updateType = RCConversationCell_MessageContent_Update;
                                    [[NSNotificationCenter defaultCenter]
                                        postNotificationName:RCKitConversationCellUpdateNotification
                                                      object:updateInfo
                                                    userInfo:nil];
                                }
                            }
                            [self notifyUpdateUnreadMessageCount];
                        } else { //由于已读回执而触发通知执行该方法时
                            if ([[RCIM sharedRCIM]
                                        .enabledReadReceiptConversationTypeList containsObject:@(conversationType)]) {
                                if (model.lastestMessageDirection == MessageDirection_SEND &&
                                    model.sentTime <= readTime && model.sentStatus != SentStatus_READ) {
                                    model.sentStatus = SentStatus_READ;
                                    RCConversationCellUpdateInfo *updateInfo =
                                        [[RCConversationCellUpdateInfo alloc] init];
                                    updateInfo.model = model;
                                    updateInfo.updateType = RCConversationCell_SentStatus_Update;
                                    [[NSNotificationCenter defaultCenter]
                                        postNotificationName:RCKitConversationCellUpdateNotification
                                                      object:updateInfo
                                                    userInfo:nil];
                                }
                            }
                        }
                        break;
                    }
                }
            });
        }
    });
}

- (void)didReceiveRecallMessageNotification:(NSNotification *)notification {
    dispatch_async(self.updateEventQueue, ^{
        long messageId = [notification.object longValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
            NSString *targetId = message.targetId;
            for (RCConversationModel *model in self.conversationListDataSource) {
                if ([targetId isEqualToString:model.targetId] || model.lastestMessageId == messageId) {

                    RCConversation *conversation =
                        [[RCIMClient sharedRCIMClient] getConversation:model.conversationType targetId:model.targetId];
                    model.lastestMessage = conversation.lastestMessage;
                    model.lastestMessageId = conversation.lastestMessageId;
                    model.mentionedCount = conversation.mentionedCount;
                    NSInteger unreadMessageCount =
                        [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType targetId:model.targetId];
                    if (unreadMessageCount != model.unreadMessageCount) {
                        RCConversationCellUpdateInfo *unreadUpdateInfo = [[RCConversationCellUpdateInfo alloc] init];
                        model.unreadMessageCount = unreadMessageCount;
                        unreadUpdateInfo.model = model;
                        unreadUpdateInfo.updateType = RCConversationCell_UnreadCount_Update;
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:RCKitConversationCellUpdateNotification
                                          object:unreadUpdateInfo
                                        userInfo:nil];
                    }
                    RCConversationCellUpdateInfo *updateInfo = [[RCConversationCellUpdateInfo alloc] init];
                    updateInfo.model = model;
                    updateInfo.updateType = RCConversationCell_MessageContent_Update;
                    [[NSNotificationCenter defaultCenter] postNotificationName:RCKitConversationCellUpdateNotification
                                                                        object:updateInfo
                                                                      userInfo:nil];
                    break;
                } else if (!message) {
                    if (model.unreadMessageCount > 0) {
                        RCConversationCellUpdateInfo *unreadUpdateInfo = [[RCConversationCellUpdateInfo alloc] init];
                        model.unreadMessageCount = [[RCIMClient sharedRCIMClient] getUnreadCount:model.conversationType
                                                                                        targetId:model.targetId];
                        unreadUpdateInfo.model = model;
                        unreadUpdateInfo.updateType = RCConversationCell_UnreadCount_Update;
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:RCKitConversationCellUpdateNotification
                                          object:unreadUpdateInfo
                                        userInfo:nil];
                    }
                }
            }
        });
    });
}

- (void)refreshConversationTableViewIfNeeded {
    __weak typeof(self) weakSelf = self;
    [self forceLoadConversationModelList:^(NSMutableArray *modelList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.conversationListDataSource = modelList;
            [weakSelf.conversationListTableView reloadData];
            [weakSelf updateEmptyConversationView];
        });
    }];
}

- (void)forceLoadConversationModelList:(void (^)(NSMutableArray *modelList))completion {
    dispatch_async(self.updateEventQueue, ^{
        NSMutableArray *modelList = [[NSMutableArray alloc] init];

        if (self.showConversationListWhileLogOut ||
            [[RCIM sharedRCIM] getConnectionStatus] != ConnectionStatus_SignOut) {
            int c = self.currentCount < PagingCount ? PagingCount : (int)self.currentCount;
            NSArray *conversationList =
                [[RCIMClient sharedRCIMClient] getConversationList:self.displayConversationTypeArray
                                                             count:c
                                                         startTime:0];
            for (RCConversation *conversation in conversationList) {
                RCConversationModel *model = [[RCConversationModel alloc] initWithConversation:conversation extend:nil];
                model.topCellBackgroundColor = self.topCellBackgroundColor;
                model.cellBackgroundColor = self.cellBackgroundColor;
                [modelList addObject:model];
            }
        }
        self.currentCount = modelList.count;
        self.collectedModelDict = [NSMutableDictionary new];
        modelList = [self willReloadTableData:modelList];
        modelList = [self collectConversation:modelList collectionTypes:self.collectionConversationTypeArray];

        if (completion) {
            completion(modelList);
        }
    });
}

- (NSMutableArray *)collectConversation:(NSMutableArray *)modelList collectionTypes:(NSArray *)collectionTypes {
    if (collectionTypes.count == 0) {
        return modelList;
    }

    for (RCConversationModel *model in modelList.copy) {
        if ([collectionTypes containsObject:@(model.conversationType)]) {
            RCConversationModel *collectedModel = self.collectedModelDict[@(model.conversationType)];
            if (collectedModel) {
                collectedModel.unreadMessageCount += model.unreadMessageCount;
                collectedModel.mentionedCount = model.mentionedCount;
                collectedModel.isTop |= model.isTop;
                [modelList removeObject:model];
            } else {
                model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_COLLECTION;
                [self.collectedModelDict setObject:model forKey:@(model.conversationType)];
            }
        }
    }

    return modelList;
}

- (NSUInteger)getFirstModelIndex:(BOOL)isTop sentTime:(long long)sentTime {
    if (isTop || self.conversationListDataSource.count == 0) {
        return 0;
    } else {
        for (NSUInteger index = 0; index < self.conversationListDataSource.count; index++) {
            RCConversationModel *model = self.conversationListDataSource[index];
            if (model.isTop == isTop && sentTime >= model.sentTime) {
                return index;
            }
        }
        return self.conversationListDataSource.count - 1;
    }
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversationListDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];

    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        RCConversationBaseCell *userCustomCell =
            [self rcConversationListTableView:tableView cellForRowAtIndexPath:indexPath];
        if (!userCustomCell) {
            NSLog(@"自定义显示的 cell 返回为 nil, "
                  @"如果会话类型是系统消息类型，并且是 RCContactNotificationMessage "
                  @"类型的消息，需要自定义 "
                  @"cell "
                  @"显示");
        }
        userCustomCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        [userCustomCell setDataModel:model];
        [self willDisplayConversationTableCell:userCustomCell atIndexPath:indexPath];

        return userCustomCell;
    } else {
        static NSString *cellReuseIndex = @"rc.conversationList.cellReuseIndex";
        RCConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIndex];
        if (!cell) {
            cell =
                [[RCConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIndex];
        }
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        [cell setDataModel:model];
        [self willDisplayConversationTableCell:cell atIndexPath:indexPath];

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION) {
        return [self rcConversationListTableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return [RCIM sharedRCIM].globalConversationPortraitSize.height + 18.5f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCConversationModel *model = self.conversationListDataSource[indexPath.row];

    if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
        NSLog(@"从SDK 2.3.0版本开始, 公众号会话点击处理放到demo中处理, "
              @"请参考RCDChatListViewController文件中的onSelectedTableRow函数");
    }
    [self onSelectedTableRow:model.conversationModelType conversationModel:model atIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.isShowNetworkIndicatorView && !self.networkIndicatorView.hidden) {
        return self.networkIndicatorView.bounds.size.height;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.isShowNetworkIndicatorView && !self.networkIndicatorView.hidden) {
        return self.networkIndicatorView;
    } else {
        return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RCConversationModel *model = self.conversationListDataSource[indexPath.row];

        if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL ||
            model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_PUBLIC_SERVICE) {
            if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
                [self sendReadReceiptIfNeed:model];
            }
            [[RCIMClient sharedRCIMClient] removeConversation:model.conversationType targetId:model.targetId];
            [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
            [self.conversationListTableView deleteRowsAtIndexPaths:@[ indexPath ]
                                                  withRowAnimation:UITableViewRowAnimationFade];
        } else if (model.conversationModelType == RC_CONVERSATION_MODEL_TYPE_COLLECTION) {
            [[RCIMClient sharedRCIMClient] clearConversations:@[ @(model.conversationType) ]];
            [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
            [self.conversationListTableView deleteRowsAtIndexPaths:@[ indexPath ]
                                                  withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self rcConversationListTableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
        }

        [self didDeleteConversationCell:model];
        [self notifyUpdateUnreadMessageCount];

        if (self.isEnteredToCollectionViewController && self.conversationListDataSource.count == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                           ^{
                               [self.conversationListTableView removeFromSuperview];
                               [self.navigationController popViewControllerAnimated:YES];
                           });
        } else {
            [self updateEmptyConversationView];
        }
    } else {
        NSLog(@"editingStyle %ld is unsupported.", (long)editingStyle);
    }
}

- (NSString *)tableView:(UITableView *)tableView
    titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedStringFromTable(@"Delete", @"RongCloudKit", nil);
}

#pragma mark - View Setter&Getter
- (RCNetworkIndicatorView *)networkIndicatorView {
    if (!_networkIndicatorView) {
        _networkIndicatorView = [[RCNetworkIndicatorView alloc]
            initWithText:NSLocalizedStringFromTable(@"ConnectionIsNotReachable", @"RongCloudKit", nil)];
        _networkIndicatorView.backgroundColor = RCDYCOLOR(0xffdfdf, 0x262626);
        [_networkIndicatorView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _networkIndicatorView.hidden = YES;
    }
    return _networkIndicatorView;
}

- (UIView *)connectionStatusView {
    if (!_connectionStatusView) {
        _connectionStatusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];

        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView startAnimating];
        [_connectionStatusView addSubview:indicatorView];

        NSString *loading = NSLocalizedStringFromTable(@"Connecting...", @"RongCloudKit", nil);
        CGSize textSize = [RCKitUtility getTextDrawingSize:loading
                                                      font:[UIFont systemFontOfSize:16]
                                           constrainedSize:CGSizeMake(_connectionStatusView.frame.size.width, 2000)];

        CGRect frame = CGRectMake(
            (_connectionStatusView.frame.size.width - (indicatorView.frame.size.width + textSize.width + 3)) / 2,
            (_connectionStatusView.frame.size.height - indicatorView.frame.size.height) / 2,
            indicatorView.frame.size.width, indicatorView.frame.size.height);
        indicatorView.frame = frame;
        frame = CGRectMake(indicatorView.frame.origin.x + 14 + indicatorView.frame.size.width,
                           (_connectionStatusView.frame.size.height - textSize.height) / 2, textSize.width,
                           textSize.height);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setText:loading];
        //    [label setTextColor:[UIColor whiteColor]];
        [_connectionStatusView addSubview:label];
    }
    return _connectionStatusView;
}

@synthesize emptyConversationView = _emptyConversationView;
- (UIView *)emptyConversationView {
    if (!_emptyConversationView) {
        _emptyConversationView = [[UIImageView alloc] initWithImage:IMAGE_BY_NAMED(@"no_message_img")];
        _emptyConversationView.center = self.view.center;
        CGRect emptyRect = _emptyConversationView.frame;
        emptyRect.origin.y -= 36;
        [_emptyConversationView setFrame:emptyRect];
        UILabel *emptyLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(-10, _emptyConversationView.frame.size.height,
                                                      _emptyConversationView.frame.size.width + 20, 20)];
        emptyLabel.text = NSLocalizedStringFromTable(@"no_message", @"RongCloudKit", nil);
        [emptyLabel setFont:[UIFont systemFontOfSize:14.f]];
        [emptyLabel setTextColor:[UIColor lightGrayColor]];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyConversationView addSubview:emptyLabel];
        [self.conversationListTableView addSubview:_emptyConversationView];
    }
    return _emptyConversationView;
}

- (void)setEmptyConversationView:(UIView *)emptyConversationView {
    if (_emptyConversationView) {
        [_emptyConversationView removeFromSuperview];
    }
    _emptyConversationView = emptyConversationView;
    [self.conversationListTableView addSubview:_emptyConversationView];
}

- (void)updateNetworkIndicatorView {
    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];

    BOOL needReloadTableView = NO;
    if (status == ConnectionStatus_NETWORK_UNAVAILABLE || status == ConnectionStatus_UNKNOWN ||
        status == ConnectionStatus_Unconnected) {
        if (self.networkIndicatorView.hidden) {
            needReloadTableView = YES;
        }
        self.networkIndicatorView.hidden = NO;
    } else if (status != ConnectionStatus_Connecting) {
        if (!self.networkIndicatorView.hidden) {
            needReloadTableView = YES;
        }
        self.networkIndicatorView.hidden = YES;
    }

    if (needReloadTableView) {
        [self.conversationListTableView reloadData];
    }
}

- (void)updateConnectionStatusView {
    if (self.isEnteredToCollectionViewController || !self.showConnectingStatusOnNavigatorBar ||
        !self.isConverstaionListAppear) {
        return;
    }

    RCConnectionStatus status = [[RCIMClient sharedRCIMClient] getConnectionStatus];
    if (status == ConnectionStatus_Connecting || status == ConnectionStatus_Suspend) {
        [self showConnectingView];
    } else {
        [self hideConnectingView];
    }

    //接口向后兼容 [[++
    [self performSelector:@selector(updateConnectionStatusOnNavigatorBar)];
    //接口向后兼容 --]]
}

- (void)showConnectingView {
    UINavigationItem *visibleNavigationItem = nil;
    if (self.tabBarController) {
        visibleNavigationItem = self.tabBarController.navigationItem;
    } else if (self.navigationItem) {
        visibleNavigationItem = self.navigationItem;
    }

    if (visibleNavigationItem) {
        if (![visibleNavigationItem.titleView isEqual:self.connectionStatusView]) {
            self.navigationTitleView = visibleNavigationItem.titleView;
            visibleNavigationItem.titleView = self.connectionStatusView;
        }
    }
}

- (void)hideConnectingView {
    UINavigationItem *visibleNavigationItem = nil;
    if (self.tabBarController) {
        visibleNavigationItem = self.tabBarController.navigationItem;
    } else if (self.navigationItem) {
        visibleNavigationItem = self.navigationItem;
    }

    if (visibleNavigationItem) {
        if ([visibleNavigationItem.titleView isEqual:self.connectionStatusView]) {
            visibleNavigationItem.titleView = self.navigationTitleView;
        } else {
            self.navigationTitleView = visibleNavigationItem.titleView;
        }
    }

    //接口向后兼容 [[++
    [self performSelector:@selector(setNavigationItemTitleView)];
    //接口向后兼容 --]]
}

- (void)updateEmptyConversationView {
    if (self.conversationListDataSource.count == 0) {
        self.emptyConversationView.hidden = NO;
    } else {
        self.emptyConversationView.hidden = YES;
    }
}

- (void)setIsConverstaionListAppear:(BOOL)isConverstaionListAppear {
    _isConverstaionListAppear = isConverstaionListAppear;
    if (!_isConverstaionListAppear) {
        [self hideConnectingView];
    }
}

- (void)setShowConnectingStatusOnNavigatorBar:(BOOL)showConnectingStatusOnNavigatorBar {
    _showConnectingStatusOnNavigatorBar = showConnectingStatusOnNavigatorBar;
    if (!_showConnectingStatusOnNavigatorBar) {
        [self hideConnectingView];
    }
}


- (void (^)(void))throttleReloadAction{
    if (!_throttleReloadAction) {
        __weak typeof(self) weakSelf = self;
        _throttleReloadAction = [self getThrottleActionWithTimeInteval:0.5 action:^{
            [weakSelf refreshConversationTableViewIfNeeded];
        }];
    }
    return _throttleReloadAction;
}
#pragma mark - 钩子
- (void)messageDestructing:(NSNotification *)notification {
}
- (void)notifyUpdateUnreadMessageCount {
}
- (void)didTapCellPortrait:(RCConversationModel *)model {
}
- (void)didLongPressCellPortrait:(RCConversationModel *)model {
}
- (NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource {
    return dataSource;
}
- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}
- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
}
- (void)didDeleteConversationCell:(RCConversationModel *)model {
}
- (void)rcConversationListTableView:(UITableView *)tableView
                 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                  forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (RCConversationBaseCell *)rcConversationListTableView:(UITableView *)tableView
                                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (CGFloat)rcConversationListTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.5f;
}

#pragma mark - 向后兼容
- (void)resetConversationListBackgroundViewIfNeeded {
}
- (void)updateConnectionStatusOnNavigatorBar {
}
- (void)setNavigationItemTitleView {
}
- (void)setDisplayConversationTypes:(NSArray *)conversationTypeArray {
    self.displayConversationTypeArray = conversationTypeArray;
}
- (void)setCollectionConversationType:(NSArray *)conversationTypeArray {
    self.collectionConversationTypeArray = conversationTypeArray;
}
- (void)setConversationAvatarStyle:(RCUserAvatarStyle)avatarStyle {
    [RCIM sharedRCIM].globalConversationAvatarStyle = avatarStyle;
}
- (void)setConversationPortraitSize:(CGSize)size {
    [RCIM sharedRCIM].globalConversationPortraitSize = size;
}
- (void)refreshConversationTableViewWithConversationModel:(RCConversationModel *)conversationModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        RCConversationModel *matchingModel = nil;
        for (RCConversationModel *model in self.conversationListDataSource) {
            if ([model isMatching:conversationModel.conversationType targetId:conversationModel.targetId]) {
                matchingModel = model;
                break;
            }
        }

        if (matchingModel) {
            NSUInteger oldIndex = [self.conversationListDataSource indexOfObject:matchingModel];
            NSUInteger newIndex = [self getFirstModelIndex:matchingModel.isTop sentTime:matchingModel.sentTime];

            if (oldIndex == newIndex) {
                [self.conversationListTableView
                    reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:newIndex inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self.conversationListDataSource removeObjectAtIndex:oldIndex];
                [self.conversationListDataSource insertObject:matchingModel atIndex:newIndex];

                [self.conversationListTableView beginUpdates];
                [self.conversationListTableView
                    deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:oldIndex inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.conversationListTableView
                    insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:newIndex inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.conversationListTableView endUpdates];
            }
        } else {
            NSUInteger newIndex = [self getFirstModelIndex:conversationModel.isTop sentTime:conversationModel.sentTime];
            [self.conversationListDataSource insertObject:conversationModel atIndex:newIndex];
            [self.conversationListTableView
                insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:newIndex inSection:0] ]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        [self updateEmptyConversationView];
    });
}

- (void)onMessageSentStatusUpdate:(NSNotification *)notification {
    NSDictionary *statusDic = notification.userInfo;

    if (statusDic) {
        // 更新消息状态
        long messageId = [statusDic[@"messageId"] longValue];
        if (messageId == 0) {
            return;
        }
        dispatch_async(self.updateEventQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                for (RCConversationModel *model in self.conversationListDataSource) {
                    if (model.lastestMessageId == messageId) {
                        RCConversationCellUpdateInfo *updateInfo = [[RCConversationCellUpdateInfo alloc] init];

                        RCConversation *conversation =
                            [[RCIMClient sharedRCIMClient] getConversation:model.conversationType
                                                                  targetId:model.targetId];
                        model.lastestMessage = conversation.lastestMessage;
                        model.sentStatus = conversation.sentStatus;
                        updateInfo.model = model;
                        updateInfo.updateType = RCConversationCell_MessageContent_Update;
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:RCKitConversationCellUpdateNotification
                                          object:updateInfo
                                        userInfo:nil];
                        break;
                    }
                }
            });
        });
    }
}

#pragma mark - traitCollection
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self fitDarkMode];
}

- (void)fitDarkMode {
    if (![RCIM sharedRCIM].enableDarkMode) {
        return;
    }
    if (@available(iOS 13.0, *)) {
        if ([self.emptyConversationView isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)self.emptyConversationView;
            if (imageView.image.rc_imageLocalPath && imageView.image.rc_imageLocalPath.length > 0 &&
                [imageView.image rc_needReloadImage]) {
                imageView.image = [UIImage rc_imageWithLocalPath:imageView.image.rc_imageLocalPath];
            }
        }
    }
}

- (void)conversationStatusChanged:(NSNotification *)notification {
    NSArray<RCConversationStatusInfo *> *conversationStatusInfos = notification.object;
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ws.conversationListDataSource.count <= 0) {
            return;
        }
        if (conversationStatusInfos.count == 1) {
            RCConversationStatusInfo *statusInfo = [conversationStatusInfos firstObject];
            if (statusInfo.conversationStatusType == RCConversationStatusType_Top) {
                [ws refreshConversationTableViewIfNeeded];
            }else {
                for (int i = 0; i < ws.conversationListDataSource.count; i++) {
                    RCConversationModel *conversationModel = ws.conversationListDataSource[i];
                    if ([conversationModel.targetId isEqualToString:statusInfo.targetId] &&
                        conversationModel.conversationType == statusInfo.conversationType) {
                        NSInteger refreshIndex = [self.conversationListDataSource indexOfObject:conversationModel];
                        conversationModel.blockStatus = statusInfo.conversationStatusvalue;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:refreshIndex inSection:0];
                        [ws.conversationListTableView reloadRowsAtIndexPaths:@[ indexPath ]
                                                            withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
        } else {
            [ws refreshConversationTableViewIfNeeded];
        }
    });
}

@end
