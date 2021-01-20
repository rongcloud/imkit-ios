//
//  RCLocationMessageCell.m
//  RongIMKit
//
//  Created by xugang on 15/2/2.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCLocationMessageCell.h"
#import "RCIM.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"
#import "RCMessageCellTool.h"
#import "RCKitConfig.h"
//写死尺寸 408*240
//这个尺寸在生成缩略图的地方有定义，还有发送位置消息时对尺寸有裁剪。如果修改尺寸，需要把对应的地方同时修改
#define TARGET_LOCATION_THUMB_WIDTH 408
#define TARGET_LOCATION_THUMB_HEIGHT 240

@interface RCLocationMessageCell ()
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *shadowMaskView;
@end

@implementation RCLocationMessageCell
#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - Super Methods

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat __messagecontentview_height = TARGET_LOCATION_THUMB_HEIGHT / 2.0f;

    if (__messagecontentview_height < RCKitConfigCenter.ui.globalMessagePortraitSize.height) {
        __messagecontentview_height = RCKitConfigCenter.ui.globalMessagePortraitSize.height;
    }

    __messagecontentview_height += extraHeight;

    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self beginDestructing];
    [self setAutoLayout];
}

#pragma mark - 阅后即焚

- (void)beginDestructing {
    RCLocationMessage *_locationMessage = (RCLocationMessage *)self.model.content;
    if (self.model.messageDirection == MessageDirection_RECEIVE && _locationMessage.destructDuration > 0 &&
        [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [[RCIMClient sharedRCIMClient]
            messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessage:self.model.messageId]];
    }
}

#pragma mark - Private Methods

- (void)initialize {
    [self.pictureView addSubview:self.locationNameLabel];
    [self.messageContentView addSubview:self.pictureView];
}

- (void)setMaskImage:(UIImage *)maskImage {
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];

        _maskView.frame = self.pictureView.bounds;
        self.pictureView.layer.mask = _maskView.layer;
        self.pictureView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.pictureView.bounds;
    }
    if (_shadowMaskView) {
        [_shadowMaskView removeFromSuperview];
    }
    _shadowMaskView = [[UIImageView alloc] initWithImage:maskImage];
    _shadowMaskView.frame = self.pictureView.bounds;
    [self.messageContentView addSubview:_shadowMaskView];
    [self.messageContentView bringSubviewToFront:self.pictureView];
}

- (void)setAutoLayout {
    RCLocationMessage *locationMessage = (RCLocationMessage *)self.model.content;
    if (locationMessage) {
        self.locationNameLabel.text = [@"  " stringByAppendingString:locationMessage.locationName ?: @""];
        CGSize imageSize = CGSizeMake(TARGET_LOCATION_THUMB_WIDTH / 2.0f, TARGET_LOCATION_THUMB_HEIGHT / 2.0f);
        self.pictureView.image = locationMessage.thumbnailImage;
        self.shadowMaskView.image = nil;
        self.messageContentView.contentSize = imageSize;
        self.pictureView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        self.locationNameLabel.frame = CGRectMake(0, self.pictureView.frame.size.height - 25,self.pictureView.frame.size.width, 25);
        [self setMaskImage:[RCMessageCellTool getDefaultMessageCellBackgroundImage:self.model]];
    } else {
        DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCLocationMessage object");
    }
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.locationNameLabel.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(8, 8)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.locationNameLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    self.locationNameLabel.layer.mask = maskLayer;
}

#pragma mark - Getter
- (UIImageView *)pictureView{
    if (!_pictureView) {
        _pictureView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _pictureView.clipsToBounds = YES;
        _pictureView.contentMode = UIViewContentModeScaleToFill;
    }
    return _pictureView;
}

- (UILabel *)locationNameLabel{
    if (!_locationNameLabel) {
        _locationNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationNameLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.34];
        _locationNameLabel.textAlignment = NSTextAlignmentLeft;
        _locationNameLabel.textColor = [UIColor whiteColor];
        _locationNameLabel.font = [[RCKitConfig defaultConfig].font fontOfGuideLevel];
        _locationNameLabel.clipsToBounds = YES;
    }
    return _locationNameLabel;
}


@end
