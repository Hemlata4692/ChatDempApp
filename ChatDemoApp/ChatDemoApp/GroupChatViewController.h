//
//  GroupChatViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPGroupChatRoom.h"

@interface GroupChatViewController : XMPPGroupChatRoom

@property(nonatomic, retain)NSMutableDictionary *roomDetail;
@end
