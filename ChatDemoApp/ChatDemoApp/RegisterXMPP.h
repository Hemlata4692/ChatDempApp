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

-(void)UserDidRegister;
-(void)UserDidNotRegister:(ErrorType)errorType;
- (void)userRegistrationPassword:(NSString *)userPassword name:(NSString*)name email:(NSString*)email phone:(NSString*)phone ;
- (void)setXMPPProfilePhotoPlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView;
@end
