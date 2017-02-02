//
//  UserProfileViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmppProfileView.h"

@interface UserProfileViewController : XmppProfileView

@property(nonatomic, strong)NSString *friendId;
@end
