//
//  ErrorCode.h
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, ErrorType){
    XMPP_UserExist,
    XMPP_InvalidUserName,
    XMPP_OtherError
};

@interface ErrorCode : NSObject

@end
