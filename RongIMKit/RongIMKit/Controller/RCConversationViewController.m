//
//  RCConversationViewController.m
//  RongIMKit
//
//  Created by xugang on 15/1/22.
//  Copyright (c) 2015年 RongCloud. All AVrights reserved.
//

#import "RCConversationViewController.h"
#import "RCAdminEvaluationView.h"
#import "RCCSAlertView.h"
#import "RCCSEvaluateView.h"
#import "RCCSLeaveMessageController.h"
#import "RCCSPullLeaveMessageCell.h"
#import "RCConversationCollectionViewHeader.h"
#import "RCCustomerServiceGroupListController.h"
#import "RCCustomerServiceMessageModel.h"
#import "RCExtensionService.h"
#import "RCFilePreviewViewController.h"
#import "RCBurnImageBrowseController.h"
#import "RCKitCommonDefine.h"
#import "RCOldMessageNotificationMessage.h"
#import "RCOldMessageNotificationMessageCell.h"
#import "RCPublicServiceImgTxtMsgCell.h"
#import "RCPublicServiceMultiImgTxtCell.h"
#import "RCRecallMessageImageView.h"
#import "RCRobotEvaluationView.h"
#import "RCSightMessageCell.h"
#import "RCHQVoiceMessageCell.h"
#import "RCSightSlideViewController.h"
#import "RCBurnSightViewController.h"
#import "RCSystemSoundPlayer.h"
#import "RCUserInfoCacheManager.h"
#import "RCVoicePlayer.h"
#import "RongIMKitExtensionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <SafariServices/SafariServices.h>
#import <objc/runtime.h>
#import "RCMessageSelectionUtility.h"
#import "RCConversationViewLayout.h"
#import "RCIMClient+Destructing.h"
#import "RCloudMediaManager.h"
#import "RCHQVoiceMsgDownloadManager.h"
#import "RCHQVoiceMsgDownloadInfo.h"
#import "RCGIFImage.h"
#import "RCGIFPreviewViewController.h"
#import "RCBurnGIFPreviewViewController.h"
#import "RCCombineMessagePreviewViewController.h"
#import "RCCombineMessageUtility.h"
#import "RCActionSheetView.h"
#import "RCSelectConversationViewController.h"
#import "RCForwardManager.h"
#import "RCCombineMessageCell.h"
#import "RCReeditMessageManager.h"
#import "RCReferencingView.h"
#import "RCReferenceMessageCell.h"
#define COLLECTION_VIEW_CELL_MAX_COUNT 3000
#define COLLECTION_VIEW_CELL_REMOVE_COUNT 200
#define UNREAD_MESSAGE_MAX_COUNT 99
#define COLLECTION_VIEW_REFRESH_CONTROL_HEIGHT 30
#define DefaultMessageBurnDuration 10
#define ImageMessageBurnDuration 30
#define BurnPushContent NSLocalizedStringFromTable(@"BurnAfterRead", @"RongCloudKit", nil)

extern NSString *const RCKitDispatchDownloadMediaNotification;

@interface RCMessageBaseCell ()
@property (nonatomic, assign) BOOL isConversationAppear;
@end

@interface RCMessageCell ()
- (void)messageDestructing;
@end

@interface RCSightMessage ()
+ (instancetype)messageWithAsset:(AVAsset *)asset thumbnail:(UIImage *)image duration:(NSUInteger)duration;
@end
;

@interface RCChatSessionInputBarControl ()
@property (nonatomic, assign) BOOL burnMessageMode;
- (void)beginBurnMsgMode;
- (void)endBurnMsgMode;
@end


@interface RCConversationViewController () <
    UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RCMessageCellDelegate,
    RCChatSessionInputBarControlDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate,
    UINavigationControllerDelegate, RCPublicServiceMessageCellDelegate, RCTypingStatusDelegate,
    RCAdminEvaluationViewDelegate, RCRobotEvaluationViewDelegate, RCCSAlertViewDelegate,
    RCChatSessionInputBarControlDataSource, RCMessagesMultiSelectedProtocol, RCReferencingViewDelegate>

@property (nonatomic, weak) RCConversationCollectionViewHeader *collectionViewHeader;
/*!
 会话页面的CollectionView Layout
 */
@property (nonatomic, strong) RCConversationViewLayout *customFlowLayout;
@property (nonatomic) KBottomBarStatus currentBottomBarStatus;
@property (nonatomic) BOOL isIndicatorLoading;
@property (nonatomic, strong) RCMessageModel *longPressSelectedModel;
@property (nonatomic, assign) BOOL isConversationAppear;
@property (nonatomic, assign) BOOL isTakeNewPhoto;
@property (nonatomic, assign) BOOL isNeedScrollToBottom;
@property (nonatomic, assign) BOOL isChatRoomHistoryMessageLoaded;

@property (nonatomic, strong) RCDiscussion *currentDiscussion;

@property (nonatomic, strong) UIImageView *unreadRightBottomIcon;
// 用于统计在当前页面时右下角未读数的显示
@property (nonatomic, strong) NSMutableArray *unreadNewMsgArr;

@property (nonatomic, assign) BOOL isClear;
@property (nonatomic) BOOL isIPad;
@property (nonatomic, strong) UIView *typingStatusView;
@property (nonatomic, strong) UILabel *typingStatusLabel;
@property (nonatomic, strong) dispatch_queue_t rcTypingMessageQueue;
@property (nonatomic, strong) NSMutableArray *typingMessageArray;
@property (nonatomic, copy) NSString *typingUserStr;
@property (nonatomic, copy) NSString *navigationTitle;
@property (nonatomic, strong) UITapGestureRecognizer *resetBottomTapGesture;

@property (nonatomic) BOOL loadHistoryMessageFromRemote;
@property (nonatomic, assign) long long recordTime;

@property (nonatomic, strong) RCCustomerServiceConfig *csConfig;
@property (nonatomic, strong) RCCSAlertView *csAlertView;
@property (nonatomic, strong) NSDate *csEnterDate;
@property (nonatomic) RCCustomerServiceStatus currentServiceStatus;
@property (nonatomic) BOOL humanEvaluated;

@property (nonatomic, strong) RCRecallMessageImageView *rcImageProressView;
@property (nonatomic, assign) BOOL hasReceiveNewMessage;
@property (nonatomic, strong) NSArray *unreadMentionedMessages;
@property (nonatomic, strong) NSOperationQueue *appendMessageQueue;
@property (nonatomic, strong) NSArray<RCExtensionMessageCellInfo *> *extensionMessageCellInfoList;
@property (nonatomic, strong) NSMutableDictionary *cellMsgDict;
//@property(nonatomic, strong) NSTimer *hideReceiptButtonTimer;//群回执定时消失timer
@property (nonatomic, strong) NSTimer *notReciveMessageAlertTimer; //长时间没有收到消息的计时器
@property (nonatomic, strong) NSTimer *notSendMessageAlertTimer;   //长时间没有发送消息的计时器
@property (nonatomic, assign) BOOL isContinuousPlaying;            //是否正在连续播放语音消息
@property (nonatomic, assign) BOOL isLoadingHistoryMessage;        //是否正在加载历史消息
@property (nonatomic, strong)
    RCMessage *firstUnreadMessage; //第一条未读消息,进入会话时存储起来，因为加载消息之后会改变所有消息的未读状态
@property (nonatomic, assign) long long lastReadReceiptTime; //需要发的阅读回执时间（毫秒）
@property (nonatomic, assign) BOOL isWaitSendReadReceipt;    //是否需要等待发送阅读回执
@property (nonatomic, assign) BOOL allMessagesAreLoaded; /// YES  表示所有消息都已加载完 NO 表示还有剩余消息
@property (nonatomic, assign) BOOL isTouchScrolled; /// 表示是否是触摸滚动

/*!
 是否开启客服超时提醒

 @discussion 默认值为NO。
 开启该提示功能之后，在客服会话页面长时间没有说话或者收到对方的消息，会插入一条提醒消息
 */
@property (nonatomic, assign) BOOL enableCustomerServiceOverTimeRemind;

/*!
 客服长时间没有收到消息超时提醒时长

 @discussion 默认值60秒。
 开启enableCustomerServiceOverTimeRemind之后，在客服会话页面，时长 customerServiceReciveMessageOverTimeRemindTimer
 没有收到对方的消息，会插入一条提醒消息
 */
@property (nonatomic, assign) int customerServiceReciveMessageOverTimeRemindTimer;

/*!
 客服长时间没有收到消息超时提醒内容

 开启enableCustomerServiceOverTimeRemind之后，在客服会话页面，时长 customerServiceSendMessageOverTimeRemindTimer
 没有说话，会插入一条提醒消息
 */
@property (nonatomic, copy) NSString *customerServiceReciveMessageOverTimeRemindContent;

/*!
 客服长时间没有发送消息超时提醒时长

 @discussion 默认值60秒。
 开启enableCustomerServiceOverTimeRemind之后，在客服会话页面，时长 customerServiceSendMessageOverTimeRemindTimer
 没有说话，会插入一条提醒消息
 */
@property (nonatomic, assign) int customerServiceSendMessageOverTimeRemindTimer;

/*!
 客服长时间没有发送消息超时提醒内容

 开启enableCustomerServiceOverTimeRemind之后，在客服会话页面，时长 customerServiceSendMessageOverTimeRemindTimer
 没有说话，会插入一条提醒消息
 */
@property (nonatomic, copy) NSString *customerServiceSendMessageOverTimeRemindContent;

/*!
 客服结束会话提示信息
 */
@property (nonatomic, copy) NSString *customerServiceQuitMsg;

@property (nonatomic, strong) RCCSEvaluateView *evaluateView;

/*!
 显示查看未读的消息 id
 */
@property (nonatomic, assign) long long showUnreadViewMessageId;

/*!
 开启已读回执功能的消息类型 objectName list, 默认为 @[@"RC:TxtMsg"],只支持文本消息

 @discussion 这些会话类型的消息在会话页面显示了之后会发送已读回执。目前仅支持单聊、群聊和讨论组。
 */
@property (nonatomic, copy) NSArray<NSString *> *enabledReadReceiptMessageTypeList;

@property (nonatomic, strong) RCMessageModel *currentSelectedModel;

@property (nonatomic, strong) NSArray<UIBarButtonItem *> *leftBarButtonItems;

@property (nonatomic, strong) NSArray<UIBarButtonItem *> *rightBarButtonItems;

@end

static NSString *const rcUnknownMessageCellIndentifier = @"rcUnknownMessageCellIndentifier";
static BOOL msgRoamingServiceAvailable = YES;
bool isCanSendTypingMessage = YES;

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation RCConversationViewController

- (id)initWithConversationType:(RCConversationType)conversationType targetId:(NSString *)targetId {
    self = [super init];
    if (self) {
        self.conversationType = conversationType;
        self.targetId = targetId;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self rcinit];
    }
    return self;
}

- (void)rcinit {
    self.isIndicatorLoading = NO;
    _isConversationAppear = NO;
    /* 先假设所有消息都已加载完，Header 的 Size.height 为 0，
            如果服务返回还有消息，修改 Header 的 Size.height 为 30*/
    self.allMessagesAreLoaded = YES;
    self.conversationDataRepository = [[NSMutableArray alloc] init];
    self.conversationMessageCollectionView = nil;
    self.targetId = nil;
    self.customerServiceReciveMessageOverTimeRemindTimer = 20;
    self.customerServiceSendMessageOverTimeRemindTimer = 10;
    // self.enableCustomerServiceOverTimeRemind = YES;
    _userName = nil; //废弃
    self.currentBottomBarStatus = KBottomBarDefaultStatus;
    [self registerNotification];

    self.displayUserNameInCell = YES;
    self.defaultInputType = RCChatSessionInputBarInputText;
    self.defaultHistoryMessageCountOfChatRoom = 10;
    if ([RCKitUtility currentDeviceIsIPad]) {
        self.isIPad = YES;
    }
    self.enableContinuousReadUnreadVoice = YES;
    self.isClear = NO;
    self.typingMessageArray = [[NSMutableArray alloc] init];
    self.loadHistoryMessageFromRemote = NO;
    self.appendMessageQueue = [NSOperationQueue new];
    self.appendMessageQueue.maxConcurrentOperationCount = 1;
    self.appendMessageQueue.name = @"cn.rongcloud.appendMessageQueue";
    self.cellMsgDict = [[NSMutableDictionary alloc] init];
    self.csEvaInterval = 60;
    self.isContinuousPlaying = NO;
    self.unreadNewMsgArr = [NSMutableArray new];
    self.enabledReadReceiptMessageTypeList = @[ [RCTextMessage getObjectName] ];
    [[RCMessageSelectionUtility sharedManager] setMultiSelect:NO];
}

- (BOOL)isLoadingHistoryMessage {
    if (self.conversationDataRepository.count == 0) {
        return NO;
    }
    return _isLoadingHistoryMessage;
}

- (void)setDefaultHistoryMessageCountOfChatRoom:(int)defaultHistoryMessageCountOfChatRoom {
    if (RC_IOS_SYSTEM_VERSION_LESS_THAN(@"8.0") && defaultHistoryMessageCountOfChatRoom > 30) {
        defaultHistoryMessageCountOfChatRoom = 30;
    }
    _defaultHistoryMessageCountOfChatRoom = defaultHistoryMessageCountOfChatRoom;
}

- (void)registerNotification {

    //注册接收消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:RCKitDispatchMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSendingMessageNotification:)
                                                 name:@"RCKitSendingMessageNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMessageHasReadNotification:)
                                                 name:RCLibDispatchReadReceiptNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppResume)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillResignActive)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveRecallMessageNotification:)
                                                 name:RCKitDispatchRecallMessageNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveMessageReadReceiptResponse:)
                                                 name:RCKitDispatchMessageReceiptResponseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveMessageReadReceiptRequest:)
                                                 name:RCKitDispatchMessageReceiptRequestNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayingVoiceMessage)
                                                 name:UIWindowDidResignKeyNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onConnectionStatusChangedNotification:)
                                                 name:RCKitDispatchConnectionStatusChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageDestructing:)
                                                 name:RCKitMessageDestructingNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDownloadStatus:)
                                                 name:RCHQDownloadStatusChangeNotify
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadMediaNotification:)
                                                 name:RCKitDispatchDownloadMediaNotification
                                               object:nil];
}

- (void)onConnectionStatusChangedNotification:(NSNotification *)status {
    if (ConnectionStatus_Connected == [status.object integerValue]) {
        [self syncReadStatus];
        [self sendReadReceipt];
    }
}

- (void)registerClass:(Class)cellClass forMessageClass:(Class)messageClass {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:[messageClass getObjectName]];
    [self.cellMsgDict setObject:cellClass forKey:[messageClass getObjectName]];
}

- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.rcImageProressView = [[RCRecallMessageImageView alloc] initWithFrame:CGRectMake(0, 0, 135, 135)];
    //-----
    // Do any additional setup after loading the view.
    // self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeTop;
    if (RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // 左滑返回 和 按住事件冲突
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self initializedSubViews];

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_10_3
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-[self getIPhonexExtraBottomHeight], 0, 0, 0);
    }
#endif
    [[RCSystemSoundPlayer defaultPlayer] setIgnoreConversationType:self.conversationType targetId:self.targetId];
    
    RCConversation *conversation =
        [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];

    if (!(self.conversationType == ConversationType_CHATROOM)) {
        //非聊天室加载历史数据
        [self loadLatestHistoryMessage];
        self.unReadMessage = conversation.unreadMessageCount;
        ;
        if (self.unReadMessage) {
            self.firstUnreadMessage =
                [[RCIMClient sharedRCIMClient] getFirstUnreadMessage:self.conversationType targetId:self.targetId];
        }
    } else {
        //聊天室从服务器拉取消息，设置初始状态为为加载完成
        self.isChatRoomHistoryMessageLoaded = NO;
    }
    if ([RCIM sharedRCIM].enableMessageMentioned &&
        (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_DISCUSSION)) {
        self.chatSessionInputBarControl.isMentionedEnabled = YES;
        if (conversation.hasUnreadMentioned) {
            _unreadMentionedMessages =
                [[RCIMClient sharedRCIMClient] getUnreadMentionedMessages:self.conversationType targetId:self.targetId];
        }
    }

    __weak RCConversationViewController *weakSelf = self;
    if (ConversationType_CHATROOM == self.conversationType) {
        [[RCIMClient sharedRCIMClient] joinChatRoom:self.targetId
            messageCount:self.defaultHistoryMessageCountOfChatRoom
            success:^{
            }
            error:^(RCErrorCode status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == KICKED_FROM_CHATROOM) {
                        [weakSelf alertErrorAndLeft:NSLocalizedStringFromTable(@"JoinChatRoomRejected", @"RongCloudKit",
                                                                               nil)];
                    } else {
                        [weakSelf
                            alertErrorAndLeft:NSLocalizedStringFromTable(@"JoinChatRoomFailed", @"RongCloudKit", nil)];
                    }
                });
            }];
    }
    if (ConversationType_CUSTOMERSERVICE == self.conversationType) {
        [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                   style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];

        if (!self.csInfo) {
            self.csInfo = [RCCustomerServiceInfo new];
            self.csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
            self.csInfo.nickName = [RCIMClient sharedRCIMClient].currentUserInfo.name;
            self.csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
        }

        [[RCIMClient sharedRCIMClient] startCustomerService:self.targetId
            info:self.csInfo
            onSuccess:^(RCCustomerServiceConfig *config) {
                weakSelf.csConfig = config;
                weakSelf.csEnterDate = [[NSDate alloc] init];
                [weakSelf startNotSendMessageAlertTimer];
                [weakSelf startNotReciveMessageAlertTimer];
                if (config.disableLocation) {
                    [weakSelf.chatSessionInputBarControl.pluginBoardView
                        removeItemWithTag:PLUGIN_BOARD_ITEM_LOCATION_TAG];
                }
                if (config.evaEntryPoint == RCCSEvaExtention) {
                    [weakSelf.chatSessionInputBarControl.pluginBoardView
                        insertItemWithImage:[RCKitUtility imageNamed:@"Comment" ofBundle:@"RongCloud.bundle"]
                                      title:@"评价"
                                        tag:PLUGIN_BOARD_ITEM_EVA_TAG];
                }
                [weakSelf announceViewWillShow];
            }
            onError:^(int errorCode, NSString *errMsg) {
                [weakSelf customerServiceWarning:errMsg.length ? errMsg : @"连接客服失败!"
                                quitAfterWarning:YES
                                    needEvaluate:NO
                                     needSuspend:NO];
            }
            onModeType:^(RCCSModeType mode) {
                weakSelf.currentServiceStatus = RCCustomerService_NoService;
                [weakSelf onCustomerServiceModeChanged:mode];
                switch (mode) {
                case RC_CS_RobotOnly:
                    [weakSelf.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                                   style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];
                    weakSelf.currentServiceStatus = RCCustomerService_RobotService;
                    break;
                case RC_CS_HumanOnly: {
                    weakSelf.currentServiceStatus = RCCustomerService_HumanService;
                    RCChatSessionInputBarControlStyle style = RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION;
                    [weakSelf.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                                   style:style];
                } break;
                case RC_CS_RobotFirst:
                    [weakSelf.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlCSRobotType
                                                                   style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];
                    weakSelf.currentServiceStatus = RCCustomerService_RobotService;
                    break;
                case RC_CS_NoService: {
                    RCChatSessionInputBarControlStyle style = RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION;
                    [weakSelf.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                                   style:style];
                    weakSelf.currentServiceStatus = RCCustomerService_NoService;
                } break;
                default:
                    break;
                }
                [weakSelf resetBottomBarStatus];
            }
            onPullEvaluation:^(NSString *dialogId) {
                //          if ([weakSelf.csEnterDate timeIntervalSinceNow] < -60 && !weakSelf.humanEvaluated &&
                //          weakSelf.csConfig.evaEntryPoint == RCCSEvaLeave) {
                //              weakSelf.humanEvaluated = YES;
                [weakSelf commentCustomerServiceWithStatus:weakSelf.currentServiceStatus
                                                 commentId:dialogId
                                          quitAfterComment:NO];
                //          }
                //        [weakSelf showEvaView];
            }
            onSelectGroup:^(NSArray<RCCustomerServiceGroupItem *> *groupList) {
                [weakSelf onSelectCustomerServiceGroup:groupList
                                                result:^(NSString *groupId) {
                                                    [[RCIMClient sharedRCIMClient]
                                                        selectCustomerServiceGroup:weakSelf.targetId
                                                                       withGroupId:groupId];
                                                }];
            }
            onQuit:^(NSString *quitMsg) {
                weakSelf.customerServiceQuitMsg = quitMsg;
                if (weakSelf.csConfig.evaEntryPoint == RCCSEvaCSEnd &&
                    weakSelf.currentServiceStatus == RCCustomerService_HumanService) {
                    [weakSelf commentCustomerServiceWithStatus:weakSelf.currentServiceStatus
                                                     commentId:nil
                                              quitAfterComment:NO];
                } else {
                    [weakSelf showCustomerServiceEndAlert];
                }
            }];
    }

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[RCKitUtility imageNamed:@"rc_setting" ofBundle:@"RongCloud.bundle"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(rightBarButtonItemClicked:)];

    if (self.conversationType == ConversationType_DISCUSSION) {
        __weak typeof(self) weakSelf = self;
        [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
            success:^(RCDiscussion *discussion) {
                weakSelf.currentDiscussion = discussion;
            }
            error:^(RCErrorCode status){

            }];
    }
    if (ConversationType_APPSERVICE == self.conversationType ||
        ConversationType_PUBLICSERVICE == self.conversationType) {
        if ([[RCIM sharedRCIM].publicServiceInfoDataSource respondsToSelector:@selector(publicServiceProfile:)]) {
            RCPublicServiceProfile *serviceProfile =
                [[RCIM sharedRCIM].publicServiceInfoDataSource publicServiceProfile:self.targetId];
            __weak typeof(self) weakSelf = self;
            void (^configureInputBar)(RCPublicServiceProfile *profile) = ^(RCPublicServiceProfile *profile) {
                if (profile.menu.menuItems) {
                    [weakSelf.chatSessionInputBarControl
                        setInputBarType:RCChatSessionInputBarControlPubType
                                  style:RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION];
                    weakSelf.chatSessionInputBarControl.publicServiceMenu = profile.menu;
                }
                if (profile.disableInput && profile.disableMenu) {
                    weakSelf.chatSessionInputBarControl.hidden = YES;
                    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
                    CGRect originFrame = weakSelf.conversationMessageCollectionView.frame;
                    originFrame.size.height =
                        screenHeight - originFrame.origin.y - [weakSelf getIPhonexExtraBottomHeight];
                    weakSelf.conversationMessageCollectionView.frame = originFrame;
                }
            };
            if (serviceProfile) {
                configureInputBar(serviceProfile);
            } else {
                [[RCIM sharedRCIM]
                        .publicServiceInfoDataSource getPublicServiceProfile:self.targetId
                                                                  completion:^(RCPublicServiceProfile *profile) {
                                                                      configureInputBar(serviceProfile);
                                                                  }];
            }

        } else {
            RCPublicServiceProfile *profile =
                [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                       publicServiceId:self.targetId];
            if (profile.menu.menuItems) {
                [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlPubType
                                                           style:RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION];
                self.chatSessionInputBarControl.publicServiceMenu = profile.menu;
            }
        }

        RCPublicServiceCommandMessage *entryCommond =
            [RCPublicServiceCommandMessage messageWithCommand:@"entry" data:nil];
        [self sendMessage:entryCommond pushContent:nil];
    }

    NSString *draft = conversation.draft;
    self.chatSessionInputBarControl.draft = draft;

    [self registerSectionHeaderView];
    if (![RCIM sharedRCIM].enableBurnMessage) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_BURN_TAG];
    }
    [self.chatSessionInputBarControl.pluginBoardView removeItemWithTag:PLUGIN_BOARD_ITEM_TRANSFER_TAG];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.messageSelectionToolbar.frame =
        CGRectMake(0, self.view.bounds.size.height - RC_ChatSessionInputBar_Height - [self getIPhonexExtraBottomHeight],
                   self.view.bounds.size.width, RC_ChatSessionInputBar_Height);
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutSubview:size];
        }];
}

