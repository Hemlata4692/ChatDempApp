//
//  LoginXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginXMPP : UIViewController

- (void)loginConnectWithoutPassword:(NSString *)username;
- (void)loginConnectPassword:(NSString *)password username:(NSString *)username;
- (void)UserDidAuthenticatedResult;
- (void)UserNotAuthenticatedResult;
- (void)userLogout;
@end
