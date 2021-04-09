//
//  RCTagProtocol.h
//  RongIMLib
//
//  Created by 张改红 on 2021/1/27.
//  Copyright © 2021 RongCloud. All rights reserved.
//

#ifndef RCTagProtocol_h
#define RCTagProtocol_h

@protocol RCTagDelegate <NSObject>

- (void)onTagChanged;

@end


@protocol RCConversationTagDelegate <NSObject>

- (void)onConversationTagChanged;

@end
#endif /* RCTagProtocol_h */