- (void)layoutSubview:(CGSize)size {
    if (![RCKitUtility currentDeviceIsIPad]) {
        return;
    }
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    frame.size.height = frame.size.height - RC_ChatSessionInputBar_Height;
    self.conversationMessageCollectionView.frame = frame;
    for (RCMessageModel *model in self.conversationDataRepository) {
        model.cellSize = CGSizeZero;
    }
    [self.conversationMessageCollectionView reloadData];
    self.collectionViewHeader.frame = CGRectMake(0, -40, size.width, 40);

    CGRect controlFrame = self.chatSessionInputBarControl.frame;
    controlFrame.size.width = self.view.frame.size.width;
    controlFrame.origin.y =
        self.conversationMessageCollectionView.frame.size.height - self.chatSessionInputBarControl.frame.size.height;
    self.chatSessionInputBarControl.frame = controlFrame;

    CGRect inputContainerViewFrame = self.chatSessionInputBarControl.inputContainerView.frame;
    inputContainerViewFrame.size.width = self.view.frame.size.width;

    CGRect inputTextViewFrame = self.chatSessionInputBarControl.inputTextView.frame;
    inputTextViewFrame.size.width = self.chatSessionInputBarControl.frame.size.width - 132;
    if (self.chatSessionInputBarControl.menuContainerView) {
        inputContainerViewFrame.size.width = inputContainerViewFrame.size.width - 42; // SwitchButtonWidth
        inputTextViewFrame.size.width = inputTextViewFrame.size.width - 41;

        // 如果包含公众号菜单需要正常调整视图大小
        self.chatSessionInputBarControl.menuContainerView.frame = inputContainerViewFrame;
        self.chatSessionInputBarControl.publicServiceMenu = self.chatSessionInputBarControl.publicServiceMenu;
    }
    self.chatSessionInputBarControl.inputContainerView.frame = inputContainerViewFrame;
    self.chatSessionInputBarControl.inputTextView.frame = inputTextViewFrame;
    [self.chatSessionInputBarControl.pluginBoardView layoutIfNeeded];
    [self.chatSessionInputBarControl containerViewSizeChangedNoAnnimation];
}

- (void)onSelectCustomerServiceGroup:(NSArray *)groupList result:(void (^)(NSString *groupId))resultBlock {
    NSMutableArray *__groupList = [NSMutableArray array];
    for (RCCustomerServiceGroupItem *item in groupList) {
        if (item.online) {
            [__groupList addObject:item];
        }
    }
    if (__groupList && __groupList.count > 0) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            RCCustomerServiceGroupListController *customerGroupListController =
                [[RCCustomerServiceGroupListController alloc] init];
            UINavigationController *rootVC =
                [[UINavigationController alloc] initWithRootViewController:customerGroupListController];
            customerGroupListController.groupList = __groupList;
            [customerGroupListController setSelectGroupBlock:^(NSString *groupId) {
                if (resultBlock) {
                    resultBlock(groupId);
                }
            }];
            rootVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [weakSelf presentViewController:rootVC animated:YES completion:nil];
        });
    } else {
        if (resultBlock) {
            resultBlock(nil);
        }
    }
}

- (void)alertErrorAndLeft:(NSString *)errorInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:errorInfo
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES
                                                completion:^{
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
        });
    });
}

- (void)rightBarButtonItemClicked:(id)sender {
    if (ConversationType_APPSERVICE == self.conversationType ||
        ConversationType_PUBLICSERVICE == self.conversationType) {
        RCPublicServiceProfile *serviceProfile =
            [[RCIMClient sharedRCIMClient] getPublicServiceProfile:(RCPublicServiceType)self.conversationType
                                                   publicServiceId:self.targetId];

        RCPublicServiceProfileViewController *infoVC = [[RCPublicServiceProfileViewController alloc] init];
        infoVC.serviceProfile = serviceProfile;
        infoVC.fromConversation = YES;
        [self.navigationController pushViewController:infoVC animated:YES];
    } else {
        RCSettingViewController *settingVC = [[RCSettingViewController alloc] init];
        settingVC.conversationType = self.conversationType;
        settingVC.targetId = self.targetId;
        __weak typeof(self) weakSelf = self;
        settingVC.clearHistoryCompletion = ^(BOOL isSuccess) {
            if (isSuccess) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.conversationDataRepository removeAllObjects];
                    [weakSelf.conversationMessageCollectionView reloadData];
                });
            }
        };
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUnreadMsgCountLabel];
    if (self.unReadMessage > 0) {
        [self syncReadStatus];
        [self sendReadReceipt];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:self.conversationType targetId:self.targetId];
            /// 清除完未读数需要通知更新UI
            [self notifyUpdateUnreadMessageCount];
        });
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContinuousPlayNotification:)
                                                 name:@"RCContinuousPlayNotification"
                                               object:nil];
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    _resetBottomTapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap4ResetDefaultBottomBarStatus:)];
    [_resetBottomTapGesture setDelegate:self];
    _resetBottomTapGesture.cancelsTouchesInView = NO;
    _resetBottomTapGesture.delaysTouchesEnded = NO;
    [self.conversationMessageCollectionView addGestureRecognizer:_resetBottomTapGesture];

    [self.chatSessionInputBarControl containerViewWillAppear];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentViewFrameChange:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];

    [[RCSystemSoundPlayer defaultPlayer] setIgnoreConversationType:self.conversationType targetId:self.targetId];
    // NSLog(@"%ld",(unsigned long)self.conversationDataRepository.count);
    if (self.conversationDataRepository.count == 0 && _unReadButton != nil) {
        [_unReadButton removeFromSuperview];
        _unReadMessage = 0;
    }

    if (_unReadMessage > 10 && self.enableUnreadMessageIcon == YES && !self.unReadButton.selected) {
        [self setupUnReadMessageView];
    }

    if (_unreadMentionedMessages) {
        for (int j = 0; j < _unreadMentionedMessages.count; j++) {
            RCMessage *mentionedMsg = [self.unreadMentionedMessages objectAtIndex:j];
            BOOL isFindMentionedMessage = NO;
            for (int i = 0; i < self.conversationDataRepository.count; i++) {
                RCMessage *rcMsg = [self.conversationDataRepository objectAtIndex:i];
                RCMessageModel *model = [RCMessageModel modelWithMessage:rcMsg];
                if (model.messageId == mentionedMsg.messageId) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
                                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                                           animated:NO];
                    isFindMentionedMessage = YES;
                    break;
                }
            }
            if (isFindMentionedMessage) {
                break;
            }
        }
    }

    if (self.locatedMessageSentTime != 0) {
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = self.conversationDataRepository[i];
            if (model.sentTime == self.locatedMessageSentTime) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.conversationMessageCollectionView scrollToItemAtIndexPath:indexPath
                                                               atScrollPosition:UICollectionViewScrollPositionTop
                                                                       animated:NO];
                self.locatedMessageSentTime = 0;
                break;
            }
        }
    }
    [[RongIMKitExtensionManager sharedManager] extensionViewWillAppear:self.conversationType
                                                              targetId:self.targetId
                                                         extensionView:self.extensionView];
}

- (void)setLocatedMessageSentTime:(long long)locatedMessageSentTime {
    _locatedMessageSentTime = locatedMessageSentTime;
}

- (void)currentViewFrameChange:(NSNotification *)notification {
    [self.chatSessionInputBarControl containerViewSizeChanged];
}

- (void)setupUnReadMessageView {
    if (_unReadButton != nil) {
        [_unReadButton removeFromSuperview];
    }
    _unReadButton = [UIButton new];
    CGFloat extraHeight = 0;
    if ([self getIPhonexExtraBottomHeight] > 0) {
        extraHeight = 24; // iphonex 的导航由20变成了44，需要额外加24
    }
    _unReadButton.frame = CGRectMake(0, extraHeight + 76, 0, 42);
    [_unReadButton setBackgroundImage:[RCKitUtility imageNamed:@"up" ofBundle:@"RongCloud.bundle"]
                             forState:UIControlStateNormal];
    self.unReadMessageLabel =
        [[UILabel alloc] initWithFrame:CGRectMake(17 + 9 + 11, 0, 0, self.unReadButton.frame.size.height)];
    NSString *newMessageCount = [NSString stringWithFormat:@"%ld", (long)_unReadMessage];
    if (_unReadMessage > UNREAD_MESSAGE_MAX_COUNT) {
        newMessageCount = [NSString stringWithFormat:@"%d+", UNREAD_MESSAGE_MAX_COUNT];
    }
    NSString *stringUnread = [NSString
        stringWithFormat:NSLocalizedStringFromTable(@"Right_unReadMessage", @"RongCloudKit", nil), newMessageCount];
    self.unReadMessageLabel.text = stringUnread;
    self.unReadMessageLabel.font = [UIFont systemFontOfSize:14.0];
    self.unReadMessageLabel.textColor = [UIColor colorWithRed:1 / 255.0f green:149 / 255.0f blue:255 / 255.0f alpha:1];
    self.unReadMessageLabel.textAlignment = NSTextAlignmentCenter;
    [_unReadButton addSubview:self.unReadMessageLabel];
    [_unReadButton addTarget:self action:@selector(didTipUnReadButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_unReadButton];
    [_unReadButton bringSubviewToFront:self.conversationMessageCollectionView];
    [self labelAdaptive:self.unReadMessageLabel];
}

- (void)labelAdaptive:(UILabel *)sender {
    CGRect rect = [sender.text boundingRectWithSize:CGSizeMake(2000, sender.frame.size.height)
                                            options:(NSStringDrawingUsesLineFragmentOrigin)
                                         attributes:@{
                                             NSFontAttributeName : [UIFont systemFontOfSize:14.0f]
                                         }
                                            context:nil];
    CGRect temp = sender.frame;
    temp.size.width = rect.size.width;
    sender.frame = temp;
    CGRect temBut = self.unReadButton.frame;
    temBut.size.width = temp.size.width + 9 + 17 + 10 + 11;
    temBut.origin.x = self.view.frame.size.width - temBut.size.width;
    self.unReadButton.frame = temBut;
    UIImage *image = [RCKitUtility imageNamed:@"up" ofBundle:@"RongCloud.bundle"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.width * 0.2, image.size.width * 0.8,
                                                                image.size.width * 0.2, image.size.width * 0.2)
                                  resizingMode:UIImageResizingModeStretch];
    [self.unReadButton setBackgroundImage:image forState:UIControlStateNormal];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(17.5, (42 - 8.5) / 2, 9, 8.5)];
    imageView.image = [RCKitUtility imageNamed:@"arrow" ofBundle:@"RongCloud.bundle"];
    [self.unReadButton addSubview:imageView];
}

- (void)didTipUnReadButton:(UIButton *)sender {
    [self.unReadButton removeFromSuperview];
    //表明已点击过UnReadButton，加载了新消息，用来判断已加载了多少新消息
    self.unReadButton.selected = YES;
    self.isLoadingHistoryMessage = YES;
    if (self.firstUnreadMessage) {
        [self.conversationDataRepository removeAllObjects]; //移除所有的已经加载的消息，页面只剩下从第一条未读开始的消息
        NSArray *__messageArray = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType
                                                                           targetId:_targetId
                                                                         objectName:nil
                                                                      baseMessageId:self.firstUnreadMessage.messageId
                                                                          isForward:NO
                                                                              count:20];
        NSArray *tempArray = [[__messageArray reverseObjectEnumerator] allObjects];
        NSMutableArray *oldMessageArray = [NSMutableArray arrayWithArray:tempArray];
        [oldMessageArray addObject:self.firstUnreadMessage];
        [self sendReadReceiptResponseForMessages:oldMessageArray.copy];
        for (int i = 0; i < oldMessageArray.count; i++) {
            RCMessage *rcMsg = [oldMessageArray objectAtIndex:i];
            RCMessageModel *model = [RCMessageModel modelWithMessage:rcMsg];
            [self pushOldMessageModel:model];
        }
        if (self.unReadButton != nil && self.enableUnreadMessageIcon) {
            //如果会话里都是未注册自定义消息，这时获取到的数据源是 0，点击右上角未读按钮会崩溃
            if (self.conversationDataRepository.count > 0) {
                RCOldMessageNotificationMessage *oldMessageTip = [[RCOldMessageNotificationMessage alloc] init];
                RCMessage *oldMessage = [[RCMessage alloc] initWithType:self.conversationType
                                                               targetId:self.targetId
                                                              direction:MessageDirection_SEND
                                                              messageId:-1
                                                                content:oldMessageTip];
                RCMessageModel *model = [RCMessageModel modelWithMessage:oldMessage];
                RCMessageModel *lastMessageModel = [self.conversationDataRepository objectAtIndex:0];
                model.messageId = lastMessageModel.messageId;
                [self.conversationDataRepository insertObject:model atIndex:0];
            }
            self.unReadButton = nil;
            self.unReadMessage = 0;
        }

        [self figureOutAllConversationDataRepository];
        [self.conversationMessageCollectionView reloadData];
        if (self.conversationDataRepository.count > 0) {
            [self.conversationMessageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                           atScrollPosition:UICollectionViewScrollPositionTop
                                                                   animated:YES];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DebugLog(@"%s======%@", __func__, self);
    DebugLog(@"conversationMessageCollectionView=>%@", self.conversationMessageCollectionView);
    _isConversationAppear = YES;

    [self.chatSessionInputBarControl containerViewDidAppear];
    self.navigationTitle = self.navigationItem.title;
    [[RCIMClient sharedRCIMClient] setRCTypingStatusDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_hasReceiveNewMessage) {
        [self syncReadStatus];
    }
    self.unreadMentionedMessages = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RCContinuousPlayNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillChangeStatusBarFrameNotification
                                                  object:nil];
    [self.conversationMessageCollectionView removeGestureRecognizer:_resetBottomTapGesture];
    [[RCSystemSoundPlayer defaultPlayer] resetIgnoreConversation];
    [self stopPlayingVoiceMessage];
    _isConversationAppear = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:self.conversationType targetId:self.targetId];
    });
    [self saveDraftIfNeed];

    [self.chatSessionInputBarControl cancelVoiceRecord];
    [[RCIMClient sharedRCIMClient] setRCTypingStatusDelegate:nil];
    self.navigationItem.title = self.navigationTitle;
    [self.chatSessionInputBarControl containerViewWillDisappear];
    [[RongIMKitExtensionManager sharedManager] extensionViewWillDisappear:self.conversationType targetId:self.targetId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!self.navigationController || ![self.navigationController.viewControllers containsObject:self]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.appendMessageQueue cancelAllOperations];
    }
}

- (void)dealloc {
    [self quitConversationViewAndClear];
    [[RCReeditMessageManager defaultManager] resetAndInvalidateTimer];
    DebugLog(@"%s======%@", __func__, self);
}

- (void)leftBarButtonItemPressed:(id)sender {
    [self quitConversationViewAndClear];
    if (self.navigationController && [self.navigationController.viewControllers.lastObject isEqual:self]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 清理环境（退出讨论组、移除监听等）
- (void)quitConversationViewAndClear {
    if (!self.isClear) {

        [[RongIMKitExtensionManager sharedManager] containerViewWillDestroy:self.conversationType
                                                                   targetId:self.targetId];

        if (self.conversationType == ConversationType_CHATROOM) {
            [[RCIMClient sharedRCIMClient] quitChatRoom:self.targetId
                success:^{

                }
                error:^(RCErrorCode status){

                }];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.isClear = YES;

        [self stopNotReciveMessageAlertTimer];
        [self stopNotSendMessageAlertTimer];
    }
}

- (void)initializedSubViews {
    // init collection view
    if (nil == self.conversationMessageCollectionView) {

        self.customFlowLayout = [[RCConversationViewLayout alloc] init];

        self.view.backgroundColor = [RCKitUtility
            generateDynamicColor:[UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1]
                       darkColor:HEXCOLOR(0x000000)];
        CGRect _conversationViewFrame = self.view.bounds;

        CGFloat _conversationViewFrameY = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame) +
                                          CGRectGetMaxY(self.navigationController.navigationBar.bounds);

        if (RC_IOS_SYSTEM_VERSION_LESS_THAN(@"7.0")) {

            _conversationViewFrame.origin.y = 0;
        } else {
            _conversationViewFrame.origin.y = _conversationViewFrameY;
        }

        _conversationViewFrame.size.height =
            self.view.bounds.size.height - RC_ChatSessionInputBar_Height - _conversationViewFrameY;

        self.conversationMessageCollectionView =
            [[UICollectionView alloc] initWithFrame:_conversationViewFrame collectionViewLayout:self.customFlowLayout];
        [self.conversationMessageCollectionView
            setBackgroundColor:[RCKitUtility generateDynamicColor:RGBCOLOR(235, 235, 235)
                                                        darkColor:HEXCOLOR(0x000000)]];
        self.conversationMessageCollectionView.showsHorizontalScrollIndicator = NO;
        self.conversationMessageCollectionView.alwaysBounceVertical = YES;

        [self registerClass:[RCTextMessageCell class] forMessageClass:[RCTextMessage class]];
        [self registerClass:[RCImageMessageCell class] forMessageClass:[RCImageMessage class]];
        [self registerClass:[RCGIFMessageCell class] forMessageClass:[RCGIFMessage class]];
        [self registerClass:[RCCombineMessageCell class] forMessageClass:[RCCombineMessage class]];
        [self registerClass:[RCVoiceMessageCell class] forMessageClass:[RCVoiceMessage class]];
        [self registerClass:[RCHQVoiceMessageCell class] forMessageClass:[RCHQVoiceMessage class]];
        [self registerClass:[RCRichContentMessageCell class] forMessageClass:[RCRichContentMessage class]];
        [self registerClass:[RCLocationMessageCell class] forMessageClass:[RCLocationMessage class]];

        [self registerClass:[RCTipMessageCell class] forMessageClass:[RCInformationNotificationMessage class]];
        [self registerClass:[RCTipMessageCell class] forMessageClass:[RCDiscussionNotificationMessage class]];
        [self registerClass:[RCTipMessageCell class] forMessageClass:[RCGroupNotificationMessage class]];
        [self registerClass:[RCTipMessageCell class] forMessageClass:[RCRecallNotificationMessage class]];
        [self registerClass:[RCCSPullLeaveMessageCell class] forMessageClass:[RCCSPullLeaveMessage class]];

        [self registerClass:[RCPublicServiceMultiImgTxtCell class]
            forMessageClass:[RCPublicServiceMultiRichContentMessage class]];
        [self registerClass:[RCPublicServiceImgTxtMsgCell class]
            forMessageClass:[RCPublicServiceRichContentMessage class]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self registerClass:[RCUnknownMessageCell class] forCellWithReuseIdentifier:rcUnknownMessageCellIndentifier];
#pragma clang diagnostic pop
        [self registerClass:[RCOldMessageNotificationMessageCell class]
            forMessageClass:[RCOldMessageNotificationMessage class]];
        [self registerClass:[RCFileMessageCell class] forMessageClass:[RCFileMessage class]];
        if (NSClassFromString(@"RCSightCapturer")) {
            [self registerClass:[RCSightMessageCell class] forMessageClass:[RCSightMessage class]];
        }

        [self registerClass:[RCReferenceMessageCell class] forMessageClass:[RCReferenceMessage class]];
        self.extensionMessageCellInfoList =
            [[RongIMKitExtensionManager sharedManager] getMessageCellInfoList:self.conversationType
                                                                     targetId:self.targetId];
        for (RCExtensionMessageCellInfo *cellInfo in self.extensionMessageCellInfoList) {
            [self registerClass:cellInfo.messageCellClass forMessageClass:cellInfo.messageContentClass];
        }

        self.conversationMessageCollectionView.dataSource = self;
        self.conversationMessageCollectionView.delegate = self;
        [RCMessageSelectionUtility sharedManager].delegate = self;
        [self.view addSubview:self.conversationMessageCollectionView];
    }
}

- (UIImageView *)unreadRightBottomIcon {
    if (!_unreadRightBottomIcon) {
        UIImage *msgCountIcon = [RCKitUtility imageNamed:@"bubble" ofBundle:@"RongCloud.bundle"];
        _unreadRightBottomIcon = [[UIImageView alloc]
            initWithFrame:CGRectMake(self.view.frame.size.width - 5.5 - 35,
                                     self.chatSessionInputBarControl.frame.origin.y - 12 - 35, 35, 35)];
        _unreadRightBottomIcon.userInteractionEnabled = YES;
        _unreadRightBottomIcon.image = msgCountIcon;
        //        _unreadRightBottomIcon.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabRightBottomMsgCountIcon:)];
        [_unreadRightBottomIcon addGestureRecognizer:tap];
        _unreadRightBottomIcon.hidden = YES;
        [self.view addSubview:_unreadRightBottomIcon];
    }
    return _unreadRightBottomIcon;
}

- (UILabel *)unReadNewMessageLabel {
    if (!_unReadNewMessageLabel) {
        _unReadNewMessageLabel = [[UILabel alloc] initWithFrame:_unreadRightBottomIcon.bounds];
        _unReadNewMessageLabel.backgroundColor = [UIColor clearColor];
        _unReadNewMessageLabel.font = [UIFont systemFontOfSize:12.0f];
        _unReadNewMessageLabel.textAlignment = NSTextAlignmentCenter;
        _unReadNewMessageLabel.textColor = [UIColor whiteColor];
        _unReadNewMessageLabel.center = CGPointMake(_unReadNewMessageLabel.frame.size.width / 2,
                                                    _unReadNewMessageLabel.frame.size.height / 2 - 2.5);
        [self.unreadRightBottomIcon addSubview:_unReadNewMessageLabel];
    }
    return _unReadNewMessageLabel;
}

- (RCChatSessionInputBarControl *)chatSessionInputBarControl {
    if (!_chatSessionInputBarControl) {
        _chatSessionInputBarControl = [[RCChatSessionInputBarControl alloc]
                initWithFrame:CGRectMake(0, self.view.bounds.size.height - RC_ChatSessionInputBar_Height -
                                                [self getIPhonexExtraBottomHeight],
                                         self.view.bounds.size.width, RC_ChatSessionInputBar_Height)
            withContainerView:self.view
                  controlType:RCChatSessionInputBarControlDefaultType
                 controlStyle:RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION
             defaultInputType:self.defaultInputType];
        _chatSessionInputBarControl.conversationType = self.conversationType;
        _chatSessionInputBarControl.targetId = self.targetId;
        _chatSessionInputBarControl.delegate = self;
        _chatSessionInputBarControl.dataSource = self;
        [self.view addSubview:_chatSessionInputBarControl];
    }
    return _chatSessionInputBarControl;
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        return [RCKitUtility getWindowSafeAreaInsets].bottom;
    }
    return height;
}

//接口向后兼容[[++
- (RCEmojiBoardView *)emojiBoardView {
    return self.chatSessionInputBarControl.emojiBoardView;
}

- (void)setEmojiBoardView:(RCEmojiBoardView *)emojiBoardView {
    self.chatSessionInputBarControl.emojiBoardView = emojiBoardView;
}

- (RCPluginBoardView *)pluginBoardView {
    return self.chatSessionInputBarControl.pluginBoardView;
}

- (void)setPluginBoardView:(RCPluginBoardView *)pluginBoardView {
    self.chatSessionInputBarControl.pluginBoardView = pluginBoardView;
}
//接口向后兼容--]]

- (void)setDefaultInputType:(RCChatSessionInputBarInputType)defaultInputType {
    _defaultInputType = defaultInputType;
    if (_chatSessionInputBarControl) {
        [_chatSessionInputBarControl setDefaultInputType:defaultInputType];
    }
}

- (void)updateUnreadMsgCountLabel {
    if (self.conversationDataRepository.count > 0) {
        if (self.unreadNewMsgArr.count > 0) {
            NSIndexPath *indexPath =
                [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1 inSection:0];
            UICollectionViewCell *cell = [self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                [self.unreadNewMsgArr removeAllObjects];
                self.unreadRightBottomIcon.hidden = YES;
            } else {
                self.unreadRightBottomIcon.hidden = NO;
                self.unReadNewMessageLabel.text =
                    (self.unreadNewMsgArr.count > 99)
                        ? @"99+"
                        : [NSString stringWithFormat:@"%li", (long)self.unreadNewMsgArr.count];
            }
        } else {
            self.unreadRightBottomIcon.hidden = YES;
        }
    } else {
        self.unreadRightBottomIcon.hidden = YES;
    }
    [self updateUnreadMsgCountLabelFrame];
}

- (void)updateUnreadMsgCountLabelFrame {
    if (!self.unreadRightBottomIcon.hidden) {
        CGRect rect = self.unreadRightBottomIcon.frame;
        if (self.referencingView) {
            rect.origin.y =
                self.chatSessionInputBarControl.frame.origin.y - 12 - 35 - self.referencingView.frame.size.height;
        } else {
            rect.origin.y = self.chatSessionInputBarControl.frame.origin.y - 12 - 35;
        }
        [self.unreadRightBottomIcon setFrame:rect];
    }
}

- (NSIndexPath *)getLastIndexPathForVisibleItems {
    NSArray *visiblePaths = [self.conversationMessageCollectionView indexPathsForVisibleItems];

    if (visiblePaths.count == 0) {
        return nil;
    } else if (visiblePaths.count == 1) {
        return (NSIndexPath *)[visiblePaths firstObject];
    }

    NSArray *sortedIndexPaths = [visiblePaths sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];

    return (NSIndexPath *)[sortedIndexPaths lastObject];
}

- (BOOL)isRemainMessageExisted {
    return self.locatedMessageSentTime != 0;
}

- (void)loadRemainMessageAndScrollToBottom:(BOOL)animated {
    self.locatedMessageSentTime = 0;
    self.conversationDataRepository = [[NSMutableArray alloc] init];
    [self loadLatestHistoryMessage];
    [self.conversationMessageCollectionView reloadData];
    [self scrollToBottomAnimated:animated];
}

#pragma mark <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTouchScrolled = YES;
    if (self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarDefaultStatus &&
        self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarRecordStatus) {
        [self.chatSessionInputBarControl resetToDefaultStatus];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y <= 0 && !self.isIndicatorLoading && !self.allMessagesAreLoaded &&
        self.isTouchScrolled) {
        [self.collectionViewHeader startAnimating];
        self.isIndicatorLoading = YES;
        [self performSelector:@selector(loadMoreHistoryMessage) withObject:nil afterDelay:0.5f];
    } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height &&
               !self.isIndicatorLoading && self.isTouchScrolled) {
        self.isIndicatorLoading = YES;
        [self performSelector:@selector(loadMoreNewerMessage) withObject:nil afterDelay:0.5f];
    }
}

