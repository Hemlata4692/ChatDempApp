//
//  LoginXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginXMPP : UIViewController

//This method will be called when password is not required
- (void)loginConnectWithoutPassword:(NSString *)username;
//This method will be called when password is required
- (void)loginConnectPassword:(NSString *)password username:(NSString *)username;

//This method will be used for login authentication response
- (void)loginUserDidAuthenticatedResult;
- (void)loginUserNotAuthenticatedResult;
@end
