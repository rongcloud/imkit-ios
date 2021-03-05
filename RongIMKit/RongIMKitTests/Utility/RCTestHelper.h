//
//  RCTestHelper.h
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCIM.h"
#import "RCMethodModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCTestHelper : NSObject
+ (RCTextMessage *)getTextMessage;
+(RCImageMessage *)getImageMessage;
+ (RCFileMessage *)getFileMessage;
+ (RCSightMessage *)getSightMessage;
+(RCGIFMessage *)getGifMessage;
+ (NSDictionary *)getAllRongCloudClasses;
+ (NSArray<RCMethodModel *> *)getAllMethods:(Class)cla;
+(void)excuteMethodArgumentWithNil:(NSObject *)instance;
+ (void)excuteMethodArgumentWithNil:(NSObject *)instance except:(NSDictionary *)exceptMethods;
+ (void)excuteClassMethod:(Class)cla except:(NSDictionary *)exceptMethods;
+ (void)excuteInstanceMethod:(NSObject *)instance except:(NSDictionary *)exceptMethods;
+ (UIImage *)fixOrientation:(UIImage *)image withOrientation:(UIImageOrientation)imageOrientation;
@end

NS_ASSUME_NONNULL_END