/// 调用scrollToItemAtIndexPath方法，滚动动画执行完时调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    /// 请在停止滚动时、滚动动画执行完时更新右下角未读数气泡 或者在collectionview未处于底部时更新
    /// 又或者在撤回未读消息时更新，不要在其他时机更新，或者进行不必要的更新，浪费资源。
    [self updateUnreadMsgCountLabel];
}

/// 停止滚动时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateUnreadMsgCountLabel];
    self.isTouchScrolled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isTouchScrolled = NO;
    }
}

//点击状态栏屏蔽系统动作手动滚动到顶部并加载历史消息
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    if ([self.conversationMessageCollectionView numberOfItemsInSection:0] > 0) {
        [self.conversationMessageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                       atScrollPosition:(UICollectionViewScrollPositionTop)
                                                               animated:YES];
    }
    if (!self.isIndicatorLoading && !self.allMessagesAreLoaded) {
        self.isIndicatorLoading = YES;
        [self loadMoreHistoryMessage];
    }
    return NO;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }

    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);

    if (0 == finalRow) {
        return;
    }

    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionBottom
                                                           animated:animated];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.conversationDataRepository.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];

    model = [self setModelIsDisplayNickName:model];

    RCMessageContent *messageContent = model.content;
    RCMessageBaseCell *cell = nil;
    NSString *objName = [[messageContent class] getObjectName];
    if (self.cellMsgDict[objName]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:objName forIndexPath:indexPath];

        if ([messageContent isMemberOfClass:[RCPublicServiceMultiRichContentMessage class]]) {
            [(RCPublicServiceMultiImgTxtCell *)cell
                setPublicServiceDelegate:(id<RCPublicServiceMessageCellDelegate>)self];
        } else if ([messageContent isMemberOfClass:[RCPublicServiceRichContentMessage class]]) {
            [(RCPublicServiceImgTxtMsgCell *)cell
                setPublicServiceDelegate:(id<RCPublicServiceMessageCellDelegate>)self];
        }
        cell.isConversationAppear = self.isConversationAppear;
        [cell setDataModel:model];
        [cell setDelegate:self];
    } else if (!messageContent && [RCIM sharedRCIM].showUnkownMessage) {
        cell = [self rcUnkownConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
        [cell setDataModel:model];
        [cell setDelegate:self];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        cell = [self rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
#pragma clang diagnostic pop
    }

    if ((self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_Encrypted) &&
        [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(model.conversationType)]) {
        cell.isDisplayReadStatus = YES;
    }
    //接口向后兼容 [[++
    [self performSelector:@selector(willDisplayConversationTableCell:atIndexPath:)
               withObject:cell
               withObject:indexPath];
    //接口向后兼容 --]]
    [self willDisplayMessageCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        RCConversationCollectionViewHeader *headerView =
            [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                               withReuseIdentifier:@"RefreshHeadView"
                                                      forIndexPath:indexPath];
        self.collectionViewHeader = headerView;
        return headerView;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    model = [self setModelIsDisplayNickName:model];
    if (model.cellSize.height > 0 &&
        !(model.conversationType == ConversationType_CUSTOMERSERVICE &&
          [model.content isKindOfClass:[RCTextMessage class]])) {
        return model.cellSize;
    }

    RCMessageContent *messageContent = model.content;
    NSString *objectName = [[messageContent class] getObjectName];
    Class cellClass = self.cellMsgDict[objectName];
    if (class_getClassMethod(cellClass, @selector(sizeForMessageModel:withCollectionViewWidth:referenceExtraHeight:))) {

        CGFloat extraHeight = [self referenceExtraHeight:cellClass messageModel:model];
        CGSize size = [cellClass sizeForMessageModel:model
                             withCollectionViewWidth:collectionView.frame.size.width
                                referenceExtraHeight:extraHeight];

        if (size.width != 0 && size.height != 0) {
            model.cellSize = size;
            return size;
        }
    }

    if (!messageContent && [RCIM sharedRCIM].showUnkownMessage) {
        CGSize _size = [self rcUnkownConversationCollectionView:collectionView
                                                         layout:collectionViewLayout
                                         sizeForItemAtIndexPath:indexPath];
        _size.height += [self referenceExtraHeight:RCUnknownMessageCell.class messageModel:model];
        model.cellSize = _size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize _size = [self rcConversationCollectionView:collectionView
                                                   layout:collectionViewLayout
                                   sizeForItemAtIndexPath:indexPath];
#pragma clang diagnostic pop
        DebugLog(@"%@", NSStringFromCGSize(_size));
        _size.height += [self referenceExtraHeight:RCUnknownMessageCell.class messageModel:model];
        model.cellSize = _size;
    }

    return model.cellSize;
}

- (RCMessageBaseCell *)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageCell *__cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:rcUnknownMessageCellIndentifier forIndexPath:indexPath];
    [__cell setDataModel:model];
    return __cell;
}

- (CGSize)rcUnkownConversationCollectionView:(UICollectionView *)collectionView
                                      layout:(UICollectionViewLayout *)collectionViewLayout
                      sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat __width = CGRectGetWidth(collectionView.frame);
    CGFloat maxMessageLabelWidth = __width - 30 * 2;
    NSString *localizedMessage = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    CGSize __textSize = [RCKitUtility getTextDrawingSize:localizedMessage
                                                    font:[UIFont systemFontOfSize:14]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, 2000)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 6);
    return CGSizeMake(collectionView.bounds.size.width, __labelSize.height);
}

- (BOOL)isExtensionCell:(RCMessageContent *)messageContent {
    for (RCExtensionMessageCellInfo *cellInfo in self.extensionMessageCellInfoList) {
        if (cellInfo.messageContentClass == [messageContent class]) {
            return YES;
        }
    }
    return NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat width = self.conversationMessageCollectionView.frame.size.width;
    CGFloat height = 0;
    // 当加载本地历史消息小于 10 时，allMessagesAreLoaded 为 NO，此时高度设置为 0，否则会向下偏移 COLLECTION_VIEW_REFRESH_CONTROL_HEIGHT 的高度
    if(!self.allMessagesAreLoaded) {
        if (self.conversationDataRepository.count < 10) {
            height = 0;
        } else {
            height = COLLECTION_VIEW_REFRESH_CONTROL_HEIGHT;
        }
    }
    return (CGSize){width, height};
}

- (CGFloat)referenceExtraHeight:(Class)cellClass messageModel:(RCMessageModel *)model {
    // 每个 Cell 底部都有 14 个点
    CGFloat extraHeight = 14;
    if ([cellClass isSubclassOfClass:RCMessageBaseCell.class]) {
        if (model.isDisplayMessageTime) {
            extraHeight += 44;
        }
    }
    if ([cellClass isSubclassOfClass:RCMessageCell.class]) {
        // name label height
        if (model.isDisplayNickname && model.messageDirection == MessageDirection_RECEIVE) {
            extraHeight += 16;
        }
    }

    return extraHeight;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)figureOutAllConversationDataRepository {
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *model = [self.conversationDataRepository objectAtIndex:i];
        if (0 == i) {
            model.isDisplayMessageTime = YES;
        } else if (i > 0) {
            RCMessageModel *pre_model = [self.conversationDataRepository objectAtIndex:i - 1];

            long long previous_time = pre_model.sentTime;

            long long current_time = model.sentTime;

            long long interval =
                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            if (interval / 1000 <= 3 * 60) {
                if (model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height - 45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = NO;
            } else if (![model.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
                if (!model.isDisplayMessageTime && model.cellSize.height > 0) {
                    CGSize size = model.cellSize;
                    size.height = model.cellSize.height + 45;
                    model.cellSize = size;
                }
                model.isDisplayMessageTime = YES;
            }
        }
        if ([model.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
            model.isDisplayMessageTime = NO;
        }
    }
}

- (void)figureOutLatestModel:(RCMessageModel *)model {
    if (_conversationDataRepository.count > 0) {

        RCMessageModel *pre_model =
            [self.conversationDataRepository objectAtIndex:_conversationDataRepository.count - 1];

        long long previous_time = pre_model.sentTime;

        long long current_time = model.sentTime;

        long long interval =
            current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
        if (interval / 1000 <= 3 * 60) {
            model.isDisplayMessageTime = NO;
        } else {
            model.isDisplayMessageTime = YES;
        }
    } else {
        model.isDisplayMessageTime = YES;
    }
}

- (void)appendAndDisplayMessageAutoScrollToBottom:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    if (self.isClear) {
        return;
    }
    __weak typeof(self) ws = self;
    [self.appendMessageQueue addOperationWithBlock:^{
        if (ws.isClear) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                if (ws.isClear) {
                    return;
                }
                RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
                [ws figureOutLatestModel:model];
                if ([ws appendMessageModel:model]) {
                    NSIndexPath *indexPath =
                        [NSIndexPath indexPathForItem:ws.conversationDataRepository.count - 1 inSection:0];
                    if ([ws.conversationMessageCollectionView numberOfItemsInSection:0] !=
                        ws.conversationDataRepository.count - 1) {
                        NSLog(@"Error, datasource and collectionview are inconsistent!!");
                        [ws.conversationMessageCollectionView reloadData];
                        return;
                    }
                    [ws.conversationMessageCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                    [ws scrollToBottomAnimated:YES];
                }
            }
        });
        [NSThread sleepForTimeInterval:0.01];
    }];
}

- (void)appendAndDisplayMessage:(RCMessage *)rcMessage {
    if (!rcMessage) {
        return;
    }
    if (self.isClear) {
        return;
    }
    __weak typeof(self) ws = self;
    [self.appendMessageQueue addOperationWithBlock:^{
        {
            if (ws.isClear) {
                return;
}
dispatch_async(dispatch_get_main_queue(), ^{
    @autoreleasepool {
        if (ws.isClear) {
            return;
        }
        BOOL needAutoScrollToBottom = NO;
        if (ws.conversationDataRepository.count > 0) {
            needAutoScrollToBottom =
                [ws.conversationMessageCollectionView
                    cellForItemAtIndexPath:[NSIndexPath indexPathForItem:ws.conversationDataRepository.count - 1
                                                               inSection:0]] != nil;
        }
        if (([rcMessage.objectName isEqualToString:@"RCBQMM:EmojiMsg"] ||
             [rcMessage.objectName isEqualToString:RCCombineMessageTypeIdentifier]) &&
            rcMessage.messageDirection == MessageDirection_SEND) {
            ws.isNeedScrollToBottom = YES;
        }
        RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
        [ws figureOutLatestModel:model];
        if ([ws appendMessageModel:model]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:ws.conversationDataRepository.count - 1 inSection:0];
            if ([ws.conversationMessageCollectionView numberOfItemsInSection:0] !=
                ws.conversationDataRepository.count - 1) {
                NSLog(@"Error, datasource and collectionview are inconsistent!!");
                [ws.conversationMessageCollectionView reloadData];
                return;
            }
            [ws.conversationMessageCollectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            if (needAutoScrollToBottom || ws.isNeedScrollToBottom) {
                [ws scrollToBottomAnimated:YES];
                ws.isNeedScrollToBottom = NO;
            } else {
                if (self.conversationType == ConversationType_CHATROOM) {
                    [ws scrollToBottomAnimated:NO];
                } else {
                    [ws updateUnreadMsgCountLabel];
                }
            }
        }
    }
});
[NSThread sleepForTimeInterval:0.01];
}
}];
}

- (BOOL)appendMessageModel:(RCMessageModel *)model {
    long newId = model.messageId;
    for (RCMessageModel *__item in self.conversationDataRepository) {

        /*
         * 当id为－1时，不检查是否重复，直接插入
         * 该场景用于插入临时提示。
         */
        if (newId == -1) {
            break;
        }
        if (newId == __item.messageId) {
            return NO;
        }
    }

    if (newId != -1 && !(!model.content && model.messageId > 0 && [RCIM sharedRCIM].showUnkownMessage) &&
        !([[model.content class] persistentFlag] & MessagePersistent_ISPERSISTED)) {
        return NO;
    }

    model = [self setModelIsDisplayNickName:model];
    if (model.messageDirection != MessageDirection_RECEIVE) {
        if ([self isShowUnreadView:model]) {
            model.isCanSendReadReceipt = YES;
            if (!model.readReceiptInfo) {
                model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
            }
        }
    }
    [self.conversationDataRepository addObject:model];
    return YES;
}

- (BOOL)isShowUnreadView:(RCMessageModel *)model {
    if (model.messageDirection == MessageDirection_SEND && model.sentStatus == SentStatus_SENT &&
        model.messageId == self.showUnreadViewMessageId) {
        if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
            [self enabledReadReceiptMessage:model] &&
            (self.conversationType == ConversationType_DISCUSSION || self.conversationType == ConversationType_GROUP)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)pushOldMessageModel:(RCMessageModel *)model {
    if (!(!model.content && model.messageId > 0 && [RCIM sharedRCIM].showUnkownMessage) &&
        !([[model.content class] persistentFlag] & MessagePersistent_ISPERSISTED)) {
        return NO;
    }

    long ne_wId = model.messageId;
    for (RCMessageModel *__item in self.conversationDataRepository) {

        if (ne_wId == __item.messageId && ne_wId != -1) {
            return NO;
        }
    }
    model = [self setModelIsDisplayNickName:model];

    [self.conversationDataRepository insertObject:model atIndex:0];
    return YES;
}

- (void)loadLatestHistoryMessage {
    self.loadHistoryMessageFromRemote = NO;
    int beforeCount = 10;
    int afterCount = 10;
    if (self.isIPad) {
        beforeCount = 15;
        afterCount = 15;
    }
    NSArray *__messageArray = [[RCIMClient sharedRCIMClient] getHistoryMessages:self.conversationType
                                                                       targetId:self.targetId
                                                                       sentTime:self.locatedMessageSentTime
                                                                    beforeCount:beforeCount
                                                                     afterCount:afterCount];
    [self sendReadReceiptResponseForMessages:__messageArray];

    // 1.如果 self.locatedMessageSentTime
    // ==0,__messageArray.count<10,证明本地消息已经拉完，如果再次拉取，需要从远端拉消息
    if (self.conversationType != ConversationType_CHATROOM) {
        if (!self.locatedMessageSentTime && __messageArray.count < 10) {
            self.loadHistoryMessageFromRemote = YES;
            self.isLoadingHistoryMessage = NO;
            self.recordTime = ((RCMessage *)__messageArray.lastObject).sentTime;
//            [self loadRemoteHistoryMessages];
        }
        self.allMessagesAreLoaded = NO;
    }

    for (int i = 0; i < __messageArray.count; i++) {
        RCMessage *rcMsg = [__messageArray objectAtIndex:i];
        RCMessageModel *model = [RCMessageModel modelWithMessage:rcMsg];
        if ([model isKindOfClass:[RCCustomerServiceMessageModel class]]) {
            RCCustomerServiceMessageModel *csModel = (RCCustomerServiceMessageModel *)model;
            [csModel disableEvaluate];
        }
        [self pushOldMessageModel:model];
        [self showUnreadViewInMessageCell:model];
        // 2.如果 self.locatedMessageSentTime
        // 不为0,判断定位的那条消息之前的消息如果小于拉取的数量10，则再次拉取需要从远端拉消息，如果定位的那条消息之后的消息大于拉取的数量10，证明此时已经没有最新消息，isLoadingHistoryMessage
        // 置为 NO
        if (self.locatedMessageSentTime && model.sentTime == self.locatedMessageSentTime) {
            if (i < 10) {
                self.isLoadingHistoryMessage = NO;
            } else {
                self.isLoadingHistoryMessage = YES;
            }
            if (__messageArray.count - 1 - i < 10) {
                self.loadHistoryMessageFromRemote = YES;
            }
        }
    }
    //    //开启群回执，最后一条发送的文本消息两分钟内可以选择请求回执(暂时去掉，多端存在问题，另一端收到自己发送的消息时不显示，但是重新进来如果小于两分钟就会显示)
    //    if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
    //        (self.conversationType == ConversationType_DISCUSSION || self.conversationType == ConversationType_GROUP))
    //        {
    //        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    //        //        RCMessageModel *canReceiptMessageModel;
    //        int len = (int)self.conversationDataRepository.count - 1;
    //        for (int i = len; i >= 0; i--) {
    //            RCMessageModel *model = self.conversationDataRepository[i];
    //
    //            if (model.messageDirection == MessageDirection_SEND) {
    //                if (((nowTime - model.sentTime) < 1000 * 60 * 2) &&
    //                    [self enabledReadReceiptMessage:model] && model.sentTime && !model.readReceiptInfo) {
    //                    model.isCanSendReadReceipt = YES;
    //                    self.showUnreadViewMessageId = model.messageId;
    //                    if (!model.readReceiptInfo) {
    //                        model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
    //                    }
    //                    //                    canReceiptMessageModel = model;
    //                    //                    self.hideReceiptButtonTimer = [NSTimer
    //                    scheduledTimerWithTimeInterval:60.0f *
    //                    //                    2
    //                    //                                                     target:self
    //                    //                                                   selector:@selector(hideReceiptButton)
    //                    //                                                   userInfo:nil
    //                    //                                                    repeats:NO];
    //                }
    //                break;
    //            }
    //        }
    //    }

    [self figureOutAllConversationDataRepository];
}

- (void)showUnreadViewInMessageCell:(RCMessageModel *)model {
    RCMessageModel *lastModel = self.conversationDataRepository.lastObject;

    if (!self.showUnreadViewMessageId && !self.isLoadingHistoryMessage &&
        [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
        (self.conversationType == ConversationType_DISCUSSION || self.conversationType == ConversationType_GROUP) &&
        lastModel.messageId == model.messageId) {
        if (model.messageDirection == MessageDirection_SEND) {
            NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
            if (((nowTime - model.sentTime) < 1000 * [RCIM sharedRCIM].maxReadRequestDuration) &&
                [self enabledReadReceiptMessage:model] && model.sentTime && !model.readReceiptInfo) {
                model.isCanSendReadReceipt = YES;
                self.showUnreadViewMessageId = model.messageId;
                if (!model.readReceiptInfo) {
                    model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                }
            }
        }
    }
}

- (void)loadMoreHistoryMessage {
    msgRoamingServiceAvailable = YES;
    
    NSArray *__messageArray = [self loadMoreLocalMessage];
    
    if (__messageArray.count == 0 && self.loadHistoryMessageFromRemote && msgRoamingServiceAvailable &&
        self.conversationType != ConversationType_CHATROOM && self.conversationType != ConversationType_APPSERVICE &&
        self.conversationType != ConversationType_PUBLICSERVICE) {
        [self loadRemoteHistoryMessages];
    }
}

- (NSArray *)loadMoreLocalMessage {
    long lastMessageId = -1;
    self.recordTime = 0;
    if (self.conversationDataRepository.count > 0) {
        for (RCMessageModel *model in self.conversationDataRepository) {
            if (![model.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
                lastMessageId = model.messageId;
                self.recordTime = model.sentTime;
                break;
            }
        }
    }
    
    NSArray *__messageArray = [[RCIMClient sharedRCIMClient] getHistoryMessages:_conversationType
                                                                       targetId:_targetId
                                                                oldestMessageId:lastMessageId
                                                                          count:10];
    [self sendReadReceiptResponseForMessages:__messageArray];
    if (__messageArray.count > 0) {
        [self handleMessagesAfterLoadMore:__messageArray];
        RCMessage *message = __messageArray.lastObject;
        self.recordTime = message.sentTime;
    }
    if (__messageArray.count < 10) {
        self.allMessagesAreLoaded = NO;
        self.loadHistoryMessageFromRemote = YES;
//        [self loadRemoteHistoryMessages];
    }
    self.isIndicatorLoading = NO;
    [self.collectionViewHeader stopAnimating];
    return __messageArray;;
}

- (void)loadRemoteHistoryMessages {
    RCConversationType conversationType = self.conversationType;
    NSString *targetId = self.targetId;
    __weak typeof(self) weakSelf = self;
    if (conversationType == ConversationType_Encrypted) {
        self.allMessagesAreLoaded = YES;
        [self.collectionViewHeader stopAnimating];
        self.isIndicatorLoading = NO;
        return;
    }

    RCRemoteHistoryMsgOption *option = [RCRemoteHistoryMsgOption new];
    option.recordTime = self.recordTime;
    option.count = 10;
    option.order = RCRemoteHistoryOrderDesc;
    [[RCIMClient sharedRCIMClient] getRemoteHistoryMessages:conversationType
        targetId:targetId
        option:option
        success:^(NSArray *messages, BOOL isRemaining) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.allMessagesAreLoaded = !isRemaining;
                if (!isRemaining && messages.count == 0) {
                    [weakSelf resetSectionHeaderView];
                } else {
                    [weakSelf handleMessagesAfterLoadMore:messages];
                }
                [weakSelf.collectionViewHeader stopAnimating];
                weakSelf.isIndicatorLoading = NO;
            });
        }
        error:^(RCErrorCode status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == MSG_ROAMING_SERVICE_UNAVAILABLE) {
                    msgRoamingServiceAvailable = NO;
                }
                weakSelf.allMessagesAreLoaded = YES;
                [weakSelf resetSectionHeaderView];
                [weakSelf.collectionViewHeader stopAnimating];
                weakSelf.isIndicatorLoading = NO;
            });

            NSLog(@"load remote history message failed(%ld)", (long)status);
        }];
}

- (void)loadMoreNewerMessage {
    RCMessageModel *model = self.conversationDataRepository.lastObject;
    NSArray *messageArray = [[RCIMClient sharedRCIMClient] getHistoryMessages:self.conversationType
                                                                     targetId:self.targetId
                                                                   objectName:nil
                                                                baseMessageId:model.messageId
                                                                    isForward:NO
                                                                        count:10];
    if (!messageArray || messageArray.count < 10) {
        self.isLoadingHistoryMessage = NO;
    }
    [self sendReadReceiptResponseForMessages:messageArray];
    for (RCMessage *message in messageArray) {
        RCMessage *checkedmessage = [self willAppendAndDisplayMessage:message];
        if (checkedmessage) {
            [self appendAndDisplayMessage:message];
        }
    }
    self.isIndicatorLoading = NO;
}

/// 返回添加入conversationDataRepository中消息数量
- (NSInteger)appendLastestMessageToDataSource {
    NSArray *messageArray =
        [[RCIMClient sharedRCIMClient] getLatestMessages:self.conversationType targetId:self.targetId count:10];
    if (!messageArray || messageArray.count < 10) {
        self.isLoadingHistoryMessage = NO;
    }
    [self sendReadReceiptResponseForMessages:messageArray];
    NSInteger count = 0;
    for (RCMessage *message in messageArray.reverseObjectEnumerator.allObjects) {
        RCMessage *checkedmessage = [self willAppendAndDisplayMessage:message];
        if (checkedmessage) {
            RCMessageModel *model = [RCMessageModel modelWithMessage:checkedmessage];
            [self figureOutLatestModel:model];
            [self.conversationDataRepository addObject:model];
            count++;
        }
    }
    self.isIndicatorLoading = NO;
    return count;
}

