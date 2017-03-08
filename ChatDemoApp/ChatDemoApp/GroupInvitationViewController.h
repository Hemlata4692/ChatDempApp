//
//  GroupInvitationViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPGroupChatRoom.h"

@interface GroupInvitationViewController : XMPPGroupChatRoom

@property(nonatomic, retain)NSString *roomSubject;
@property(nonatomic, retain)NSString *roomDescription;
@property(nonatomic, retain)NSString *roomNickname;
@property(nonatomic, retain)UIImage *friendImage;
@end
