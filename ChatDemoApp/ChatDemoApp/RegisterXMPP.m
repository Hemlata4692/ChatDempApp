//
//  RegisterXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "RegisterXMPP.h"

@interface RegisterXMPP ()

@end

@implementation RegisterXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidRegister:) name:@"XMPPDidRegisterResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotRegister:) name:@"XMPPDidNotRegisterResponse" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)UserDidRegister:(NSNotification *)notification {
    
    [self UserDidRegister];
}

- (void)UserNotRegister:(NSNotification *)notification {
    
    if([[notification object] intValue]==XMPP_UserExist){
        
        [self UserDidNotRegister:XMPP_UserExist];
    }
    else if(([[notification object] intValue]==XMPP_InvalidUserName)){
        //This error is called when your Name is as username
        [self UserDidNotRegister:XMPP_InvalidUserName];
    }
    else {
        [self UserDidNotRegister:XMPP_OtherError];
    }
}

- (void)UserDidRegister {

}

- (void)UserDidNotRegister:(ErrorType)errorType {

}

- (void)setXMPPProfilePhotoPlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView {

    UIImage* placeholderImage = [UIImage imageNamed:profilePlaceholder];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView);
    
    AppDelegateObjectFile *appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        appDelegate.userProfileImageDataValue=nil;
    }
    else {
        appDelegate.userProfileImageDataValue = UIImageJPEGRepresentation(profileImageView, 1.0);
    }
}

- (void)userRegistrationPassword:(NSString *)userPassword name:(NSString*)name email:(NSString*)email phone:(NSString*)phone {
    
     AppDelegateObjectFile *appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName]; // OR
    NSString *password = userPassword;
    AppDelegateObjectFile *del = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    del.xmppStream.myJID = [XMPPJID jidWithString:username];
    if (del.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        
        if (![name isEqualToString:@""]&&![email isEqualToString:@""]&&![phone isEqualToString:@""]) {
            if (![del.xmppStream registerWithPassword:password name:name email:email phone:phone error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([name isEqualToString:@""]&&[email isEqualToString:@""]) {
            if (![del.xmppStream registerWithPassword:password error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([email isEqualToString:@""]) {
            if (![del.xmppStream registerWithPassword:password name:name error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else {
            [self UserDidNotRegister:XMPP_OtherError];
        }
    }
    else {
        [self UserDidNotRegister:XMPP_OtherError];
        NSLog(@"Inband registration failed.");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