- (void)handleMessagesAfterLoadMore:(NSArray *)__messageArray {
    CGFloat increasedHeight = 0;
    NSMutableArray *indexPathes = [[NSMutableArray alloc] initWithCapacity:10];
    int indexPathCount = 0;
    for (int i = 0; i < __messageArray.count; i++) {
        RCMessage *rcMsg = [__messageArray objectAtIndex:i];
        RCMessageModel *model = [RCMessageModel modelWithMessage:rcMsg];
        //__messageArray 数据源是倒序的，所以采用下列判断
        BOOL showTime = NO;
        if (i == __messageArray.count - 1) {
            showTime = YES;
        } else {
            NSInteger previousIndex = i + 1;
            RCMessageModel *premodel = __messageArray[previousIndex];
            long long previous_time = premodel.sentTime;
            long long current_time = model.sentTime;
            long long interval =
                current_time - previous_time > 0 ? current_time - previous_time : previous_time - current_time;
            showTime = interval / 1000 > 3 * 60;
        }
        if ([model isKindOfClass:[RCCustomerServiceMessageModel class]]) {
            RCCustomerServiceMessageModel *csModel = (RCCustomerServiceMessageModel *)model;
            [csModel disableEvaluate];
        }
        if ([self pushOldMessageModel:model]) {
            [self showUnreadViewInMessageCell:model];
            [indexPathes addObject:[NSIndexPath indexPathForItem:indexPathCount++ inSection:0]];
            CGSize itemSize = [self collectionView:self.conversationMessageCollectionView
                                            layout:self.customFlowLayout
                            sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            increasedHeight += itemSize.height;
            if (showTime) {
                CGSize size = model.cellSize;
                size.height = model.cellSize.height + 45;
                model.cellSize = size;
                model.isDisplayMessageTime = YES;
                increasedHeight += 45;
            }
        }
        if (rcMsg.messageId == self.firstUnreadMessage.messageId && self.unReadButton != nil &&
            self.enableUnreadMessageIcon) {
            //如果会话里都是未注册自定义消息，这时获取到的数据源是 0，点击右上角未读按钮会崩溃
            if (self.conversationDataRepository.count > 0) {
                RCOldMessageNotificationMessage *oldMessageTip = [[RCOldMessageNotificationMessage alloc] init];
                RCMessage *oldMessage = [[RCMessage alloc] initWithType:self.conversationType
                                                               targetId:self.targetId
                                                              direction:MessageDirection_SEND
                                                              messageId:-1
                                                                content:oldMessageTip];
                RCMessageModel *model = [RCMessageModel modelWithMessage:oldMessage];
                model.messageId = rcMsg.messageId;
                [self.conversationDataRepository insertObject:model atIndex:0];
                [indexPathes addObject:[NSIndexPath indexPathForItem:indexPathCount++ inSection:0]];
                CGSize itemSize = [self collectionView:self.conversationMessageCollectionView
                                                layout:self.customFlowLayout
                                sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                increasedHeight += itemSize.height;
            }
            [self.unReadButton removeFromSuperview];
            self.unReadButton = nil;
            self.unReadMessage = 0;
        }
    }

    if (self.conversationDataRepository.count <= 0) {
        return;
    }

    if (indexPathes.count <= 0) {
        return;
    }

    CGSize contentSize = self.conversationMessageCollectionView.contentSize;
    contentSize.height += increasedHeight;
    if (self.allMessagesAreLoaded) {
        contentSize.height -= COLLECTION_VIEW_REFRESH_CONTROL_HEIGHT;
    }
    self.customFlowLayout.collectionViewNewContentSize = contentSize;
    if (indexPathes.count <= 0) {
        return;
    }
    [UIView setAnimationsEnabled:NO];
    @try {
        if (self.conversationDataRepository.count == 1 ||
            [self.conversationMessageCollectionView numberOfItemsInSection:0] ==
                self.conversationDataRepository.count) {
            [self.conversationMessageCollectionView reloadData];
        } else {
            [self.conversationMessageCollectionView insertItemsAtIndexPaths:indexPathes];
        }
        [UIView setAnimationsEnabled:YES];
        [self.collectionViewHeader stopAnimating];
        self.isIndicatorLoading = NO;
        if (self.allMessagesAreLoaded) {
            UICollectionViewLayout *layout = self.conversationMessageCollectionView.collectionViewLayout;
            [self.conversationMessageCollectionView.collectionViewLayout invalidateLayout];
            [self.conversationMessageCollectionView setCollectionViewLayout:layout];
        }

    } @catch (NSException *except) {
        NSLog(@"----handleMessagesAfterLoadMore %@", except.description);
    }
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

//历史遗留接口
- (void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
}

- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView
                             cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    // RCMessageContent *messageContent = model.content;
    RCMessageCell *__cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:rcUnknownMessageCellIndentifier forIndexPath:indexPath];
    [__cell setDataModel:model];
    return __cell;
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat __width = CGRectGetWidth(collectionView.frame);
    CGFloat __height = 0;
    CGFloat maxMessageLabelWidth = __width - 30 * 2;
    NSString *localizedMessage = NSLocalizedStringFromTable(@"unknown_message_cell_tip", @"RongCloudKit", nil);
    CGSize __textSize = [RCKitUtility getTextDrawingSize:localizedMessage
                                                    font:[UIFont systemFontOfSize:14]
                                         constrainedSize:CGSizeMake(maxMessageLabelWidth, 2000)];
    __textSize = CGSizeMake(ceilf(__textSize.width), ceilf(__textSize.height));
    CGSize __labelSize = CGSizeMake(__textSize.width + 5, __textSize.height + 6);
    __height = __labelSize.height;
    return CGSizeMake(collectionView.bounds.size.width, __height);
}

//点击cell
- (void)didTapMessageCell:(RCMessageModel *)model {
    DebugLog(@"%s", __FUNCTION__);
    if (nil == model) {
        return;
    }

    RCMessageContent *_messageContent = model.content;

    if (model.messageDirection == MessageDirection_RECEIVE && _messageContent.destructDuration > 0) {
        if ([self alertBurnMessageRemind]) {
            return;
        }
    }

    if ([_messageContent isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMsg = (RCImageMessage *)_messageContent;
        if (imageMsg.destructDuration > 0) {
            [self presentBurnImagePreviewController:model];
        } else {
            [self presentImagePreviewController:model];
        }

    } else if ([_messageContent isMemberOfClass:[RCSightMessage class]]) {
        if ([[RCExtensionService sharedService] isCameraHolding]) {
            NSString *alertMessage = NSLocalizedStringFromTable(@"VoIPVideoCallExistedWarning", @"RongCloudKit", nil);
            [self showAlertController:alertMessage];
            return;
        }
        if ([[RCExtensionService sharedService] isAudioHolding]) {
            NSString *alertMessage = NSLocalizedStringFromTable(@"VoIPAudioCallExistedWarning", @"RongCloudKit", nil);
            [self showAlertController:alertMessage];
            return;
        }
        RCSightMessage *sightMsg = (RCSightMessage *)_messageContent;
        if (sightMsg.destructDuration > 0) {
            [self presentBurnSightViewPreviewViewController:model];
        } else {
            [self presentSightViewPreviewViewController:model];
        }

    } else if ([_messageContent isMemberOfClass:[RCGIFMessage class]]) {
        RCGIFMessage *gifMsg = (RCGIFMessage *)_messageContent;
        if (gifMsg.destructDuration > 0) {
            [self pushBurnGIFPreviewViewController:model];
        } else {
            [self pushGIFPreviewViewController:model];
        }

    } else if ([_messageContent isMemberOfClass:[RCCombineMessage class]]) {
        RCCombineMessage *combineMsg = (RCCombineMessage *)_messageContent;
        if (combineMsg.destructDuration > 0) {
        } else {
            [self pushCombinePreviewViewController:model];
        }

    } else if ([_messageContent isMemberOfClass:[RCVoiceMessage class]]) {
        if ([[RCExtensionService sharedService] isAudioHolding]) {
            NSString *alertMessage = NSLocalizedStringFromTable(@"AudioHoldingWarning", @"RongCloudKit", nil);
            [self showAlertController:alertMessage];
            return;
        }
        if (model.messageDirection == MessageDirection_RECEIVE && model.receivedStatus != ReceivedStatus_LISTENED) {
            self.isContinuousPlaying = YES;
        } else {
            self.isContinuousPlaying = NO;
        }
        model.receivedStatus = ReceivedStatus_LISTENED;
        NSUInteger row = [self.conversationDataRepository indexOfObject:model];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        RCVoiceMessageCell *cell =
            (RCVoiceMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            [cell playVoice];
        }
    } else if ([_messageContent isMemberOfClass:[RCHQVoiceMessage class]]) {
        if ([[RCExtensionService sharedService] isAudioHolding]) {
            NSString *alertMessage = NSLocalizedStringFromTable(@"AudioHoldingWarning", @"RongCloudKit", nil);
            [self showAlertController:alertMessage];
            return;
        }
        if (model.messageDirection == MessageDirection_RECEIVE && model.receivedStatus != ReceivedStatus_LISTENED) {
            self.isContinuousPlaying = YES;
        } else {
            self.isContinuousPlaying = NO;
        }
        if (((RCHQVoiceMessage *)_messageContent).localPath.length > 0) {
            model.receivedStatus = ReceivedStatus_LISTENED;
        }
        NSUInteger row = [self.conversationDataRepository indexOfObject:model];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        RCHQVoiceMessageCell *cell =
            (RCHQVoiceMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            [cell playVoice];
        }
    } else if ([_messageContent isMemberOfClass:[RCLocationMessage class]]) {
        // Show the location view controller
        RCLocationMessage *locationMessage = (RCLocationMessage *)(_messageContent);
        [self presentLocationViewController:locationMessage];
    } else if ([_messageContent isMemberOfClass:[RCTextMessage class]]) {
        // link
        RCTextMessage *textMsg = (RCTextMessage *)(_messageContent);
        if (model.messageDirection == MessageDirection_RECEIVE && textMsg.destructDuration > 0) {
            NSUInteger row = [self.conversationDataRepository indexOfObject:model];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            if (model.messageDirection == MessageDirection_RECEIVE && textMsg.destructDuration > 0) {
                [[RCIMClient sharedRCIMClient]
                    messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:model.messageId]];
            }
            model.cellSize = CGSizeZero;
            //更新UI
            [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
        }
        // phoneNumber
    } else if ([self isExtensionCell:_messageContent]) {
        [[RongIMKitExtensionManager sharedManager] didTapMessageCell:model];
    } else if ([_messageContent isMemberOfClass:[RCFileMessage class]]) {
        [self presentFilePreviewViewController:model];
    } else if ([_messageContent isMemberOfClass:[RCCSPullLeaveMessage class]]) {
        if (self.csConfig.leaveMessageType == RCCSLMNative && self.csConfig.leaveMessageNativeInfo.count > 0) {
            RCCSLeaveMessageController *leaveMsgVC = [[RCCSLeaveMessageController alloc] init];
            leaveMsgVC.leaveMessageConfig = self.csConfig.leaveMessageNativeInfo;
            leaveMsgVC.targetId = self.targetId;
            leaveMsgVC.conversationType = self.conversationType;
            __weak typeof(self) weakSelf = self;
            [leaveMsgVC setLeaveMessageSuccess:^{
                RCInformationNotificationMessage *warningMsg =
                    [RCInformationNotificationMessage notificationWithMessage:@"您已提交留言。" extra:nil];
                RCMessage *savedMsg = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:weakSelf.conversationType
                                                                                  targetId:weakSelf.targetId
                                                                                sentStatus:SentStatus_SENT
                                                                                   content:warningMsg];
                [weakSelf appendAndDisplayMessage:savedMsg];
            }];
            [self.navigationController pushViewController:leaveMsgVC animated:YES];
        } else if (self.csConfig.leaveMessageType == RCCSLMWeb) {
            [RCKitUtility openURLInSafariViewOrWebView:self.csConfig.leaveMessageWebUrl base:self];
        }
    }
}

- (void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model {
    [RCKitUtility openURLInSafariViewOrWebView:url base:self];
}

- (void)didTapReedit:(RCMessageModel *)model {
    // 获取被撤回的文本消息的内容
    RCRecallNotificationMessage *recallMessage = (RCRecallNotificationMessage *)model.content;
    NSString *content = recallMessage.recallContent;
    if (content.length > 0) {
        [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
        self.chatSessionInputBarControl.inputTextView.text =
            [NSString stringWithFormat:@"%@%@", self.chatSessionInputBarControl.inputTextView.text, content];
    }
}

- (void)didTapReferencedContentView:(RCMessageModel *)model {
    [self previewReferenceView:model];
}

- (void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model {
    NSString *phoneStr = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneStr]];
}

//点击头像
- (void)didTapCellPortrait:(NSString *)userId {
}

- (BOOL)canRecallMessageOfModel:(RCMessageModel *)model {
    long long cTime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long ServerTime = cTime - [[RCIMClient sharedRCIMClient] getDeltaTime];
    long long interval = ServerTime - model.sentTime > 0 ? ServerTime - model.sentTime : model.sentTime - ServerTime;
    return (interval <= [RCIM sharedRCIM].maxRecallDuration * 1000 && model.messageDirection == MessageDirection_SEND &&
            [RCIM sharedRCIM].enableMessageRecall && model.sentStatus != SentStatus_SENDING &&
            model.sentStatus != SentStatus_FAILED && model.sentStatus != SentStatus_CANCELED &&
            (model.conversationType == ConversationType_PRIVATE || model.conversationType == ConversationType_GROUP ||
             model.conversationType == ConversationType_DISCUSSION) &&
            ![model.content isKindOfClass:NSClassFromString(@"JrmfRedPacketMessage")] &&
            ![model.content isKindOfClass:NSClassFromString(@"RCCallSummaryMessage")]);
}

- (NSArray<UIMenuItem *> *)getLongTouchMessageCellMenuList:(RCMessageModel *)model {
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Copy", @"RongCloudKit", nil)
                                                      action:@selector(onCopyMessage:)];
    UIMenuItem *deleteItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Delete", @"RongCloudKit", nil)
                                   action:@selector(onDeleteMessage:)];

    UIMenuItem *recallItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Recall", @"RongCloudKit", nil)
                                   action:@selector(onRecallMessage:)];
    UIMenuItem *multiSelectItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"MessageTapMore", @"RongCloudKit", nil)
                                   action:@selector(onMultiSelectMessageCell:)];

    UIMenuItem *referItem =
        [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Reference", @"RongCloudKit", nil)
                                   action:@selector(onReferenceMessageCell:)];
    NSMutableArray *items = @[].mutableCopy;
    if (model.content.destructDuration > 0) {
        [items addObject:deleteItem];
        if ([self canRecallMessageOfModel:model]) {
            [items addObject:recallItem];
        }
        [items addObject:multiSelectItem];
    } else {
        if ([model.content isMemberOfClass:[RCTextMessage class]] ||
            [model.content isMemberOfClass:[RCReferenceMessage class]]) {
            [items addObject:copyItem];
        }
        [items addObject:deleteItem];
        if ([self canRecallMessageOfModel:model]) {
            [items addObject:recallItem];
        }
        if ([self enableReferenceMessage:model]) {
            [items addObject:referItem];
        }

        [items addObject:multiSelectItem];
    }
    self.currentSelectedModel = model;
    return items.copy;
}

//长按消息内容
- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    //长按消息需要停止播放语音消息
    NSUInteger row = [self.conversationDataRepository indexOfObject:model];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    RCVoiceMessageCell *cell =
        (RCVoiceMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
    if (cell && [cell isMemberOfClass:[RCVoiceMessageCell class]]) {
        [cell stopPlayingVoice];
    }
    if (cell && [cell isMemberOfClass:[RCHQVoiceMessageCell class]]) {
        [cell stopPlayingVoice];
    }

    self.chatSessionInputBarControl.inputTextView.disableActionMenu = YES;
    self.longPressSelectedModel = model;
    if (![self.chatSessionInputBarControl.inputTextView isFirstResponder]) {
        //聊天界面不为第一响应者时，长按消息，UIMenuController不能正常显示菜单
        // inputTextView 是第一响应者时，不需要再设置 self 为第一响应者，否则会导致键盘收起
        [self becomeFirstResponder];
    }
    CGRect rect = [self.view convertRect:view.frame fromView:view.superview];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[self getLongTouchMessageCellMenuList:model]];
    if (@available(iOS 13.0, *)) {
        [menu showMenuFromView:self.view rect:rect];
    } else {
        [menu setTargetRect:rect inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }

}

- (void)didTapCancelUploadButton:(RCMessageModel *)model {
    [self cancelUploadMedia:model];
}

- (void)cancelUploadMedia:(RCMessageModel *)model {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RCIM sharedRCIM] cancelSendMediaMessage:model.messageId];
    });
}
/**
 *  UIResponder
 *
 *  @return
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender];
}

- (NSIndexPath *)findDataIndexFromMessageList:(RCMessageModel *)model {
    NSIndexPath *indexPath;
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        RCMessageModel *msg = (self.conversationDataRepository)[i];
        if (msg.messageId == model.messageId && ![msg.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
            indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            ;
            break;
        }
    }
    return indexPath;
}

- (void)resendMessage:(RCMessageContent *)messageContent {
    if ([messageContent isMemberOfClass:RCImageMessage.class]) {
        RCImageMessage *imageMessage = (RCImageMessage *)messageContent;
        if (imageMessage.imageUrl) {
            imageMessage.originalImage = [UIImage imageWithContentsOfFile:imageMessage.imageUrl];
        } else {
            imageMessage.originalImage = [UIImage imageWithContentsOfFile:imageMessage.localPath];
        }
        [self sendMessage:imageMessage pushContent:nil];
    } else if ([messageContent isMemberOfClass:RCFileMessage.class]) {
        RCFileMessage *fileMessage = (RCFileMessage *)messageContent;
        [self sendMessage:fileMessage pushContent:nil];
    } else {
        [self sendMessage:messageContent pushContent:nil];
    }
}

- (void)didTapmessageFailedStatusViewForResend:(RCMessageModel *)model {
    // resending message.
    DebugLog(@"%s", __FUNCTION__);

    RCMessageContent *content = model.content;
    long msgId = model.messageId;
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    if (!indexPath) {
        return;
    }
    if ([content isMemberOfClass:[RCHQVoiceMessage class]] && model.messageDirection == MessageDirection_RECEIVE) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
            [[RCHQVoiceMsgDownloadManager defaultManager] pushVoiceMsgs:@[ message ] priority:NO];
            [self.conversationMessageCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        });
    } else {
        [[RCIMClient sharedRCIMClient] deleteMessages:@[ @(msgId) ]];
        [self.conversationDataRepository removeObject:model];
        [self.conversationMessageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        self.isNeedScrollToBottom = YES;
        [self resendMessage:content];
    }
}

/**
 *  打开大图。开发者可以重写，自己下载并且展示图片。默认使用内置controller
 *
 *  @param imageMessageContent 图片消息内容
 */
- (void)presentImagePreviewController:(RCMessageModel *)model {
    [self presentImagePreviewController:model onlyPreviewCurrentMessage:NO];
}

- (void)presentImagePreviewController:(RCMessageModel *)model
            onlyPreviewCurrentMessage:(BOOL)onlyPreviewCurrentMessage {
    RCImageSlideController *_imagePreviewVC = [[RCImageSlideController alloc] init];
    _imagePreviewVC.messageModel = model;
    _imagePreviewVC.onlyPreviewCurrentMessage = onlyPreviewCurrentMessage;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_imagePreviewVC];

    if (self.navigationController) {
        //导航和原有的配色保持一直
        UIImage *image = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];

        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)presentBurnImagePreviewController:(RCMessageModel *)model {
    RCBurnImageBrowseController *_imagePreviewVC = [[RCBurnImageBrowseController alloc] init];
    _imagePreviewVC.messageModel = model;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_imagePreviewVC];
    if (self.navigationController) {
        //导航和原有的配色保持一直
        UIImage *image = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        [nav.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav
                       animated:YES
                     completion:^{

                     }];
}

- (void)pushGIFPreviewViewController:(RCMessageModel *)model {
    RCGIFPreviewViewController *gifPreviewVC = [[RCGIFPreviewViewController alloc] init];
    gifPreviewVC.messageModel = model;
    [self.navigationController pushViewController:gifPreviewVC animated:NO];
}

- (void)pushBurnGIFPreviewViewController:(RCMessageModel *)model {
    RCBurnGIFPreviewViewController *gifPreviewVC = [[RCBurnGIFPreviewViewController alloc] init];
    gifPreviewVC.messageModel = model;
    [self.navigationController pushViewController:gifPreviewVC animated:NO];
}

- (void)pushCombinePreviewViewController:(RCMessageModel *)model {
    NSString *navTitle = [RCCombineMessageUtility getCombineMessagePreviewVCTitle:(RCCombineMessage *)(model.content)];
    RCCombineMessagePreviewViewController *combinePreviewVC =
        [[RCCombineMessagePreviewViewController alloc] initWithMessageModel:model navTitle:navTitle];
    [self.navigationController pushViewController:combinePreviewVC animated:YES];
}

- (void)presentSightViewPreviewViewController:(RCMessageModel *)model {
    RCSightSlideViewController *svc = [[RCSightSlideViewController alloc] init];
    svc.messageModel = model;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:svc];
    navc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)presentBurnSightViewPreviewViewController:(RCMessageModel *)model {
    RCBurnSightViewController *svc = [[RCBurnSightViewController alloc] init];
    svc.messageModel = model;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:svc];
    navc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navc
                       animated:YES
                     completion:^{

                     }];
}

/**
 *  打开地理位置。开发者可以重写，自己根据经纬度打开地图显示位置。默认使用内置地图
 *
 *  @param locationMessageContent 位置消息
 */
- (void)presentLocationViewController:(RCLocationMessage *)locationMessageContent {
    //默认方法跳转
    RCLocationViewController *locationViewController = [[RCLocationViewController alloc] init];
    locationViewController.locationName = locationMessageContent.locationName;
    locationViewController.location = locationMessageContent.location;
    locationViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:locationViewController];
    if (self.navigationController) {
        //导航和原有的配色保持一直
        UIImage *image = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];

        [navc.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    navc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navc animated:YES completion:NULL];
}

- (void)presentFilePreviewViewController:(RCMessageModel *)model {
    RCFilePreviewViewController *fileViewController = [[RCFilePreviewViewController alloc] init];
    fileViewController.messageModel = model;
    [self.navigationController pushViewController:fileViewController animated:YES];
}

- (void)updateForMessageSendOut:(RCMessage *)message {
    if ([message.content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *img = (RCImageMessage *)message.content;
        img.originalImage = nil;
    }
    __weak typeof(self) __weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        RCMessage *tempMessage = [__weakself willAppendAndDisplayMessage:message];
        __weakself.showUnreadViewMessageId = message.messageId;
        [__weakself appendAndDisplayMessage:tempMessage];
    });
}

- (void)updateForMessageSendProgress:(int)progress messageId:(long)messageId {
    RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_PROGRESS;
    notifyModel.messageId = messageId;
    notifyModel.progress = progress;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                                            object:notifyModel];
    });
}

- (void)updateForMessageSendSuccess:(long)messageId content:(RCMessageContent *)content {
    DebugLog(@"message<%ld> send succeeded ", messageId);
    [self startNotSendMessageAlertTimer];
    RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_SUCCESS;
    notifyModel.messageId = messageId;

    __weak typeof(self) __weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (RCMessageModel *model in __weakself.conversationDataRepository) {
            if (model.messageId == messageId) {
                model.sentStatus = SentStatus_SENT;
                if (model.messageId > 0) {
                    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
                    if (message) {
                        model.sentTime = message.sentTime;
                        model.messageUId = message.messageUId;
                        model.content = message.content;
                    }
                }
                break;
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                                            object:notifyModel];
        if (messageId == __weakself.showUnreadViewMessageId) {
            [__weakself updateLastMessageReadReceiptStatus:messageId content:content];
        }
        if (__weakself.chatSessionInputBarControl.inputTextView.text &&
            __weakself.chatSessionInputBarControl.inputTextView.text.length > 0) {
            [__weakself.chatSessionInputBarControl.emojiBoardView enableSendButton:YES];
        } else {
            [__weakself.chatSessionInputBarControl.emojiBoardView enableSendButton:NO];
        }
    });

    [self didSendMessage:0 content:content];

    if ([content isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)content;
        if (self.enableSaveNewPhotoToLocalSystem && _isTakeNewPhoto) {
            UIImage *image = [UIImage imageWithContentsOfFile:imageMessage.localPath];
            imageMessage = [RCImageMessage messageWithImage:image];
            [self saveNewPhotoToLocalSystemAfterSendingSuccess:imageMessage.originalImage];
        }
    }
}

- (void)updateLastMessageReadReceiptStatus:(long)messageId content:(RCMessageContent *)content {
    RCMessage *message = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    RCMessageModel *model = [RCMessageModel modelWithMessage:message];
    if ([self enabledReadReceiptMessage:model]) {
        if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
            (self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_DISCUSSION)) {
            int len = (int)self.conversationDataRepository.count - 1;
            for (int i = len; i >= 0; i--) {
                RCMessageModel *model = self.conversationDataRepository[i];
                if (model.messageId == messageId) {
                    model.isCanSendReadReceipt = YES;
                    if (!model.readReceiptInfo) {
                        model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                    }
                } else {
                    model.isCanSendReadReceipt = NO;
                }
            }
        }
        if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
            (self.conversationType == ConversationType_DISCUSSION || self.conversationType == ConversationType_GROUP)) {
            NSDictionary *statusDic = @{
                @"targetId" : self.targetId,
                @"conversationType" : @(self.conversationType),
                @"messageId" : @(messageId)
            };
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"KNotificationMessageBaseCellUpdateCanReceiptStatus"
                              object:statusDic];
        }
    }
    dispatch_after(
        // 0.3s之后再刷新一遍，防止没有Cell绘制太慢
        dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
                (self.conversationType == ConversationType_DISCUSSION ||
                 self.conversationType == ConversationType_GROUP) &&
                [content isMemberOfClass:[RCTextMessage class]]) {
                NSDictionary *statusDic = @{
                    @"targetId" : self.targetId,
                    @"conversationType" : @(self.conversationType),
                    @"messageId" : @(messageId)
                };
                [[NSNotificationCenter defaultCenter]
                    postNotificationName:@"KNotificationMessageBaseCellUpdateCanReceiptStatus"
                                  object:statusDic];
            }
        });
}

