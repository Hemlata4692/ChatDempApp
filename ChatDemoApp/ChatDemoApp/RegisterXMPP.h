//
//  RegisterXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorCode.h"

@interface RegisterXMPP : UIViewController

//This method will be called when password is  required
- (void)userRegistrationPassword:(NSString *)userPassword name:(NSString*)name email:(NSString*)email phone:(NSString*)phone;
//This method will be called when password is not required
- (void)userRegistrationWithoutPassword:(NSString*)name email:(NSString*)email phone:(NSString*)phone;
//This method will be used for uploading profile photo
- (void)setXMPPProfilePhotoPlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView;

//This method will be used for user registeration response
-(void)UserDidRegister;
-(void)UserDidNotRegister:(ErrorType)errorType;

//This method will be used to connect XMPP with registered user
- (void)xmppConnect:(NSString *)phone password:(NSString *)password;
- (void)xmppConnectWithoutPassword:(NSString *)phone;

@end
