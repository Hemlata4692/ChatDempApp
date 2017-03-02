//
//  GroupChatXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 28/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPUserDefaultManager.h"

@interface GroupChatXMPP : UIViewController

- (void)createChatRoom:(UIImage *)image;
- (void)updateChatRoom:(UIImage *)image;
- (void)fetchList;
- (void)deleteBookmark;
- (void)joinChatRoom:(NSString *)roomJidString;
@end