- (void)updateForMessageSendError:(RCErrorCode)nErrorCode
                        messageId:(long)messageId
                          content:(RCMessageContent *)content {
    DebugLog(@"message<%ld> send failed error code %d", messageId, (int)nErrorCode);

    RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_FAILED;
    notifyModel.messageId = messageId;

    __weak typeof(self) __weakself = self;
    dispatch_after(
        // 发送失败0.3s之后再刷新，防止没有Cell绘制太慢
        dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.3f), dispatch_get_main_queue(), ^{
            for (RCMessageModel *model in __weakself.conversationDataRepository) {
                if (model.messageId == messageId) {
                    model.sentStatus = SentStatus_FAILED;
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                                                object:notifyModel];
        });

    [self didSendMessage:nErrorCode content:content];

    RCInformationNotificationMessage *informationNotifiMsg = nil;
    if (NOT_IN_DISCUSSION == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"NOT_IN_DISCUSSION", @"RongCloudKit", nil)
                              extra:nil];
    } else if (NOT_IN_GROUP == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"NOT_IN_GROUP", @"RongCloudKit", nil)
                              extra:nil];
    } else if (NOT_IN_CHATROOM == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"NOT_IN_CHATROOM", @"RongCloudKit", nil)
                              extra:nil];
    } else if (REJECTED_BY_BLACKLIST == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"Message rejected", @"RongCloudKit", nil)
                              extra:nil];
    } else if (FORBIDDEN_IN_GROUP == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"FORBIDDEN_IN_GROUP", @"RongCloudKit", nil)
                              extra:nil];
    } else if (FORBIDDEN_IN_CHATROOM == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"ForbiddenInChatRoom", @"RongCloudKit", nil)
                              extra:nil];
    } else if (KICKED_FROM_CHATROOM == nErrorCode) {
        informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:NSLocalizedStringFromTable(@"KickedFromChatRoom", @"RongCloudKit", nil)
                              extra:nil];
    }
    if (nil != informationNotifiMsg) {
        __block RCMessage *tempMessage = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:self.conversationType
                                                                                     targetId:self.targetId
                                                                                   sentStatus:SentStatus_SENT
                                                                                      content:informationNotifiMsg];
        dispatch_async(dispatch_get_main_queue(), ^{
            tempMessage = [__weakself willAppendAndDisplayMessage:tempMessage];
            if (tempMessage) {
                __weakself.isNeedScrollToBottom = YES;
                [__weakself appendAndDisplayMessage:tempMessage];
            }
        });
    }
}

- (void)updateForMessageSendCanceled:(long)messageId content:(RCMessageContent *)content {
    DebugLog(@"message<%ld> canceled", messageId);

    RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_CANCELED;
    notifyModel.messageId = messageId;

    __weak typeof(self) __weakself = self;
    dispatch_after(
        // 发送失败0.3s之后再刷新，防止没有Cell绘制太慢
        dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.3f), dispatch_get_main_queue(), ^{
            for (RCMessageModel *model in __weakself.conversationDataRepository) {
                if (model.messageId == messageId) {
                    model.sentStatus = SentStatus_CANCELED;
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                                                object:notifyModel];
        });

    [self didCancelMessage:content];
}

- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    if (self.targetId == nil) {
        return;
    }

    messageContent = [self willSendMessage:messageContent];
    if (messageContent == nil) {
        return;
    }
    if (messageContent.destructDuration > 0) {
        pushContent = BurnPushContent;
    }
    self.isNeedScrollToBottom = YES;
    
    if ([messageContent isKindOfClass:[RCMediaMessageContent class]]) {
        
        [[RCIM sharedRCIM] sendMediaMessage:self.conversationType
                                   targetId:self.targetId
                                    content:messageContent
                                pushContent:pushContent
                                   pushData:nil
                                   progress:nil
                                    success:nil
                                      error:nil
                                     cancel:nil];
        
    } else {
        
        [[RCIM sharedRCIM] sendMessage:self.conversationType
                              targetId:self.targetId
                               content:messageContent
                           pushContent:pushContent
                              pushData:nil
                               success:nil
                                 error:nil];
    }
}

- (void)sendMediaMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent {
    if (!self.targetId) {
        return;
    }

    messageContent = [self willSendMessage:messageContent];
    if (messageContent == nil) {
        return;
    }

    [[RCIM sharedRCIM] sendMediaMessage:self.conversationType
                               targetId:self.targetId
                                content:messageContent
                            pushContent:pushContent
                               pushData:nil
                               progress:nil
                                success:nil
                                  error:nil
                                 cancel:nil];
}

- (void)sendMediaMessage:(RCMessageContent *)messageContent
             pushContent:(NSString *)pushContent
               appUpload:(BOOL)appUpload {
    if (!appUpload) {
        [self sendMessage:messageContent pushContent:pushContent];
        return;
    }
    __weak typeof(self) ws = self;
    RCConversationType conversationType = self.conversationType;
    NSString *targetId = [self.targetId copy];
    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient] sendMediaMessage:conversationType
        targetId:targetId
        content:messageContent
        pushContent:pushContent
        pushData:@""
        uploadPrepare:^(RCUploadMediaStatusListener *uploadListener) {
            [ws uploadMedia:uploadListener.currentMessage uploadListener:uploadListener];
        }
        progress:^(int progress, long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : targetId,
                @"conversationType" : @(conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_SENDING),
                @"progress" : @(progress)
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        success:^(long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : targetId,
                @"conversationType" : @(conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_SENT),
                @"content" : messageContent
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        error:^(RCErrorCode errorCode, long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : targetId,
                @"conversationType" : @(conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_FAILED),
                @"error" : @(errorCode),
                @"content" : messageContent
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        cancel:^(long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : targetId,
                @"conversationType" : @(conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_CANCELED),
                @"content" : messageContent
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                        object:rcMessage
                                                      userInfo:nil];
}

- (void)uploadMedia:(RCMessage *)message uploadListener:(RCUploadMediaStatusListener *)uploadListener {
    uploadListener.errorBlock(-1);
    NSLog(@"error, App应该实现uploadMedia:uploadListener:函数用来上传媒体");
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //            int i = 0;
    //            for (i = 0; i < 100; i++) {
    //                uploadListener.updateBlock(i);
    //                [NSThread sleepForTimeInterval:0.2];
    //            }
    //            RCImageMessage *imageMsg = (RCImageMessage*)message.content;
    //            imageMsg.imageUrl = @"http://www.rongcloud.cn/images/newVersion/bannerInner.png?0717";
    //            uploadListener.successBlock(imageMsg);
    //        });
}

//接口向后兼容 [[++
- (void)sendImageMessage:(RCImageMessage *)imageMessage pushContent:(NSString *)pushContent {
    [self sendMessage:imageMessage pushContent:pushContent];
}

- (void)sendImageMessage:(RCImageMessage *)imageMessage pushContent:(NSString *)pushContent appUpload:(BOOL)appUpload {
    if (!appUpload) {
        [self sendMessage:imageMessage pushContent:pushContent];
        return;
    }

    __weak typeof(self) __weakself = self;

    RCMessage *rcMessage = [[RCIMClient sharedRCIMClient] sendMediaMessage:self.conversationType
        targetId:self.targetId
        content:imageMessage
        pushContent:pushContent
        pushData:@""
        uploadPrepare:^(RCUploadMediaStatusListener *uploadListener) {
            [__weakself uploadMedia:uploadListener.currentMessage uploadListener:uploadListener];
        }
        progress:^(int progress, long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : __weakself.targetId,
                @"conversationType" : @(__weakself.conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_SENDING),
                @"progress" : @(progress)
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        success:^(long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : __weakself.targetId,
                @"conversationType" : @(__weakself.conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_SENT),
                @"content" : imageMessage
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        error:^(RCErrorCode errorCode, long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : __weakself.targetId,
                @"conversationType" : @(__weakself.conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_FAILED),
                @"error" : @(errorCode),
                @"content" : imageMessage
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }
        cancel:^(long messageId) {
            NSDictionary *statusDic = @{
                @"targetId" : __weakself.targetId,
                @"conversationType" : @(__weakself.conversationType),
                @"messageId" : @(messageId),
                @"sentStatus" : @(SentStatus_CANCELED),
                @"content" : imageMessage
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                                object:nil
                                                              userInfo:statusDic];
        }];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RCKitSendingMessageNotification"
                                                        object:rcMessage
                                                      userInfo:nil];
}

- (void)uploadImage:(RCMessage *)message uploadListener:(RCUploadImageStatusListener *)uploadListener {
    if (!uploadListener) {
        NSLog(@"error, App应该实现uploadImage函数用来上传图片");
        return;
    }
    uploadListener.errorBlock(-1);
    NSLog(@"error, App应该实现uploadImage函数用来上传图片");
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        int i = 0;
    //        for (i = 0; i < 100; i++) {
    //            uploadListener.updateBlock(i);
    //            [NSThread sleepForTimeInterval:0.2];
    //        }
    //        uploadListener.successBlock(@"http://www.rongcloud.cn/images/newVersion/bannerInner.png?0717");
    //    });
}
//接口向后兼容 --]]

- (void)receiveMessageHasReadNotification:(NSNotification *)notification {
    NSNumber *ctype = [notification.userInfo objectForKey:@"cType"];
    NSNumber *time = [notification.userInfo objectForKey:@"messageTime"];
    NSString *targetId = [notification.userInfo objectForKey:@"tId"];

    if (ctype.intValue == (int)self.conversationType && [targetId isEqualToString:self.targetId]) {
        // TODO:通知UI消息已读
        dispatch_async(dispatch_get_main_queue(), ^{
            for (RCMessageModel *model in self.conversationDataRepository) {
                if (model.messageDirection == MessageDirection_SEND && model.sentTime <= time.longLongValue &&
                    model.sentStatus == SentStatus_SENT) {
                    RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
                    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_HASREAD;
                    model.sentStatus = SentStatus_READ;
                    notifyModel.messageId = model.messageId;
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                      object:notifyModel];
                }
            }
        });
    }
}

- (void)didReceiveRecallMessageNotification:(NSNotification *)notification {
    __weak typeof(self) __blockSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([RCVoicePlayer defaultPlayer].isPlaying &&
            [RCVoicePlayer defaultPlayer].messageId == [notification.object longValue]) {
            [[RCVoicePlayer defaultPlayer] stopPlayVoice];
        }
        long recalledMsgId = [notification.object longValue];
        RCMessage *recalledMsg = [[RCIMClient sharedRCIMClient] getMessage:recalledMsgId];

        // 更新右下角未读数(条件：同一个会话／开启提示／未在底部／不是搜索进入的界面／未读数不为0)
        if (__blockSelf.enableNewComingMessageIcon && recalledMsg.conversationType == __blockSelf.conversationType &&
            [recalledMsg.targetId isEqual:__blockSelf.targetId] && ![__blockSelf isAtTheBottomOfTableView] &&
            ![__blockSelf isRemainMessageExisted] && __blockSelf.unreadNewMsgArr.count != 0) {
            //遍历删除对应的消息
            for (NSNumber *messageId in __blockSelf.unreadNewMsgArr) {
                if ([messageId longValue] == recalledMsgId) {
                    [__blockSelf.unreadNewMsgArr removeObject:messageId];
                    break;
                }
            }
            [__blockSelf updateUnreadMsgCountLabel];
        }
        [__blockSelf reloadRecalledMessage:recalledMsgId];
    });
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    if (self.isClear) {
        return;
    }
    __block BOOL needAutoScrollToBottom = NO;
    __block RCMessage *rcMessage = notification.object;
    RCMessageModel *model = [RCMessageModel modelWithMessage:rcMessage];
    NSDictionary *leftDic = notification.userInfo;
    //进入聊天室第一次拉取消息完成需要滑动到最下方
    if (self.conversationType == ConversationType_CHATROOM && !self.isChatRoomHistoryMessageLoaded) {

        if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
            self.isNeedScrollToBottom = YES;
            self.isChatRoomHistoryMessageLoaded = YES;
            needAutoScrollToBottom = YES;
        }
    }

    if (model.conversationType == self.conversationType && [model.targetId isEqual:self.targetId]) {
        [self startNotReciveMessageAlertTimer];
        if (self.isConversationAppear) {
            if (self.conversationType != ConversationType_CHATROOM && rcMessage.messageId > 0) {
                [[RCIMClient sharedRCIMClient] setMessageReceivedStatus:rcMessage.messageId
                                                         receivedStatus:ReceivedStatus_READ];
            }
        } else {
            self.unReadMessage++;
        }
        Class messageContentClass = model.content.class;

        NSInteger persistentFlag = [messageContentClass persistentFlag];
        //如果开启消息回执，收到消息要发送已读消息，发送失败存入数据库
        if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
            if (self.isConversationAppear && [self.targetId isEqualToString:model.targetId] &&
                self.conversationType == model.conversationType && model.messageDirection == MessageDirection_RECEIVE &&
                (persistentFlag & MessagePersistent_ISPERSISTED)) {
                if ([[RCIM sharedRCIM]
                            .enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)] &&
                    (self.conversationType == ConversationType_PRIVATE ||
                     self.conversationType == ConversationType_Encrypted)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.lastReadReceiptTime = model.sentTime;
                        [self delaySendReadReceiptMessage];
                    });
                }
            }
        }
        _hasReceiveNewMessage = YES;

        __weak typeof(self) __blockSelf = self;

        dispatch_async(dispatch_get_main_queue(), ^{
            //数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
            //用户可以手动下拉更多消息，查看更多历史消息。
            [__blockSelf clearOldestMessagesWhenMemoryWarning];
            rcMessage = [__blockSelf willAppendAndDisplayMessage:rcMessage];
            if (rcMessage) {
                if (rcMessage.messageDirection == MessageDirection_SEND) {
                    __blockSelf.showUnreadViewMessageId = rcMessage.messageId;
                }
                if (self.conversationDataRepository.count > 0) {
                    needAutoScrollToBottom =
                        [self.conversationMessageCollectionView
                            cellForItemAtIndexPath:[NSIndexPath
                                                       indexPathForItem:self.conversationDataRepository.count - 1
                                                              inSection:0]] != nil;
                }
                if (!self.isLoadingHistoryMessage) {
                    if (needAutoScrollToBottom) {
                        [__blockSelf appendAndDisplayMessageAutoScrollToBottom:rcMessage];
                    } else {
                        [__blockSelf appendAndDisplayMessage:rcMessage];
                    }
                }
                if (rcMessage.messageDirection == MessageDirection_SEND) {
                    [self.appendMessageQueue addOperationWithBlock:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [__blockSelf updateForMessageSendSuccess:rcMessage.messageId content:rcMessage.content];
                        });
                    }];
                }
                UIMenuController *menu = [UIMenuController sharedMenuController];
                menu.menuVisible = NO;
                // 是否显示右下未读消息数
                if (__blockSelf.enableNewComingMessageIcon == YES && (persistentFlag & MessagePersistent_ISPERSISTED)) {
                    if (![__blockSelf isAtTheBottomOfTableView] &&
                        ![rcMessage.senderUserId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
                        [__blockSelf.unreadNewMsgArr addObject:[NSNumber numberWithLong:rcMessage.messageId]];
                        [__blockSelf updateUnreadMsgCountLabel];
                    }
                }
            }
        });
    } else {
        if (leftDic && [leftDic[@"left"] isEqual:@(0)]) {
            [self notifyUpdateUnreadMessageCount];
        }
    }
}

- (void)delaySendReadReceiptMessage {
    if (!self.isWaitSendReadReceipt && self.lastReadReceiptTime > 0) {
        self.isWaitSendReadReceipt = YES;
        [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:self.conversationType
                                                     targetId:self.targetId
                                                         time:self.lastReadReceiptTime
                                                      success:nil
                                                        error:nil];
        self.lastReadReceiptTime = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isWaitSendReadReceipt = NO;
            if (self.lastReadReceiptTime > 0) {
                [self delaySendReadReceiptMessage];
            }
        });
    }
}

//数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
//用户可以手动下拉更多消息，查看更多历史消息。
- (void)clearOldestMessagesWhenMemoryWarning {
    if (self.conversationDataRepository.count > COLLECTION_VIEW_CELL_MAX_COUNT) {
        NSArray *array = [self.conversationMessageCollectionView indexPathsForVisibleItems];
        if (array.count > 0) {
            NSIndexPath *indexPath = array.firstObject;
            //当前可见的 cell 是否在即将清理的 200
            //条数据源内，如果在，用户可能正在拉取历史消息，或者查看历史消息，暂不清理，判断大于300，预留100个数据缓冲，避免用户感觉突兀
            if (indexPath.row > 300) {
                NSRange range = NSMakeRange(0, COLLECTION_VIEW_CELL_REMOVE_COUNT);
                [self.conversationDataRepository removeObjectsInRange:range];
                [self.conversationMessageCollectionView reloadData];
            }
        } else {
            //聊天页面生命周期未结束但是又不在当前展示页面，直接清理
            NSRange range = NSMakeRange(0, COLLECTION_VIEW_CELL_REMOVE_COUNT);
            [self.conversationDataRepository removeObjectsInRange:range];
            [self.conversationMessageCollectionView reloadData];
        }
    }
}

- (void)didSendingMessageNotification:(NSNotification *)notification {
    RCMessage *rcMessage = notification.object;
    NSDictionary *statusDic = notification.userInfo;

    if (rcMessage) {
        // 插入消息
        if (rcMessage.conversationType == self.conversationType && [rcMessage.targetId isEqual:self.targetId]) {
            [self updateForMessageSendOut:rcMessage];
        }
    } else if (statusDic) {
        // 更新消息状态
        NSNumber *conversationType = statusDic[@"conversationType"];
        NSString *targetId = statusDic[@"targetId"];
        if (conversationType.intValue == self.conversationType && [targetId isEqual:self.targetId]) {
            NSNumber *messageId = statusDic[@"messageId"];
            NSNumber *sentStatus = statusDic[@"sentStatus"];
            if (sentStatus.intValue == SentStatus_SENDING) {
                NSNumber *progress = statusDic[@"progress"];
                [self updateForMessageSendProgress:progress.intValue messageId:messageId.longValue];
            } else if (sentStatus.intValue == SentStatus_SENT) {
                RCMessageContent *content = statusDic[@"content"];
                [self updateForMessageSendSuccess:messageId.longValue content:content];
            } else if (sentStatus.intValue == SentStatus_FAILED) {
                NSNumber *errorCode = statusDic[@"error"];
                RCMessageContent *content = statusDic[@"content"];
                [self updateForMessageSendError:errorCode.intValue messageId:messageId.longValue content:content];
            } else if (sentStatus.intValue == SentStatus_CANCELED) {
                RCMessageContent *content = statusDic[@"content"];
                [self updateForMessageSendCanceled:messageId.longValue content:content];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)message {
    DebugLog(@"super %s", __FUNCTION__);
    return message;
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message {
    DebugLog(@"super %s", __FUNCTION__);
    return message;
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent {
    DebugLog(@"super %s, %@", __FUNCTION__, messageContent);
}

- (void)didCancelMessage:(RCMessageContent *)messageContent {
    DebugLog(@"super %s, %@", __FUNCTION__, messageContent);
}

- (BOOL)willSelectMessage:(RCMessageModel *)model {
    DebugLog(@"super %s, %@", __FUNCTION__, model);
    return YES;
}

- (BOOL)willCancelSelectMessage:(RCMessageModel *)model {
    DebugLog(@"super %s, %@", __FUNCTION__, model);
    return YES;
}

#pragma mark <RCChatSessionInputBarControlDataSource>

- (void)getSelectingUserIdList:(void (^)(NSArray<NSString *> *userIdList))completion
                   functionTag:(NSInteger)functionTag {
    switch (functionTag) {
    case INPUT_MENTIONED_SELECT_TAG: {
        if (self.conversationType == ConversationType_DISCUSSION) {
            [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
                success:^(RCDiscussion *discussion) {
                    if (completion) {
                        completion(discussion.memberIdList);
                    }
                }
                error:^(RCErrorCode status) {
                    if (completion) {
                        completion(nil);
                    }
                }];
        } else if (self.conversationType == ConversationType_GROUP) {
            if ([[RCIM sharedRCIM].groupMemberDataSource respondsToSelector:@selector(getAllMembersOfGroup:result:)]) {
                [[RCIM sharedRCIM]
                        .groupMemberDataSource getAllMembersOfGroup:self.targetId
                                                             result:^(NSArray<NSString *> *userIdList) {
                                                                 if (completion) {
                                                                     completion(userIdList);
                                                                 }
                                                             }];
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        }
    } break;
    default: {
        if (completion) {
            completion(nil);
        }

    } break;
    }
}

- (RCUserInfo *)getSelectingUserInfo:(NSString *)userId {
    if (self.conversationType == ConversationType_GROUP) {
        return [[RCUserInfoCacheManager sharedManager] getUserInfo:userId inGroupId:self.targetId];
    } else {
        return [[RCUserInfoCacheManager sharedManager] getUserInfo:userId];
    }
}

#pragma mark <RCChatSessionInputBarControlDelegate>

- (void)chatInputBar:(RCChatSessionInputBarControl *)chatInputBar shouldChangeFrame:(CGRect)frame {
    if ([self updateReferenceViewFrame]) {
        return;
    }
    CGRect collectionViewRect = self.conversationMessageCollectionView.frame;
    collectionViewRect.size.height = CGRectGetMinY(frame) - collectionViewRect.origin.y;
    if (!chatInputBar.hidden) {
        [self.conversationMessageCollectionView setFrame:collectionViewRect];
    }
    [self.unreadRightBottomIcon setFrame:CGRectMake(self.view.frame.size.width - 5.5 - 35,
                                                    self.chatSessionInputBarControl.frame.origin.y - 12 - 35, 35, 35)];
    if (self.locatedMessageSentTime == 0 || self.isConversationAppear) {
        //在viewwillapear和viewdidload之前，如果强制定位，则不滑动到底部
        if (self.isLoadingHistoryMessage || [self isRemainMessageExisted]) {
            [self loadRemainMessageAndScrollToBottom:YES];
        } else {
            [self scrollToBottomAnimated:NO];
        }
    }
}

- (void)inputTextViewDidTouchSendKey:(UITextView *)inputTextView {
    if ([self sendReferenceMessage:inputTextView.text]) {
        return;
    }
    RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:inputTextView.text];
    rcTextMessage.mentionedInfo = self.chatSessionInputBarControl.mentionedInfo;
    if (self.chatSessionInputBarControl.burnMessageMode) {
        NSInteger duration;
        if (inputTextView.text.length <= 20) {
            duration = DefaultMessageBurnDuration;
        } else {
            duration = DefaultMessageBurnDuration + (inputTextView.text.length - 20) / 2;
        }
        rcTextMessage.destructDuration = duration;
    }
    [self sendMessage:rcTextMessage pushContent:nil];
}

- (void)inputTextView:(UITextView *)inputTextView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
    if ([RCIM sharedRCIM].enableTypingStatus && ![text isEqualToString:@"\n"]) {
        [[RCIMClient sharedRCIMClient] sendTypingStatus:self.conversationType
                                               targetId:self.targetId
                                            contentType:[RCTextMessage getObjectName]];
    }
}

- (void)setChatSessionInputBarStatus:(KBottomBarStatus)inputBarStatus animated:(BOOL)animated {
    [self.chatSessionInputBarControl updateStatus:inputBarStatus animated:animated];
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
    switch (tag) {
    case PLUGIN_BOARD_ITEM_ALBUM_TAG: {
        [self openSystemAlbum];
    } break;
    case PLUGIN_BOARD_ITEM_CAMERA_TAG: {
        [self openSystemCamera];
    } break;
    case PLUGIN_BOARD_ITEM_LOCATION_TAG: {
        [self openLocationPicker];
    } break;
    case PLUGIN_BOARD_ITEM_BURN_TAG: {
        [self switchBurnMessageModel];
    } break;
    case PLUGIN_BOARD_ITEM_FILE_TAG: {
        [self openFileSelector];
    } break;
    case PLUGIN_BOARD_ITEM_EVA_TAG: {
        [self commentCustomerServiceWithStatus:self.currentServiceStatus commentId:nil quitAfterComment:NO];
    } break;
    case PLUGIN_BOARD_ITEM_VOICE_INPUT_TAG: {
        if ([[RCExtensionService sharedService] isAudioHolding]) {
            NSString *alertMessage = NSLocalizedStringFromTable(@"AudioHoldingWarning", @"RongCloudKit", nil);
            [self showAlertController:alertMessage];
        } else {
            [self openDynamicFunction:tag];
        }
    } break;
    default: { [self openDynamicFunction:tag]; } break;
    }
}

- (void)presentViewController:(UIViewController *)viewController functionTag:(NSInteger)functionTag {
    switch (functionTag) {
    case PLUGIN_BOARD_ITEM_ALBUM_TAG:
    case PLUGIN_BOARD_ITEM_CAMERA_TAG:
    case PLUGIN_BOARD_ITEM_LOCATION_TAG:
    case PLUGIN_BOARD_ITEM_FILE_TAG:
    case INPUT_MENTIONED_SELECT_TAG: {
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:viewController animated:YES completion:nil];
    } break;
    default: { } break; }
}

- (void)openSystemAlbum {
    [self.chatSessionInputBarControl openSystemAlbum];
}

- (void)openSystemCamera {
    [self.chatSessionInputBarControl openSystemCamera];
}

- (void)openLocationPicker {
    [self.chatSessionInputBarControl openLocationPicker];
}

- (void)switchBurnMessageModel {
    if (self.chatSessionInputBarControl.burnMessageMode) {
        [self.chatSessionInputBarControl endBurnMsgMode];
    } else {
        [self alertBurnMessageRemind];
        [self.chatSessionInputBarControl beginBurnMsgMode];
    }
}

- (BOOL)alertBurnMessageRemind {
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"FirstTimeBeginBurnMode"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"FirstTimeBeginBurnMode"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = NSLocalizedStringFromTable(@"BurnAfterReadTitle", @"RongCloudKit", nil);
            NSString *msg = NSLocalizedStringFromTable(@"BurnAfterReadMsg", @"RongCloudKit", nil);
            NSString *ok = NSLocalizedStringFromTable(@"Know", @"RongCloudKit", nil);
            UIAlertController *alertController =
                [UIAlertController alertControllerWithTitle:title
                                                    message:msg
                                             preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:ok
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *_Nonnull action){
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
        });
        return YES;
    }
    return NO;
}

- (void)openFileSelector {
    [self.chatSessionInputBarControl openFileSelector];
}

- (void)openDynamicFunction:(NSInteger)functionTag {
    [self.chatSessionInputBarControl openDynamicFunction:functionTag];
}

- (void)emojiView:(RCEmojiBoardView *)emojiView didTouchedEmoji:(NSString *)touchedEmoji {

    if ([RCIM sharedRCIM].enableTypingStatus) {
        [[RCIMClient sharedRCIMClient] sendTypingStatus:self.conversationType
                                               targetId:self.targetId
                                            contentType:[RCTextMessage getObjectName]];
    }
}

- (void)emojiView:(RCEmojiBoardView *)emojiView didTouchSendButton:(UIButton *)sendButton {
    if ([self sendReferenceMessage:self.chatSessionInputBarControl.inputTextView.text]) {
        return;
    }
    RCTextMessage *rcTextMessage =
        [RCTextMessage messageWithContent:self.chatSessionInputBarControl.inputTextView.text];
    rcTextMessage.mentionedInfo = self.chatSessionInputBarControl.mentionedInfo;

    [self sendMessage:rcTextMessage pushContent:nil];
}

//点击常用语的回调
- (void)commonPhrasesViewDidTouch:(NSString *)commonPhrases {
    RCTextMessage *rcTextMessage = [RCTextMessage messageWithContent:commonPhrases];
    [self sendMessage:rcTextMessage pushContent:nil];
}

//语音消息开始录音
- (void)recordDidBegin {
    if ([RCIM sharedRCIM].enableTypingStatus) {
        [[RCIMClient sharedRCIMClient] sendTypingStatus:self.conversationType
                                               targetId:self.targetId
                                            contentType:[RCVoiceMessage getObjectName]];
    }

    [self onBeginRecordEvent];
}

//语音消息录音结束
- (void)recordDidEnd:(NSData *)recordData duration:(long)duration error:(NSError *)error {
    if (error == nil) {
        if (self.conversationType == ConversationType_CUSTOMERSERVICE ||
            [RCIMClient sharedRCIMClient].voiceMsgType == RCVoiceMessageTypeOrdinary) {
            RCVoiceMessage *voiceMessage = [RCVoiceMessage messageWithAudio:recordData duration:duration];
            if (self.chatSessionInputBarControl.burnMessageMode) {
                voiceMessage.destructDuration = DefaultMessageBurnDuration;
            }
            if (self.chatSessionInputBarControl.burnMessageMode) {
                voiceMessage.destructDuration = DefaultMessageBurnDuration;
            }
            [self sendMessage:voiceMessage pushContent:nil];
        } else if ([RCIMClient sharedRCIMClient].voiceMsgType == RCVoiceMessageTypeHighQuality) {
            long long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *path = [RCUtilities rongImageCacheDirectory];
            path = [path
                stringByAppendingFormat:@"/%@/RCHQVoiceCache", [RCIMClient sharedRCIMClient].currentUserInfo.userId];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO) {
                [[NSFileManager defaultManager] createDirectoryAtPath:path
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:nil];
            }
            NSString *fileName = [NSString stringWithFormat:@"/Voice_%@.m4a", @(currentTime)];
            path = [path stringByAppendingPathComponent:fileName];
            [recordData writeToFile:path atomically:YES];
            RCHQVoiceMessage *hqVoiceMsg = [RCHQVoiceMessage messageWithPath:path duration:duration];
            if (self.chatSessionInputBarControl.burnMessageMode) {
                hqVoiceMsg.destructDuration = DefaultMessageBurnDuration;
            }
            [self sendMessage:hqVoiceMsg pushContent:nil];
        }
    }

    [self onEndRecordEvent];
}

