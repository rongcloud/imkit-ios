//
//  RCMethodModel.h
//  RongIMKit
//
//  Created by 杜立召 on 2020/2/26.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RCMethodType) {
     RCMethodType_InstanceMethod = 0,
     RCMethodType_ClassMethod = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface RCMethodModel : NSObject

@property(nonatomic,copy)NSString *methodName;
@property(nonatomic,assign)int argumentCount;
@property(nonatomic,assign)RCMethodType methodType;
@end

NS_ASSUME_NONNULL_END
