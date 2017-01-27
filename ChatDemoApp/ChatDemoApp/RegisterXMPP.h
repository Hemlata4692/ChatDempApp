//
//  RegisterXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorCode.h"

@interface RegisterXMPP : UIViewController<XMPPStreamDelegate>

@property(nonatomic,readonly) NSString *xmppRegisterId;
@property(nonatomic,readonly) NSString *xmppName;
@property(nonatomic,readonly) NSString *xmppPhoneNumber;
@property(nonatomic,readonly) NSString *xmppUserStatus;
@property(nonatomic,readonly) NSString *xmppDescription;
@property(nonatomic,readonly) NSString *xmppAddress;
@property(nonatomic,readonly) NSString *xmppEmailAddress;
@property(nonatomic,readonly) NSString *xmppUserBirthDay;
@property(nonatomic,readonly) NSString *xmppGender;

//This method will be called when password is  required
- (void)userRegistrationPassword:(NSString *)userPassword userName:(NSString*)userName profileData:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView;
//This method will be called when password is not required
- (void)userRegistrationWithoutPassword:(NSString*)userName profileData:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView;

//This method will be used for user registeration response
-(void)UserDidRegister;
-(void)UserDidNotRegister:(ErrorType)errorType;

//This method will be used to connect XMPP with registered user
- (void)xmppConnect;
- (void)xmppConnectWithoutPassword:(NSString *)phone;

@end