//语音消息开始录音
- (void)recordDidCancel {
    [self onCancelRecordEvent];
}

//接口向后兼容[[++
- (void)onBeginRecordEvent {
}

- (void)onEndRecordEvent {
}

- (void)onCancelRecordEvent {
}
//接口向后兼容--]]

- (void)fileDidSelect:(NSArray *)filePathList {
    [self becomeFirstResponder];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *filePath in filePathList) {
            RCFileMessage *fileMessage = [RCFileMessage messageWithFile:filePath];
            [self sendMessage:fileMessage pushContent:nil];
            [NSThread sleepForTimeInterval:0.5];
        }
    });
}

- (void)imageDataDidSelect:(NSArray *)selectedImages fullImageRequired:(BOOL)full {
    [self becomeFirstResponder];
    _isTakeNewPhoto = NO;
    //耗时操作异步执行，以免阻塞主线程
    __weak RCConversationViewController *weakSelf = self;
    __block BOOL isBurnMode = self.chatSessionInputBarControl.burnMessageMode;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < selectedImages.count; i++) {
            @autoreleasepool {
                id item = [selectedImages objectAtIndex:i];
                if ([item isKindOfClass:NSData.class]) {
                    NSData *imageData = (NSData *)item;
                    UIImage *image = [UIImage imageWithData:imageData];
                    image = [RCKitUtility fixOrientation:image];
                    // 保留原有逻辑并添加大图缩小的功能
                    [[RCloudMediaManager sharedManager] downsizeImage:image
                        completionBlock:^(UIImage *outimage, BOOL doNothing) {
                            RCImageMessage *imagemsg;
                            if (doNothing || !outimage) {
                                imagemsg = [RCImageMessage messageWithImage:image];
                                imagemsg.full = full;
                            } else if (outimage) {
                                NSData *newImageData = UIImageJPEGRepresentation(outimage, 1);
                                imagemsg = [RCImageMessage messageWithImageData:newImageData];
                                imagemsg.full = full;
                            }
                            if (isBurnMode) {
                                imagemsg.destructDuration = ImageMessageBurnDuration;
                            }
                            [weakSelf sendMessage:imagemsg pushContent:nil];
                        }
                        progressBlock:^(UIImage *outimage, BOOL doNothing){

                        }];
                } else if ([item isKindOfClass:NSDictionary.class]) {
                    NSDictionary *assertInfo = item;
                    if ([assertInfo objectForKey:@"avAsset"]) {
                        AVAsset *model = assertInfo[@"avAsset"];
                        UIImage *image = assertInfo[@"thumbnail"];
                        NSString *localPath = assertInfo[@"localPath"];
                        if (![localPath isKindOfClass:[NSString class]] || ![localPath containsString:@"APPLE/"]) {
                            localPath = @"";
                        }
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            NSUInteger duration = round(CMTimeGetSeconds(model.duration));
                            RCSightMessage *sightMsg =
                                [RCSightMessage messageWithAsset:model thumbnail:image duration:duration];
                            sightMsg.localPath = localPath;
                            if (isBurnMode) {
                                sightMsg.destructDuration = DefaultMessageBurnDuration;
                            }
                            [weakSelf sendMessage:sightMsg pushContent:nil];
                        });
                    } else {
                        NSData *gifImageData = (NSData *)[assertInfo objectForKey:@"imageData"];
                        RCGIFImage *gifImage = [RCGIFImage animatedImageWithGIFData:gifImageData];
                        if (gifImage) {
                            RCGIFMessage *gifMsg = [RCGIFMessage messageWithGIFImageData:gifImageData
                                                                                   width:gifImage.size.width
                                                                                  height:gifImage.size.height];
                            if (isBurnMode) {
                                gifMsg.destructDuration = ImageMessageBurnDuration;
                            }
                            [weakSelf sendMessage:gifMsg pushContent:nil];
                        }
                    }
                }
                [NSThread sleepForTimeInterval:0.5];
            }
        }
    });
}

//- (void)imageDidSelect:(NSArray *)selectedImages fullImageRequired:(BOOL)full {
//    [self becomeFirstResponder];
//    _isTakeNewPhoto = NO;
//    //耗时操作异步执行，以免阻塞主线程
//    __weak RCConversationViewController *weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (int i = 0; i < selectedImages.count; i++) {
//            UIImage *image = [selectedImages objectAtIndex:i];
//            RCImageMessage *imagemsg = [RCImageMessage messageWithImage:image];
//            imagemsg.full = full;
//            [weakSelf sendMessage:imagemsg pushContent:nil];
//            [NSThread sleepForTimeInterval:0.5];
//        }
//    });
//}

- (void)locationDidSelect:(CLLocationCoordinate2D)location
             locationName:(NSString *)locationName
            mapScreenShot:(UIImage *)mapScreenShot {
    [self becomeFirstResponder];
    RCLocationMessage *locationMessage =
        [RCLocationMessage messageWithLocationImage:mapScreenShot location:location locationName:locationName];
    [self sendMessage:locationMessage pushContent:nil];
}

//选择相册图片或者拍照回调
- (void)imageDidCapture:(UIImage *)image {
    [self becomeFirstResponder];
    image = [RCKitUtility fixOrientation:image];
    RCImageMessage *imageMessage = [RCImageMessage messageWithImage:image];
    _isTakeNewPhoto = YES;
    if (self.chatSessionInputBarControl.burnMessageMode) {
        imageMessage.destructDuration = ImageMessageBurnDuration;
    }
    [self sendMessage:imageMessage pushContent:nil];
}

- (void)sightDidFinishRecord:(NSString *)url thumbnail:(UIImage *)image duration:(NSUInteger)duration {
    RCSightMessage *sightMessage = [RCSightMessage messageWithLocalPath:url thumbnail:image duration:duration];
    if (self.chatSessionInputBarControl.burnMessageMode) {
        sightMessage.destructDuration = DefaultMessageBurnDuration;
    }
    [self sendMessage:sightMessage pushContent:nil];
}

- (void)sendTypingStatusTimerFired {
    isCanSendTypingMessage = YES;
}

- (void)tabRightBottomMsgCountIcon:(UIGestureRecognizer *)gesture {
    [self.unreadNewMsgArr removeAllObjects];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSInteger count = 0;
        if (self.isLoadingHistoryMessage) {
            count = [self appendLastestMessageToDataSource];
            NSInteger totalcount = self.conversationDataRepository.count;
            /// 0.35 的作用时在滚动动画完成后执行 滚动动画的执行时间大约是0.35
            dispatch_after(
                dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.conversationDataRepository removeObjectsInRange:NSMakeRange(0, totalcount - count)];
                    [self.conversationMessageCollectionView reloadData];
                });
        }
        [self scrollToBottomAnimated:YES];
    }
    self.isLoadingHistoryMessage = NO;
}

- (void)tap4ResetDefaultBottomBarStatus:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarDefaultStatus &&
            self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarRecordStatus) {
            [self.chatSessionInputBarControl resetToDefaultStatus];
        }
    }
}

/**
 *  复制
 *
 *  @param sender
 */
- (void)onCopyMessage:(id)sender {
    // self.msgInputBar.msgColumnTextView.disableActionMenu = NO;
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    // RCMessageCell* cell = _RCMessageCell;
    //判断是否文本消息
    if ([_longPressSelectedModel.content isKindOfClass:[RCTextMessage class]]) {
        RCTextMessage *text = (RCTextMessage *)_longPressSelectedModel.content;
        [pasteboard setString:text.content];
    } else if ([_longPressSelectedModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *refer = (RCReferenceMessage *)_longPressSelectedModel.content;
        [pasteboard setString:refer.content];
    }
}
/**
 *  删除
 *
 *  @param sender
 */
- (void)onDeleteMessage:(id)sender {
    // self.msgInputBar.msgColumnTextView.disableActionMenu = NO;
    self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
    // RCMessageCell* cell = _RCMessageCell;
    RCMessageModel *model = _longPressSelectedModel;
    // RCMessageContent *content = _longPressSelectedModel.content;

    //删除消息时如果是当前播放的消息就停止播放
    if ([RCVoicePlayer defaultPlayer].isPlaying && [RCVoicePlayer defaultPlayer].messageId == model.messageId) {
        [[RCVoicePlayer defaultPlayer] stopPlayVoice];
    }
    [self deleteMessage:model];
}
- (void)reloadRecalledMessage:(long)recalledMsgId {
    int index = -1;
    RCMessageModel *msgModel;
    for (int i = 0; i < self.conversationDataRepository.count; i++) {
        msgModel = [self.conversationDataRepository objectAtIndex:i];
        if (msgModel.messageId == recalledMsgId &&
            ![msgModel.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
            index = i;
            break;
        }
    }
    if (index >= 0) {
        NSIndexPath *indexPath = [self findDataIndexFromMessageList:msgModel];
        if (!indexPath) {
            return;
        }
        [self.conversationDataRepository removeObject:msgModel];
        RCMessage *newMsg = [[RCIMClient sharedRCIMClient] getMessage:recalledMsgId];
        if (newMsg) {
            RCMessageModel *newModel = [RCMessageModel modelWithMessage:newMsg];
            newModel.isDisplayMessageTime = msgModel.isDisplayMessageTime;
            newModel.isDisplayNickname = msgModel.isDisplayNickname;
            [self.conversationDataRepository insertObject:newModel atIndex:index];
            [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
        } else {
            [self.conversationMessageCollectionView deleteItemsAtIndexPaths:@[ indexPath ]];
        }
    }

    if (self.referencingView && self.referencingView.referModel.messageId == recalledMsgId) {
        [self dismissReferencingView:self.referencingView];
    }
}
/**
 *  撤回消息
 *
 *  @param sender
 */
- (void)onRecallMessage:(id)sender {
    if ([self canRecallMessageOfModel:_longPressSelectedModel]) {
        self.chatSessionInputBarControl.inputTextView.disableActionMenu = NO;
        RCMessageModel *model = _longPressSelectedModel;
        [self recallMessage:model.messageId];
    } else {
        UIAlertController *alertController = [UIAlertController
            alertControllerWithTitle:nil
                             message:NSLocalizedStringFromTable(@"CanNotRecall", @"RongCloudKit", nil)
                      preferredStyle:UIAlertControllerStyleAlert];
        [alertController
            addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction *_Nonnull action){
                                             }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
/**
 *  此方法是为了解决 5s及其以下设备 RCRecallMessageImageView 撤回消息时hud盖住键盘的问题
 *  解决方法为获取最高 windowLevel 的 window 将 RCRecallMessageImageView 添加到获取到的 window 上
 */
- (UIWindow *)geyKeybordWindow {
    __block UIWindow *keybordWindow = [UIApplication sharedApplication].keyWindow;
    __block CGFloat windowMaxValue = keybordWindow.windowLevel;
    [[UIApplication sharedApplication]
            .windows
        enumerateObjectsUsingBlock:^(__kindof UIWindow *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.windowLevel > windowMaxValue) {
                keybordWindow = obj;
                windowMaxValue = obj.windowLevel;
            }
        }];
    return keybordWindow;
}
- (void)recallMessage:(long)messageId {
    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
    if (msg.messageDirection != MessageDirection_SEND && msg.sentStatus != SentStatus_SENT) {
        NSLog(@"错误，只有发送成功的消息才能撤回！！！");
        return;
    }
    //将 self.rcImageProressView 添加到优先级最高的 window 上,避免键盘被遮挡
    [[self geyKeybordWindow] addSubview:self.rcImageProressView];
    [self.rcImageProressView setCenter:CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2)];
    [self.rcImageProressView startAnimating];
    __weak typeof(self) ws = self;
    [[RCIMClient sharedRCIMClient] recallMessage:msg
        pushContent:nil
        success:^(long messageId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([RCVoicePlayer defaultPlayer].isPlaying &&
                    [RCVoicePlayer defaultPlayer].messageId == msg.messageId) {
                    [[RCVoicePlayer defaultPlayer] stopPlayVoice];
                }

                [ws reloadRecalledMessage:messageId];

                [ws.rcImageProressView stopAnimating];
                [ws.rcImageProressView removeFromSuperview];
                // private method
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RCEConversationUpdateNotification"
                                                                    object:nil];
            });
        }
        error:^(RCErrorCode errorcode) {
            dispatch_async(dispatch_get_main_queue(), ^{

                [ws.rcImageProressView stopAnimating];
                [ws.rcImageProressView removeFromSuperview];

                NSString *errorMsg = NSLocalizedStringFromTable(@"MessageRecallFailed", @"RongCloudKit", nil);
                NSString *Ok = NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil);
                UIAlertController *alertController =
                    [UIAlertController alertControllerWithTitle:nil
                                                        message:errorMsg
                                                 preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:Ok
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *_Nonnull action){
                                                                  }]];
                [self presentViewController:alertController animated:YES completion:nil];

            });
        }];
}

- (void)deleteMessage:(RCMessageModel *)model {
    if (self.conversationDataRepository.count == 0) {
        return;
    }
    long msgId = model.messageId;
    NSIndexPath *indexPath = [self findDataIndexFromMessageList:model];
    if (!indexPath) {
        return;
    }
    [[RCIMClient sharedRCIMClient] deleteMessages:@[ @(msgId) ]];
    [self.conversationDataRepository removeObjectAtIndex:indexPath.item];
    [self.conversationMessageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    //如果“以上是历史消息(RCOldMessageNotificationMessage)”上面或者下面没有消息了，把RCOldMessageNotificationMessage也删除
    if (self.conversationDataRepository.count > 0) {
        RCMessageModel *lastOldModel = self.conversationDataRepository[0];
        RCMessageModel *lastNewModel = self.conversationDataRepository[self.conversationDataRepository.count - 1];

        if ([lastOldModel.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.conversationDataRepository removeObject:lastOldModel];
            [self.conversationMessageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

            //删除“以上是历史消息”之后，会话的第一条消息显示时间，并且调整高度
            RCMessageModel *topMsg = (self.conversationDataRepository)[0];
            topMsg.isDisplayMessageTime = YES;
            topMsg.cellSize = CGSizeMake(topMsg.cellSize.width, topMsg.cellSize.height + 30);
            RCMessageCell *__cell = (RCMessageCell *)[self.conversationMessageCollectionView
                cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            if (__cell) {
                [__cell setDataModel:topMsg];
            }
            [self.conversationMessageCollectionView reloadData];
        }
        if ([lastNewModel.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
            NSIndexPath *indexPath =
                [NSIndexPath indexPathForRow:self.conversationDataRepository.count - 1 inSection:0];
            [self.conversationDataRepository removeObject:lastNewModel];
            [self.conversationMessageCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
    }
}

- (void)notifyUnReadMessageCount:(NSInteger)count {
}

/**
 *  设置头像样式
 *
 *  @param avatarStyle avatarStyle
 */
- (void)setMessageAvatarStyle:(RCUserAvatarStyle)avatarStyle {
    [RCIM sharedRCIM].globalMessageAvatarStyle = avatarStyle;
}
/**
 *  设置头像大小
 *
 *  @param size size
 */
- (void)setMessagePortraitSize:(CGSize)size {
    [RCIM sharedRCIM].globalMessagePortraitSize = size;
}

- (void)notifyUpdateUnreadMessageCount {
    //如果消息是选择状态，不更新leftBar
    if (self.allowsMessageCellSelection) {
        __weak typeof(self) __weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __weakself.rightBarButtonItems = __weakself.navigationItem.rightBarButtonItems;
            __weakself.leftBarButtonItems = __weakself.navigationItem.leftBarButtonItems;
            __weakself.navigationItem.rightBarButtonItems = nil;
            __weakself.navigationItem.leftBarButtonItems = nil;
            UIBarButtonItem *left =
                [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(onCancelMultiSelectEvent:)];

            [left setTintColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
            self.navigationItem.leftBarButtonItem = left;
        });
    } else {
        __weak typeof(self) __weakself = self;
        int count = 0;
        if (self.displayConversationTypeArray) {
            count = [[RCIMClient sharedRCIMClient] getUnreadCount:self.displayConversationTypeArray];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                __weakself.navigationItem.leftBarButtonItems = __weakself.leftBarButtonItems;
                __weakself.leftBarButtonItems = nil;
                if (__weakself.conversationType != ConversationType_Encrypted && __weakself.rightBarButtonItems) {
                    __weakself.navigationItem.rightBarButtonItems = __weakself.rightBarButtonItems;
                    __weakself.rightBarButtonItems = nil;
                }
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *backString = nil;
            if (count > 0 && count < 1000) {
                backString = [NSString
                    stringWithFormat:@"%@(%d)", NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil), count];
            } else if (count >= 1000) {
                backString =
                    [NSString stringWithFormat:@"%@(...)", NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil)];
            } else {
                backString = NSLocalizedStringFromTable(@"Back", @"RongCloudKit", nil);
            }

            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(0, 6, 72, 23);
            CGFloat originY = 0;
            if (RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0")) {
                originY = 5;
            }
            UIImageView *backImg = [[UIImageView alloc] initWithImage:IMAGE_BY_NAMED(@"navigator_btn_back")];
            backImg.frame = CGRectMake(-8, originY, 15, 22);
            [backBtn addSubview:backImg];
            UILabel *backText = [[UILabel alloc] initWithFrame:CGRectMake(12, originY, 70, 22)];
            backText.text = backString;
            backText.font = [UIFont systemFontOfSize:15];
            [backText setBackgroundColor:[UIColor clearColor]];
            [backText setTextColor:[RCIM sharedRCIM].globalNavigationBarTintColor];
            [backBtn addSubview:backText];
            if (__weakself.conversationType == ConversationType_CUSTOMERSERVICE) {
                [backBtn addTarget:__weakself
                              action:@selector(customerServiceLeftCurrentViewController)
                    forControlEvents:UIControlEventTouchUpInside];
            } else {
                [backBtn addTarget:__weakself
                              action:@selector(leftBarButtonItemPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
            }

            UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
            [__weakself.navigationItem setLeftBarButtonItem:leftButton];
            __weakself.leftBarButtonItems = nil;
            if (__weakself.rightBarButtonItems) {
                __weakself.navigationItem.rightBarButtonItems = __weakself.rightBarButtonItems;
                __weakself.rightBarButtonItems = nil;
            }
        });
    }
}

- (void)saveNewPhotoToLocalSystemAfterSendingSuccess:(UIImage *)newImage {
}

- (BOOL)isAtTheBottomOfTableView {
    if (self.isLoadingHistoryMessage)
        return NO;
    if (self.conversationMessageCollectionView.contentSize.height <=
        self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }

    if (self.conversationMessageCollectionView.contentOffset.y + 200 >=
        (self.conversationMessageCollectionView.contentSize.height -
         self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    } else {
        return NO;
    }
}

//修复ios7下不断下拉加载历史消息偶尔崩溃的bug
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)receiveContinuousPlayNotification:(NSNotification *)notification {
    if (self.enableContinuousReadUnreadVoice) {
        if (!self.isContinuousPlaying) {
            return;
        }
        long messageId = [notification.object longValue];
        RCConversationType conversationType = [notification.userInfo[@"conversationType"] longValue];
        NSString *targetId = notification.userInfo[@"targetId"];
        RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:messageId];
        if (messageId > 0 && conversationType == self.conversationType && [targetId isEqualToString:self.targetId] &&
            msg.content.destructDuration == 0) {

            [self performSelector:@selector(playNextVoiceMesage:)
                       withObject:@(messageId)
                       afterDelay:0.3f]; //延时0.3秒播放
        }
    }
}

- (void)playNextVoiceMesage:(NSNumber *)msgId {
    dispatch_async(dispatch_get_main_queue(), ^{
        long messageId = [msgId longValue];
        RCMessageModel *rcMsg;
        int index = 0;
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            rcMsg = [self.conversationDataRepository objectAtIndex:i];
            if (messageId < rcMsg.messageId && ([rcMsg.content isMemberOfClass:[RCVoiceMessage class]] ||
                                                [rcMsg.content isMemberOfClass:[RCHQVoiceMessage class]]) &&
                rcMsg.receivedStatus != ReceivedStatus_LISTENED && rcMsg.messageDirection == MessageDirection_RECEIVE &&
                rcMsg.content.destructDuration == 0) {
                index = i;
                break;
            }
        }
        if (index == self.conversationDataRepository.count - 1) {
            self.isContinuousPlaying = NO;
        }

        if (index != 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            RCVoiceMessageCell *__cell =
                (RCVoiceMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
            //如果是空说明被回收了，重新dequeue一个cell
            if (__cell) {
                rcMsg.receivedStatus = ReceivedStatus_LISTENED;
                [__cell setDataModel:rcMsg];
                [__cell playVoice];
            } else {
                if ([rcMsg.content isKindOfClass:RCVoiceMessage.class]) {
                    __cell = (RCVoiceMessageCell *)[self.conversationMessageCollectionView
                        dequeueReusableCellWithReuseIdentifier:[[RCVoiceMessage class] getObjectName]
                                                  forIndexPath:indexPath];
                    rcMsg.receivedStatus = ReceivedStatus_LISTENED;
                } else if ([rcMsg.content isKindOfClass:RCHQVoiceMessage.class]) {
                    __cell = [self.conversationMessageCollectionView
                        dequeueReusableCellWithReuseIdentifier:[[RCHQVoiceMessage class] getObjectName]
                                                  forIndexPath:indexPath];
                    if (((RCHQVoiceMessage *)rcMsg.content).localPath.length > 0) {
                        rcMsg.receivedStatus = ReceivedStatus_LISTENED;
                    }
                }
                [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
                [__cell setDataModel:rcMsg];
                [__cell setDelegate:self];
                [__cell playVoice];
            }
        }
    });
}

- (void)onPublicServiceMenuItemSelected:(RCPublicServiceMenuItem *)selectedMenuItem {
    if (selectedMenuItem.type == RC_PUBLIC_SERVICE_MENU_ITEM_VIEW) {
        [RCKitUtility openURLInSafariViewOrWebView:selectedMenuItem.url base:self];
    }
    /// VIEW  要不要发消息
    RCPublicServiceCommandMessage *command = [RCPublicServiceCommandMessage messageFromMenuItem:selectedMenuItem];
    if (command) {
        [[RCIMClient sharedRCIMClient] sendMessage:self.conversationType
            targetId:self.targetId
            content:command
            pushContent:nil
            pushData:nil
            success:^(long messageId) {

            }
            error:^(RCErrorCode nErrorCode, long messageId){

            }];
    }
}

- (void)didTapUrlInPublicServiceMessageCell:(NSString *)url model:(RCMessageModel *)model {
    UIViewController *viewController = nil;
    url = [RCKitUtility checkOrAppendHttpForUrl:url];
    if (![RCIM sharedRCIM].embeddedWebViewPreferred && RC_IOS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        viewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
    } else {
        viewController = [[RCIMClient sharedRCIMClient] getPublicServiceWebViewController:url];
        [viewController setValue:[RCIM sharedRCIM].globalNavigationBarTintColor forKey:@"backButtonTextColor"];
    }
    [self didTapImageTxtMsgCell:url webViewController:viewController];
}
- (void)didLongTouchPublicServiceMessageCell:(RCMessageModel *)model inView:(UIView *)view {
    [self didLongTouchMessageCell:model inView:view];
}
#pragma mark override
- (void)didTapImageTxtMsgCell:(NSString *)tapedUrl webViewController:(UIViewController *)rcWebViewController {
    rcWebViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if ([rcWebViewController isKindOfClass:[SFSafariViewController class]]) {
        [self presentViewController:rcWebViewController animated:YES completion:nil];
    } else {
        UIWindow *window = [RCKitUtility getKeyWindow];
        UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
        [navigationController pushViewController:rcWebViewController animated:YES];
    }
}

- (void)resetBottomBarStatus {
    [self.chatSessionInputBarControl resetToDefaultStatus];
}

/****************** Custom Service Code Begin ******************/
- (void)robotSwitchButtonDidTouch {
    if (self.conversationType == ConversationType_CUSTOMERSERVICE) {
        [[RCIMClient sharedRCIMClient] switchToHumanMode:self.targetId];
        [self startNotSendMessageAlertTimer];
        [self startNotReciveMessageAlertTimer];
    }
}

- (void)switchRobotInputType:(BOOL)isRobotType {
    if (isRobotType) {
        [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlCSRobotType
                                                   style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];
    } else {
        [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                   style:RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION];
    }
}

- (void)didTapCustomerService:(RCMessageModel *)model RobotResoluved:(BOOL)isResolved {
    RCCustomerServiceMessageModel *csModel = (RCCustomerServiceMessageModel *)model;
    csModel.alreadyEvaluated = YES;
    [[RCIMClient sharedRCIMClient] evaluateCustomerService:model.targetId
                                              knownledgeId:csModel.evaluateId
                                                robotValue:YES
                                                   suggest:nil];
    NSUInteger index = [self.conversationDataRepository indexOfObject:model];
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.conversationMessageCollectionView reloadItemsAtIndexPaths:@[ path ]];
}

- (void)suspendCustomerService {
    [[RCIMClient sharedRCIMClient] stopCustomerService:self.targetId];
}

- (void)leftCustomerServiceWithEvaluate:(BOOL)needEvaluate {
    if (needEvaluate) {
        if ([self.csEnterDate timeIntervalSinceNow] >= -(self.csEvaInterval)) {
            needEvaluate = NO;
        }
        if (self.currentServiceStatus == RCCustomerService_RobotService && self.csConfig.robotSessionNoEva) {
            needEvaluate = NO;
        } else if (self.currentServiceStatus == RCCustomerService_HumanService && self.csConfig.humanSessionNoEva) {
            needEvaluate = NO;
        }

        if (self.humanEvaluated) {
            needEvaluate = NO;
        }
    }

    if (needEvaluate && self.currentServiceStatus != RCCustomerService_NoService &&
        self.csConfig.evaEntryPoint == RCCSEvaLeave) {
        [self resetBottomBarStatus];
        if (self.currentServiceStatus == RCCustomerService_HumanService) {
            self.humanEvaluated = YES;
        }
        [self commentCustomerServiceWithStatus:self.currentServiceStatus commentId:nil quitAfterComment:YES];
    } else {
        [self leftBarButtonItemPressed:nil];
    }
}

- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
                               commentId:(NSString *)commentId
                        quitAfterComment:(BOOL)isQuit {
    if (serviceStatus != RCCustomerService_NoService && self.csConfig.evaType == EVA_UNIFIED) {
        [self showEvaView];
    }
    if (serviceStatus == RCCustomerService_HumanService) {
        RCChatSessionInputBarControlStyle style = RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION;
        [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType style:style];
        RCAdminEvaluationView *eva = [[RCAdminEvaluationView alloc] initWithDelegate:self];
        eva.quitAfterEvaluation = isQuit;
        eva.dialogId = commentId;
        [eva show];
    } else if (serviceStatus == RCCustomerService_RobotService) {
        [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType
                                                   style:RC_CHAT_INPUT_BAR_STYLE_CONTAINER];
        RCRobotEvaluationView *eva = [[RCRobotEvaluationView alloc] initWithDelegate:self];
        eva.quitAfterEvaluation = isQuit;
        eva.knownledgeId = commentId;
        [eva show];
    }
}

- (void)customerServiceLeftCurrentViewController {
    if (self.conversationType == ConversationType_CUSTOMERSERVICE) {
        [self suspendCustomerService];
        [self leftCustomerServiceWithEvaluate:YES];
    } else {
        [self leftBarButtonItemPressed:nil];
    }
}

- (void)customerServiceWarning:(NSString *)warning
              quitAfterWarning:(BOOL)quit
                  needEvaluate:(BOOL)needEvaluate
                   needSuspend:(BOOL)needSuspend {
    [self.evaluateView hide];
    if (self.csAlertView) {
        [self.csAlertView dismissWithClickedButtonIndex:0];
        self.csAlertView = nil;
    }

    [self resetBottomBarStatus];

    RCCSAlertView *alert = [[RCCSAlertView alloc] initWithTitle:nil warning:warning delegate:self];
    int tag = 0;
    if (quit) {
        tag = 1;
    }
    if (needEvaluate) {
        tag = tag | (1 << 1);
    }
    if (needSuspend) {
        tag = tag | (1 << 2);
    }
    alert.tag = tag;
    self.csAlertView = alert;
    [alert show];
}

- (void)onCustomerServiceModeChanged:(RCCSModeType)newMode {
}

- (void)showEvaView {
    [self resetBottomBarStatus];
    self.evaluateView =
        [[RCCSEvaluateView alloc] initWithFrame:CGRectZero showSolveView:self.csConfig.reportResolveStatus];
    __weak typeof(self) weakSelf = self;
    [self.evaluateView setEvaluateResult:^(int source, int solveStatus, NSString *suggest) {
        [[RCIMClient sharedRCIMClient] evaluateCustomerService:weakSelf.targetId
                                                      dialogId:nil
                                                     starValue:source
                                                       suggest:suggest
                                                 resolveStatus:solveStatus];
    }];
    [self.evaluateView show];
}

- (void)showAlertController:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (void)showCustomerServiceEndAlert {
    [self customerServiceWarning:self.customerServiceQuitMsg.length ? self.customerServiceQuitMsg
                                                                    : @"客服会话已结束!"
                quitAfterWarning:YES
                    needEvaluate:YES
                     needSuspend:YES];
}

- (void)announceViewWillShow {
    if (self.csConfig.announceMsg.length > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self announceViewWillShow:self.csConfig.announceMsg announceClickUrl:self.csConfig.announceClickUrl];
        });
    }
}

- (void)announceViewWillShow:(NSString *)announceMsg announceClickUrl:(NSString *)announceClickUrl {
}

#pragma mark - RCCSAlertViewDelegate
- (void)willCSAlertViewDismiss:(RCCSAlertView *)view {
    if (view.tag & (1 << 2)) {
        [self suspendCustomerService];
    }
    if (view.tag & 0x001) {
        [self leftCustomerServiceWithEvaluate:((view.tag & (1 << 1)) > 0)];
    }
}

#pragma mark - RCAdminEvaluationViewDelegate
- (void)adminEvaluateViewCancel:(RCAdminEvaluationView *)view {
    if (view.quitAfterEvaluation) {
        [self leftBarButtonItemPressed:nil];
    }
    if (self.csConfig.evaEntryPoint == RCCSEvaCSEnd) {
        [self showCustomerServiceEndAlert];
    }
}

- (void)adminEvaluateView:(RCAdminEvaluationView *)view didEvaluateValue:(int)starValues {
    if (starValues >= 0) {
        [[RCIMClient sharedRCIMClient] evaluateCustomerService:self.targetId
                                                      dialogId:view.dialogId
                                                     starValue:starValues + 1
                                                       suggest:nil
                                                 resolveStatus:(RCCSResolved)
                                                       tagText:nil
                                                         extra:nil];
    }
    if (view.quitAfterEvaluation) {
        [self leftBarButtonItemPressed:nil];
    }
    if (self.csConfig.evaEntryPoint == RCCSEvaCSEnd) {
        [self showCustomerServiceEndAlert];
    }
}

#pragma mark - RCRobotEvaluationViewDelegate
- (void)robotEvaluateViewCancel:(RCRobotEvaluationView *)view {
    if (view.quitAfterEvaluation) {
        [self leftBarButtonItemPressed:nil];
    }
}

- (void)robotEvaluateView:(RCRobotEvaluationView *)view didEvaluateValue:(BOOL)isResolved {
    [[RCIMClient sharedRCIMClient] evaluateCustomerService:self.targetId
                                              knownledgeId:view.knownledgeId
                                                robotValue:isResolved
                                                   suggest:nil];
    if (view.quitAfterEvaluation) {
        [self leftBarButtonItemPressed:nil];
    }
}

/****************** Custom Service Code End   ******************/

- (void)onTypingStatusChanged:(RCConversationType)conversationType
                     targetId:(NSString *)targetId
                       status:(NSArray *)userTypingStatusList {
    if (conversationType == self.conversationType && [targetId isEqualToString:self.targetId] &&
        [RCIM sharedRCIM].enableTypingStatus) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (userTypingStatusList == nil || userTypingStatusList.count == 0) {
                self.navigationItem.title = self.navigationTitle;
            } else {
                RCUserTypingStatus *typingStatus = (RCUserTypingStatus *)userTypingStatusList[0];
                if ([typingStatus.contentType isEqualToString:[RCTextMessage getObjectName]]) {
                    self.navigationItem.title = NSLocalizedStringFromTable(@"typing", @"RongCloudKit", nil);
                } else if ([typingStatus.contentType isEqualToString:[RCVoiceMessage getObjectName]]) {
                    self.navigationItem.title = NSLocalizedStringFromTable(@"Speaking", @"RongCloudKit", nil);
                }
            }
        });
    }
}

- (void)handleAppResume {
    self.isConversationAppear = YES;
    [self.conversationMessageCollectionView reloadData];
    if ([[RCIMClient sharedRCIMClient] getConnectionStatus] == ConnectionStatus_Connected) {
        [self syncReadStatus];
        [self sendReadReceipt];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:self.conversationType targetId:self.targetId];
    });
}

- (void)handleWillResignActive {
    self.isConversationAppear = NO;
    [self.chatSessionInputBarControl endVoiceRecord];
    //直接从会话页面杀死 app，保存或者清除草稿
    [self saveDraftIfNeed];
}

- (void)saveDraftIfNeed {
    NSString *draft = self.chatSessionInputBarControl.draft;
    if (draft && [draft length] > 0) {
        NSString *draftInDB =
            [[RCIMClient sharedRCIMClient] getTextMessageDraft:self.conversationType targetId:self.targetId];
        if(![draft isEqualToString:draftInDB]) {
            [[RCIMClient sharedRCIMClient] saveTextMessageDraft:self.conversationType targetId:self.targetId content:draft];
        }
    } else {
        [[RCIMClient sharedRCIMClient] clearTextMessageDraft:self.conversationType targetId:self.targetId];
    }
}

- (void)didLongPressCellPortrait:(NSString *)userId {
    if (!self.chatSessionInputBarControl.isMentionedEnabled ||
        [userId isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]) {
        return;
    }

    [self.chatSessionInputBarControl addMentionedUser:[self getSelectingUserInfo:userId]];
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
}
//遍历@列表，根据修改字符的范围更新@信息的range
//- (void)updateAllMentionedRangeInfo:(NSRange)changedRange {
//  for (RCMentionedStringRangeInfo *mentionedInfo in self.chatSessionInputBarControl.mentionedRangeInfoList) {
//    NSRange mentionedStrRange = mentionedInfo.range;
//    if (mentionedStrRange.location >= changedRange.location) {
//      mentionedInfo.range =
//      NSMakeRange(mentionedInfo.range.location + changedRange.length,
//                  mentionedInfo.range.length);
//    }
//  }
//}

#pragma mark - 回执请求及响应处理， 同步阅读状态
- (void)sendReadReceipt {
    if ((self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_Encrypted) &&
        [[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)]) {

        for (long i = self.conversationDataRepository.count - 1; i >= 0; i--) {
            RCMessageModel *model = self.conversationDataRepository[i];
            if (model.messageDirection == MessageDirection_RECEIVE) {
                [[RCIMClient sharedRCIMClient] sendReadReceiptMessage:self.conversationType
                                                             targetId:self.targetId
                                                                 time:model.sentTime
                                                              success:nil
                                                                error:nil];
                break;
            }
        }
    }
}

//自动回复机器人收到信令消息也会有自动回复，针对这些会话暂时不发 RC:SRSMsg 信令
//包含融云客服/爱客服小助手/测试公众号客服
- (BOOL)isAutoResponseRobot:(RCConversationType)type targetId:(NSString *)targetId {
    if (type == ConversationType_APPSERVICE) {
        if ([targetId isEqualToString:@"aikefutest"] || [targetId isEqualToString:@"KEFU144595511648939"] ||
            [targetId isEqualToString:@"testkefu"]) {
            return YES;
        }
    }
    return NO;
}

- (void)syncReadStatus {
    if (![RCIM sharedRCIM].enableSyncReadStatus)
        return;

    //单聊如果开启了已读回执，同步阅读状态功能可以复用已读回执，不需要发送同步命令。
    if ((self.conversationType == ConversationType_PRIVATE &&
         ![[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)]) ||
        self.conversationType == ConversationType_GROUP || self.conversationType == ConversationType_DISCUSSION ||
        self.conversationType == ConversationType_Encrypted || self.conversationType == ConversationType_APPSERVICE ||
        self.conversationType == ConversationType_PUBLICSERVICE) {
        if ([self isAutoResponseRobot:self.conversationType targetId:self.targetId]) {
            return;
        }
        for (long i = self.conversationDataRepository.count - 1; i >= 0; i--) {
            RCMessageModel *model = self.conversationDataRepository[i];
            if (model.messageDirection == MessageDirection_RECEIVE) {
                [[RCIMClient sharedRCIMClient] syncConversationReadStatus:self.conversationType
                                                                 targetId:self.targetId
                                                                     time:model.sentTime
                                                                  success:nil
                                                                    error:nil];
                break;
            }
        }
    }
}

/**
 *  收到回执消息的响应，更新这条消息的已读数
 *
 *  @param notification notification description
 */
- (void)onReceiveMessageReadReceiptResponse:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([self.targetId isEqualToString:dic[@"targetId"]] &&
        self.conversationType == [dic[@"conversationType"] intValue]) {
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            RCMessageModel *model = self.conversationDataRepository[i];
            if ([model.messageUId isEqualToString:dic[@"messageUId"]]) {
                NSDictionary *readerList = dic[@"readerList"];
                model.readReceiptCount = readerList.count;
                model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                model.readReceiptInfo.isReceiptRequestMessage = YES;
                model.readReceiptInfo.userIdList = [NSMutableDictionary dictionaryWithDictionary:readerList];
                RCMessageCellNotificationModel *notifyModel = [[RCMessageCellNotificationModel alloc] init];
                notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_READCOUNT;
                notifyModel.messageId = model.messageId;
                notifyModel.progress = readerList.count;

                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                        postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                      object:notifyModel];
                });
            }
        }
    }
}

/**
 *  收到消息请求回执，如果当前列表中包含需要回执的messageUId，发送回执响应
 *
 *  @param notification notification description
 */
- (void)onReceiveMessageReadReceiptRequest:(NSNotification *)notification {
    NSDictionary *dic = notification.object;
    if ([self.targetId isEqualToString:dic[@"targetId"]] &&
        self.conversationType == [dic[@"conversationType"] intValue]) {
        [self.conversationDataRepository enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RCMessageModel *model = (RCMessageModel *)obj;
            if ([model.messageUId isEqualToString:dic[@"messageUId"]]) {
                if (model.messageDirection == MessageDirection_RECEIVE) {
                    RCMessage *msg = [[RCIMClient sharedRCIMClient] getMessage:model.messageId];
                    if (msg) {
                        NSArray *msgList = [NSArray arrayWithObject:msg];
                        [[RCIMClient sharedRCIMClient]
                            sendReadReceiptResponse:self.conversationType
                            targetId:self.targetId
                            messageList:msgList
                            success:^{

                            }
                            error:^(RCErrorCode nErrorCode){

                            }];
                    }
                    if (!model.readReceiptInfo) {
                        model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                    }
                    model.readReceiptInfo.isReceiptRequestMessage = YES;
                    model.readReceiptInfo.hasRespond = YES;
                } else {
                    model.readReceiptCount = 0;
                    model.readReceiptInfo = [[RCReadReceiptInfo alloc] init];
                    model.readReceiptInfo.isReceiptRequestMessage = YES;
                    model.isCanSendReadReceipt = NO;
                    RCMessageCellNotificationModel *notifyModel =
                        [[RCMessageCellNotificationModel alloc] init];
                    notifyModel.actionName = CONVERSATION_CELL_STATUS_SEND_READCOUNT;
                    notifyModel.messageId = model.messageId;
                    notifyModel.progress = 0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]
                            postNotificationName:KNotificationMessageBaseCellUpdateSendingStatus
                                          object:notifyModel];
                    });
                }
                *stop = YES;
            }
        }];
    }
}

/**
 *  需要发送回执响应
 *
 *  @param array 需要回执响应的消息的列表
 */
- (void)sendReadReceiptResponseForMessages:(NSArray *)array {
    if ([[RCIM sharedRCIM].enabledReadReceiptConversationTypeList containsObject:@(self.conversationType)]) {
        NSMutableArray *readReceiptarray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            RCMessage *rcMsg = [array objectAtIndex:i];
            if (rcMsg.readReceiptInfo && rcMsg.readReceiptInfo.isReceiptRequestMessage &&
                !rcMsg.readReceiptInfo.hasRespond && rcMsg.messageDirection == MessageDirection_RECEIVE) {
                [readReceiptarray addObject:rcMsg];
            }
        }

        if (readReceiptarray && readReceiptarray.count > 0) {
            [[RCIMClient sharedRCIMClient] sendReadReceiptResponse:self.conversationType
                                                          targetId:self.targetId
                                                       messageList:readReceiptarray
                                                           success:nil
                                                             error:nil];
        }
    }
}

- (BOOL)enabledReadReceiptMessage:(RCMessageModel *)model {
    if ([self.enabledReadReceiptMessageTypeList containsObject:model.objectName]) {
        return YES;
    }
    return NO;
}

- (void)stopNotSendMessageAlertTimer {
    if (_notSendMessageAlertTimer) {
        if (_notSendMessageAlertTimer.valid) {
            [_notSendMessageAlertTimer invalidate];
        }
        _notSendMessageAlertTimer = nil;
    }
}

- (void)stopNotReciveMessageAlertTimer {
    if (_notReciveMessageAlertTimer) {
        if (_notReciveMessageAlertTimer.valid) {
            [_notReciveMessageAlertTimer invalidate];
        }
        _notReciveMessageAlertTimer = nil;
    }
}

/**
 *  开始长时间没有收到消息的timer监听
 *
 */
- (void)startNotReciveMessageAlertTimer {
    if (self.conversationType != ConversationType_CUSTOMERSERVICE) {
        return;
    }
    if (self.csConfig.adminTipTime > 0 && self.csConfig.adminTipWord.length > 0) {
        self.customerServiceReciveMessageOverTimeRemindTimer = self.csConfig.adminTipTime * 60;
        self.customerServiceReciveMessageOverTimeRemindContent = self.csConfig.adminTipWord;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_notReciveMessageAlertTimer) {
                if (_notReciveMessageAlertTimer.valid) {
                    [_notReciveMessageAlertTimer invalidate];
                }
                _notReciveMessageAlertTimer = nil;
            }
            if (!_notReciveMessageAlertTimer) {
                _notReciveMessageAlertTimer =
                    [NSTimer scheduledTimerWithTimeInterval:self.customerServiceReciveMessageOverTimeRemindTimer
                                                     target:self
                                                   selector:@selector(longTimeNotReciveMessageAlert)
                                                   userInfo:nil
                                                    repeats:YES];
            }

        });
    }
}

/**
 *  开始长时间没有发送消息的timer监听
 *
 */
- (void)startNotSendMessageAlertTimer {
    if (self.conversationType != ConversationType_CUSTOMERSERVICE) {
        return;
    }
    if (self.csConfig.userTipTime > 0 && self.csConfig.userTipWord.length > 0) {
        self.customerServiceSendMessageOverTimeRemindTimer = self.csConfig.userTipTime * 60;
        self.customerServiceSendMessageOverTimeRemindContent = self.csConfig.userTipWord;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_notSendMessageAlertTimer) {
                if (_notSendMessageAlertTimer.valid) {
                    [_notSendMessageAlertTimer invalidate];
                }
                _notSendMessageAlertTimer = nil;
            }
            _notSendMessageAlertTimer =
                [NSTimer scheduledTimerWithTimeInterval:self.customerServiceSendMessageOverTimeRemindTimer
                                                 target:self
                                               selector:@selector(longTimeNotSendMessageAlert)
                                               userInfo:nil
                                                repeats:YES];
        });
    }
}

/**
 *  长时间没有收到消息的超时提醒
 *
 */
- (void)longTimeNotReciveMessageAlert {
    if (self.currentServiceStatus == RCCustomerService_HumanService) {
        RCInformationNotificationMessage *informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:self.customerServiceReciveMessageOverTimeRemindContent
                              extra:nil];

        __block RCMessage *tempMessage = [[RCIMClient sharedRCIMClient] insertIncomingMessage:self.conversationType
                                                                                     targetId:self.targetId
                                                                                 senderUserId:self.targetId
                                                                               receivedStatus:(ReceivedStatus_READ)
                                                                                      content:informationNotifiMsg];
        dispatch_async(dispatch_get_main_queue(), ^{
            tempMessage = [self willAppendAndDisplayMessage:tempMessage];
            if (tempMessage) {
                [self appendAndDisplayMessage:tempMessage];
            }
            [self stopNotReciveMessageAlertTimer];
        });
    } else {
        [self stopNotReciveMessageAlertTimer];
    }
}

/**
 *  长时间没有发送消息的超时提醒
 *
 */
- (void)longTimeNotSendMessageAlert {
    if (self.currentServiceStatus == RCCustomerService_HumanService) {
        RCInformationNotificationMessage *informationNotifiMsg = [RCInformationNotificationMessage
            notificationWithMessage:self.customerServiceSendMessageOverTimeRemindContent
                              extra:nil];
        __block RCMessage *tempMessage = [[RCIMClient sharedRCIMClient] insertIncomingMessage:self.conversationType
                                                                                     targetId:self.targetId
                                                                                 senderUserId:self.targetId
                                                                               receivedStatus:(ReceivedStatus_READ)
                                                                                      content:informationNotifiMsg];
        dispatch_async(dispatch_get_main_queue(), ^{
            tempMessage = [self willAppendAndDisplayMessage:tempMessage];
            if (tempMessage) {
                [self appendAndDisplayMessage:tempMessage];
            }

            [self stopNotSendMessageAlertTimer];
        });
    } else {
        [self stopNotReciveMessageAlertTimer];
    }
}

- (UIView *)extensionView {
    if (!_extensionView) {
        _extensionView = [[UIView alloc] init];
        [self.view addSubview:_extensionView];
    }
    return _extensionView;
}

- (void)stopPlayingVoiceMessage {
    if ([RCVoicePlayer defaultPlayer].isPlaying) {
        [[RCVoicePlayer defaultPlayer] stopPlayVoice];
    }
}

#pragma mark-- Cell multi select
- (void)setAllowsMessageCellSelection:(BOOL)allowsMessageCellSelection {
    [[RCMessageSelectionUtility sharedManager] clear];
    [[RCMessageSelectionUtility sharedManager] setMultiSelect:allowsMessageCellSelection];
    if ([NSThread isMainThread]) {
        [self updateConversationMessageCollectionView];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateConversationMessageCollectionView];
        });
    }
}

- (void)updateConversationMessageCollectionView {
    [self updateNavigationBarItem];
    if ([RCMessageSelectionUtility sharedManager].multiSelect) {
        if (self.chatSessionInputBarControl.currentBottomBarStatus != KBottomBarRecordStatus) {
            [self.chatSessionInputBarControl resetToDefaultStatus];
        }
        [[RCMessageSelectionUtility sharedManager] addMessageModel:self.currentSelectedModel];
    } else {
        self.currentSelectedModel = nil;
    }
    [self showToolBar:[RCMessageSelectionUtility sharedManager].multiSelect];
    NSArray<NSIndexPath *> *indexPathsForVisibleItems =
        [self.conversationMessageCollectionView indexPathsForVisibleItems];
    if (indexPathsForVisibleItems) {
        [self.conversationMessageCollectionView reloadItemsAtIndexPaths:indexPathsForVisibleItems];
    }
}

- (void)onMultiSelectMessageCell:(id)sender {
    self.allowsMessageCellSelection = YES;
}

- (void)onCancelMultiSelectEvent:(UIBarButtonItem *)item {
    self.allowsMessageCellSelection = NO;
}

- (void)showToolBar:(BOOL)show {
    if (show) {
        [self.view addSubview:self.messageSelectionToolbar];
        [self dismissReferencingView:self.referencingView];
    } else {
        [self.messageSelectionToolbar removeFromSuperview];
    }
}

- (NSArray<RCMessageModel *> *)selectedMessages {
    return [[RCMessageSelectionUtility sharedManager] selectedMessages];
}

- (void)deleteMessages {
    for (int i = 0; i < self.selectedMessages.count; i++) {
        [self deleteMessage:self.selectedMessages[i]];
    }
    self.allowsMessageCellSelection = NO;
}

/// RCMessagesMultiSelectedProtocol method
/// @param status 选择状态：选择/取消选择
/// @param model cell 数据模型
- (BOOL)onMessagesMultiSelectedCountWillChanged:(RCMessageMultiSelectStatus)status model:(RCMessageModel *)model {
    BOOL executed = YES;
    switch (status) {
    case RCMessageMultiSelectStatusSelected:
        executed = [self willSelectMessage:model];
        break;
    case RCMessageMultiSelectStatusCancelSelected:
        executed = [self willCancelSelectMessage:model];
        break;
    default:
        break;
    }
    return executed;
}

- (void)onMessagesMultiSelectedCountDidChanged:(RCMessageMultiSelectStatus)status model:(RCMessageModel *)model {
    if (self.selectedMessages.count == 0) {
        for (UIBarButtonItem *item in self.messageSelectionToolbar.items) {
            item.enabled = NO;
        }
    } else {
        for (UIBarButtonItem *item in self.messageSelectionToolbar.items) {
            item.enabled = YES;
        }
    }
}

- (void)updateDownloadStatus:(NSNotification *)noti {
    RCHQVoiceMsgDownloadInfo *info = noti.object;
    RCMessageModel *model;
    RCHQVoiceMessage *message;
    if (info.status == RCHQDownloadStatusSuccess) {
        for (int i = (int)self.conversationDataRepository.count - 1; i >= 0; i--) {
            model = self.conversationDataRepository[i];
            if (model.messageId == info.hqVoiceMsg.messageId &&
                [model.content isKindOfClass:[RCHQVoiceMessage class]]) {
                message = (RCHQVoiceMessage *)model.content;
                message.localPath = ((RCHQVoiceMessage *)info.hqVoiceMsg.content).localPath;
                break;
            }
        }
    }
}

- (void)downloadMediaNotification:(NSNotification *)noti {
    NSDictionary *info = noti.userInfo;
    if ([[info objectForKey:@"type"] isEqualToString:@"success"]) {
        NSInteger messageid = [[info objectForKey:@"messageId"] integerValue];
        RCMessageModel *model;
        RCGIFMessage *message;
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            model = self.conversationDataRepository[i];
            if (model.messageId == messageid && [model.content isKindOfClass:[RCGIFMessage class]]) {
                message = (RCGIFMessage *)model.content;
                message.localPath = [info objectForKey:@"mediaPath"];
                break;
            }
        }
    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dataDict = notification.userInfo;
        RCMessage *message = dataDict[@"message"];
        NSTimeInterval duration = [dataDict[@"remainDuration"] doubleValue];

        if (duration > 0) {
            NSString *msgUId = message.messageUId;
            RCMessageModel *msgModel;
            for (RCMessageCell *cell in self.conversationMessageCollectionView.visibleCells) {
                msgModel = cell.model;
                if ([msgModel.messageUId isEqualToString:msgUId] &&
                    [cell respondsToSelector:@selector(messageDestructing)]) {
                    [cell performSelectorOnMainThread:@selector(messageDestructing) withObject:nil waitUntilDone:NO];
                }
            }
        } else {
            [self onMessageBurnDestory:message];
        }

        //钩子
        [self messageDestructing:notification];
    });
}

- (void)onMessageBurnDestory:(RCMessage *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msgUId = message.messageUId;
        int index = -1;
        RCMessageModel *msgModel;
        for (int i = 0; i < self.conversationDataRepository.count; i++) {
            msgModel = [self.conversationDataRepository objectAtIndex:i];
            if ([msgModel.messageUId isEqualToString:msgUId]) {
                index = i;
                break;
            }
        }
        if (index >= 0) {
            NSIndexPath *indexPath = [self findDataIndexFromMessageList:msgModel];
            //如果是语音消息则停止播放
            if ([message.content isMemberOfClass:[RCVoiceMessage class]]) {
                RCVoiceMessageCell *cell =
                    (RCVoiceMessageCell *)[self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath];
                [cell stopPlayingVoice];
            }
            //获取需要更新的indexPath
            [self.conversationDataRepository removeObjectAtIndex:index];

            if (self.conversationDataRepository.count > 0) {
                RCMessageModel *lastOldModel = self.conversationDataRepository[0];
                RCMessageModel *lastNewModel =
                    self.conversationDataRepository[self.conversationDataRepository.count - 1];
                BOOL needReloadView = NO;
                if ([lastOldModel.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
                    //                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.conversationDataRepository removeObject:lastOldModel];
                    //                    [self.conversationMessageCollectionView
                    //                     deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                    //删除“以上是历史消息”之后，会话的第一条消息显示时间，并且调整高度
                    RCMessageModel *topMsg = (self.conversationDataRepository)[0];
                    topMsg.isDisplayMessageTime = YES;
                    topMsg.cellSize = CGSizeMake(topMsg.cellSize.width, topMsg.cellSize.height + 30);
                    RCMessageCell *__cell = (RCMessageCell *)[self.conversationMessageCollectionView
                        cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
                    if (__cell) {
                        [__cell setDataModel:topMsg];
                    }
                    needReloadView = YES;
                }
                NSIndexPath *internalIndexPath;
                if ([lastNewModel.content isKindOfClass:[RCOldMessageNotificationMessage class]]) {
                    internalIndexPath =
                        [NSIndexPath indexPathForRow:self.conversationDataRepository.count - 1 inSection:0];
                    [self.conversationDataRepository removeObject:lastNewModel];
                }
                if (needReloadView) {
                    [self.conversationMessageCollectionView reloadData];
                } else {
                    NSArray *deleteItems;
                    if (internalIndexPath) {
                        deleteItems = [NSArray arrayWithObjects:indexPath, internalIndexPath, nil];
                    } else {
                        deleteItems = [NSArray arrayWithObject:indexPath];
                    }
                    [self.conversationMessageCollectionView deleteItemsAtIndexPaths:deleteItems];
                }
            } else {
                if ([self.conversationMessageCollectionView cellForItemAtIndexPath:indexPath]) {
                    [self.conversationMessageCollectionView deleteItemsAtIndexPaths:@[ indexPath ]];
                }
            }

            if ([self.longPressSelectedModel.messageUId isEqualToString:message.messageUId]) {
                if (@available(iOS 13.0, *)) {
                    [[UIMenuController sharedMenuController] hideMenuFromView:self.view];
                } else {
                    [[UIMenuController sharedMenuController] setMenuItems:nil];
                    [UIMenuController sharedMenuController].menuVisible = NO;
                }

                self.longPressSelectedModel = nil;
            }
        }
        if (msgModel) {
            if ([[RCMessageSelectionUtility sharedManager] isContainMessage:msgModel]) {
                [[RCMessageSelectionUtility sharedManager] removeMessageModel:msgModel];
            }
        }
    });
}

- (void)messageDestructing:(NSNotification *)notification {
}

- (void)updateNavigationBarItem {
    [self notifyUpdateUnreadMessageCount];
}

- (BOOL)allowsMessageCellSelection {
    return [RCMessageSelectionUtility sharedManager].multiSelect;
}

- (UIToolbar *)messageSelectionToolbar {
    if (!_messageSelectionToolbar) {
        _messageSelectionToolbar = [[UIToolbar alloc] init];
        if ([RCIM sharedRCIM].enableSendCombineMessage &&
            (self.conversationType == ConversationType_PRIVATE || self.conversationType == ConversationType_GROUP)) {
            UIButton *forwardBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
            [forwardBtn setImage:[RCKitUtility imageNamed:@"forward_message" ofBundle:@"RongCloud.bundle"]
                        forState:UIControlStateNormal];
            [forwardBtn addTarget:self action:@selector(forwardMessages) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *forwardBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:forwardBtn];

            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
            [deleteBtn setImage:[RCKitUtility imageNamed:@"delete_message" ofBundle:@"RongCloud.bundle"]
                       forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
            UIBarButtonItem *spaceItem =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                              target:nil
                                                              action:nil];
            [_messageSelectionToolbar
                setItems:@[ spaceItem, forwardBarButtonItem, spaceItem, deleteBarButtonItem, spaceItem ]
                animated:YES];
        } else {
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
            [deleteBtn setImage:[RCKitUtility imageNamed:@"delete_message" ofBundle:@"RongCloud.bundle"]
                       forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteMessages) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *deleteBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
            UIBarButtonItem *spaceItem =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                              target:nil
                                                              action:nil];
            [_messageSelectionToolbar setItems:@[ spaceItem, deleteBarButtonItem, spaceItem ] animated:YES];
        }

        _messageSelectionToolbar.translucent = NO;
    }
    return _messageSelectionToolbar;
}

- (void)forwardMessages {
    [self showForwardActionSheet];
}

- (void)showForwardActionSheet {
    __weak typeof(self) weakSelf = self;
    NSArray *titleArray = [[NSMutableArray alloc]
        initWithObjects:NSLocalizedStringFromTable(@"OneByOneForward", @"RongCloudKit", nil),
                        NSLocalizedStringFromTable(@"CombineAndForward", @"RongCloudKit", nil), nil];
    CGSize bounds = self.view.bounds.size;
    RCActionSheetView *actionSheetView = [[RCActionSheetView alloc] initWithCellArray:titleArray
        viewBounds:bounds
        cancelTitle:NSLocalizedStringFromTable(@"Cancel", @"RongCloudKit", nil)
        selectedBlock:^(NSInteger index) {
            NSArray *selectedMessage = [NSArray arrayWithArray:weakSelf.selectedMessages];
            if (index == 0) {
                if ([RCCombineMessageUtility allSelectedOneByOneForwordMessagesAreLegal:self.selectedMessages]) {
                    //逐条转发
                    [self forwardMessage:0
                               completed:^(NSArray<RCConversation *> *conversationList) {
                                   if (conversationList) {
                                       [[RCForwardManager sharedInstance] doForwardMessageList:selectedMessage
                                                                              conversationList:conversationList
                                                                                     isCombine:NO
                                                                       forwardConversationType:weakSelf.conversationType
                                                                                     completed:^(BOOL success){
                                                                                     }];
                                       [weakSelf forwardMessageEnd];
                                   }
                               }];
                } else {
                    UIAlertController *alertController = [UIAlertController
                        alertControllerWithTitle:nil
                                         message:NSLocalizedStringFromTable(@"OneByOneForwardingNotSupported",
                                                                            @"RongCloudKit", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
                    [alertController
                        addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                         }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }

            } else if (index == 1) {
                if ([RCCombineMessageUtility allSelectedCombineForwordMessagesAreLegal:self.selectedMessages]) {
                    [self forwardMessage:1
                               completed:^(NSArray<RCConversation *> *conversationList) {
                                   if (conversationList) {
                                       [[RCForwardManager sharedInstance] doForwardMessageList:selectedMessage
                                                                              conversationList:conversationList
                                                                                     isCombine:YES
                                                                       forwardConversationType:weakSelf.conversationType
                                                                                     completed:^(BOOL success){
                                                                                     }];
                                       [weakSelf forwardMessageEnd];
                                   }
                               }];
                } else {
                    UIAlertController *alertController = [UIAlertController
                        alertControllerWithTitle:nil
                                         message:NSLocalizedStringFromTable(@"CombineForwardingNotSupported",
                                                                            @"RongCloudKit", nil)
                                  preferredStyle:UIAlertControllerStyleAlert];
                    [alertController
                        addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action){
                                                         }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
        }
        cancelBlock:^{

        }];
    [self.view addSubview:actionSheetView];
}

- (void)forwardMessage:(NSInteger)index
             completed:(void (^)(NSArray<RCConversation *> *conversationList))completedBlock {
    RCSelectConversationViewController *forwardSelectedVC = [[RCSelectConversationViewController alloc]
        initSelectConversationViewControllerCompleted:^(NSArray<RCConversation *> *conversationList) {
            completedBlock(conversationList);
        }];
    [self.navigationController pushViewController:forwardSelectedVC animated:NO];
}

- (void)forwardMessageEnd {
    self.allowsMessageCellSelection = NO;
}

#pragma mark - Helper
- (void)registerSectionHeaderView {
    [self.conversationMessageCollectionView registerClass:[RCConversationCollectionViewHeader class]
                               forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                      withReuseIdentifier:@"RefreshHeadView"];
}

- (void)resetSectionHeaderView {
    self.isIndicatorLoading = YES;
    CGPoint offset = self.conversationMessageCollectionView.contentOffset;
    if (!self.allMessagesAreLoaded) {
        offset.y += COLLECTION_VIEW_REFRESH_CONTROL_HEIGHT;
    }
    [UIView setAnimationsEnabled:NO];
    UICollectionViewLayout *layout = self.conversationMessageCollectionView.collectionViewLayout;
    [self.conversationMessageCollectionView.collectionViewLayout invalidateLayout];
    [self.conversationMessageCollectionView setCollectionViewLayout:layout];
    [self.conversationMessageCollectionView performBatchUpdates:^{
        self.conversationMessageCollectionView.contentOffset = offset;
    }
        completion:^(BOOL finished) {
            self.isIndicatorLoading = NO;
            [UIView setAnimationsEnabled:YES];
        }];
}

- (void)refreshVisibleCells {
    //刷新当前屏幕的cell
    NSMutableArray *indexPathes = [[NSMutableArray alloc] init];
    for (RCMessageCell *cell in self.conversationMessageCollectionView.visibleCells) {
        NSIndexPath *indexPath = [self.conversationMessageCollectionView indexPathForCell:cell];
        [indexPathes addObject:indexPath];
    }
    [self.conversationMessageCollectionView reloadItemsAtIndexPaths:[indexPathes copy]];
}

- (RCMessageModel *)setModelIsDisplayNickName:(RCMessageModel *)model {
    if (!model) {
        return nil;
    }
    if (model.messageDirection == MessageDirection_RECEIVE) {
        model.isDisplayNickname = self.displayUserNameInCell;
    } else {
        model.isDisplayNickname = NO;
    }
    return model;
}

#pragma mark - dark
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self fitDarkMode];
}

- (void)fitDarkMode {
    if (![RCIM sharedRCIM].enableDarkMode) {
        return;
    }
    if (@available(iOS 13.0, *)) {
        if (self.unReadButton) {
            [self.unReadButton setBackgroundImage:[RCKitUtility imageNamed:@"up" ofBundle:@"RongCloud.bundle"]
                                         forState:UIControlStateNormal];
        }
        [self.conversationMessageCollectionView reloadData];
    }
}

#pragma mark - Reference
- (void)onReferenceMessageCell:(id)sender {
    [self removeReferencingView];
    self.referencingView = [[RCReferencingView alloc] initWithModel:self.currentSelectedModel inView:self.view];
    self.referencingView.delegate = self;
    [self.view addSubview:self.referencingView];
    [self.referencingView
        setOffsetY:CGRectGetMinY(self.chatSessionInputBarControl.frame) - self.referencingView.frame.size.height];
    [self.chatSessionInputBarControl.inputTextView becomeFirstResponder];
    [self updateReferenceViewFrame];
}

#pragma mark - RCReferencingViewDelegate
- (void)dismissReferencingView:(RCReferencingView *)referencingView {
    [self removeReferencingView];
    __block CGRect messageCollectionView = self.conversationMessageCollectionView.frame;
    [UIView animateWithDuration:0.25
                     animations:^{
                         messageCollectionView.size.height =
                             CGRectGetMinY(self.chatSessionInputBarControl.frame) - messageCollectionView.origin.y;
                         self.conversationMessageCollectionView.frame = messageCollectionView;
                     }];
}

- (void)didTapReferencingView:(RCMessageModel *)messageModel {
    [self previewReferenceView:messageModel];
}

- (void)previewReferenceView:(RCMessageModel *)messageModel {
    RCMessageContent *msgContent = messageModel.content;
    if ([messageModel.content isKindOfClass:[RCReferenceMessage class]]) {
        RCReferenceMessage *refer = (RCReferenceMessage *)messageModel.content;
        msgContent = refer.referMsg;
    }

    if ([msgContent isKindOfClass:[RCImageMessage class]]) {
        RCMessage *referencedMsg = [[RCMessage alloc] initWithType:self.conversationType
                                                          targetId:self.targetId
                                                         direction:MessageDirection_SEND
                                                         messageId:-1
                                                           content:msgContent];
        RCMessageModel *imageModel = [RCMessageModel modelWithMessage:referencedMsg];
        [self presentImagePreviewController:imageModel onlyPreviewCurrentMessage:YES];
    } else if ([msgContent isKindOfClass:[RCFileMessage class]]) {
        [self presentFilePreviewViewController:messageModel];
    } else if ([msgContent isKindOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *richMsg = (RCRichContentMessage *)msgContent;
        if (richMsg.url.length > 0) {
            [RCKitUtility openURLInSafariViewOrWebView:richMsg.url base:self];
        } else if (richMsg.imageURL.length > 0) {
            [RCKitUtility openURLInSafariViewOrWebView:richMsg.imageURL base:self];
        }
    }
}

- (BOOL)enableReferenceMessage:(RCMessageModel *)message {
    if (![RCIM sharedRCIM].enableMessageReference || self.chatSessionInputBarControl.hidden ||
        self.chatSessionInputBarControl.burnMessageMode || self.conversationType == ConversationType_CUSTOMERSERVICE) {
        return NO;
    }

    //发送失败的消息不允许引用
    if ((message.sentStatus != SentStatus_SENDING && message.sentStatus != SentStatus_FAILED &&
         message.sentStatus != SentStatus_CANCELED) &&
        ([message.content isKindOfClass:RCTextMessage.class] || [message.content isKindOfClass:RCFileMessage.class] ||
         [message.content isKindOfClass:RCRichContentMessage.class] ||
         [message.content isKindOfClass:RCImageMessage.class] ||
         [message.content isKindOfClass:RCReferenceMessage.class])) {
        return YES;
    }
    return NO;
}

- (BOOL)updateReferenceViewFrame {
    if (self.referencingView) {
        UIButton *recordBtn = (UIButton *)self.chatSessionInputBarControl.recordButton;
        UIButton *emojiBtn = (UIButton *)self.chatSessionInputBarControl.emojiButton;
        UIButton *additionalBtn = (UIButton *)self.chatSessionInputBarControl.additionalButton;
        //文本输入或者表情输入状态下，才可以发送引用消息
        if ((recordBtn.hidden || emojiBtn.state == UIControlStateHighlighted) &&
            additionalBtn.state == UIControlStateNormal) {
            [self.referencingView setOffsetY:CGRectGetMinY(self.chatSessionInputBarControl.frame) -
                                             self.referencingView.frame.size.height];

            __block CGRect messageCollectionView = self.conversationMessageCollectionView.frame;
            [UIView
                animateWithDuration:0.25
                         animations:^{
                             messageCollectionView.size.height =
                                 CGRectGetMinY(self.referencingView.frame) - messageCollectionView.origin.y;
                             self.conversationMessageCollectionView.frame = messageCollectionView;
                             if (self.conversationMessageCollectionView.contentSize.height >
                                 messageCollectionView.size.height) {
                                 [self.conversationMessageCollectionView
                                     setContentOffset:CGPointMake(
                                                          0, self.conversationMessageCollectionView.contentSize.height -
                                                                 messageCollectionView.size.height)
                                             animated:NO];
                                 //引用view显示时，页面滚动到最新处，右下方气泡消失
                                 [self.unreadNewMsgArr removeAllObjects];
                                 [self updateUnreadMsgCountLabel];
                             }
                         }];
            return YES;
        } else {
            [self removeReferencingView];
        }
    }
    return NO;
}

- (BOOL)sendReferenceMessage:(NSString *)content {
    if (self.referencingView.referModel) {
        RCReferenceMessage *reference = [[RCReferenceMessage alloc] init];
        reference.content = content;
        reference.referMsg = self.referencingView.referModel.content;
        reference.referMsgUserId = self.referencingView.referModel.senderUserId;
        reference.mentionedInfo = self.chatSessionInputBarControl.mentionedInfo;
        [self sendMessage:reference pushContent:nil];
        [self removeReferencingView];
        return YES;
    }
    return NO;
}

- (void)removeReferencingView {
    if (self.referencingView) {
        [self.referencingView removeFromSuperview];
        self.referencingView = nil;
        [self updateUnreadMsgCountLabelFrame];
    }
}
@end
