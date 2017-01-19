//
//  RegisterXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "RegisterXMPP.h"

@interface RegisterXMPP () {
    
    AppDelegateObjectFile *appDelegate;
}
@end

@implementation RegisterXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    
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

- (void)UserDidRegister {}
- (void)UserDidNotRegister:(ErrorType)errorType {}

- (void)setXMPPProfilePhotoPlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView {

    UIImage* placeholderImage = [UIImage imageNamed:profilePlaceholder];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImageView);
 
    if ([profileImageData isEqualToData:placeholderImageData])
    {
        appDelegate.userProfileImageDataValue=nil;
    }
    else {
        appDelegate.userProfileImageDataValue = UIImageJPEGRepresentation(profileImageView, 1.0);
    }
}

- (void)userRegistrationPassword:(NSString *)userPassword name:(NSString*)name email:(NSString*)email phone:(NSString*)phone {
    
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName];
    
    NSString *password = userPassword;

    appDelegate.xmppStream.myJID = [XMPPJID jidWithString:username];
    if (appDelegate.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        
        if (![name isEqualToString:@""]&&![email isEqualToString:@""]&&![phone isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password name:name email:email phone:phone error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([name isEqualToString:@""]&&[email isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([email isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password name:name error:&error])
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

- (void)userRegistrationWithoutPassword:(NSString*)name email:(NSString*)email phone:(NSString*)phone {
    
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName];
    NSString *password = appDelegate.defaultPassword;
    
    appDelegate.xmppStream.myJID = [XMPPJID jidWithString:username];
    if (appDelegate.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        
        if (![name isEqualToString:@""]&&![email isEqualToString:@""]&&![phone isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password name:name email:email phone:phone error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([name isEqualToString:@""]&&[email isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password error:&error])
            {
                [self UserDidNotRegister:XMPP_OtherError];
            }
        }
        else if ([email isEqualToString:@""]) {
            if (![appDelegate.xmppStream registerWithPassword:password name:name error:&error])
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

- (void)xmppConnect:(NSString *)phone password:(NSString *)passwordtext
{

    [self setValue:phone key:@"userName"];
    if ([self getValue:@"CountData"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [self setValue:countData key:@"CountData"];
    }
    if ([self getValue:@"BadgeCount"] == nil) {
        [self setValue:@"0" key:@"BadgeCount"];
    }
    
    [appDelegate disconnect];
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName]; // OR
    NSString *password = passwordtext;
    [self setValue:username key:@"LoginCred"];
    [self setValue:password key:@"PassCred"];
    [self setValue:@"1" key:@"CountValue"];
    [appDelegate connect];
}

- (void)xmppConnectWithoutPassword:(NSString *)phone
{
    
    [self setValue:phone key:@"userName"];
    if ([self getValue:@"CountData"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [self setValue:countData key:@"CountData"];
    }
    if ([self getValue:@"BadgeCount"] == nil) {
        [self setValue:@"0" key:@"BadgeCount"];
    }
    
    [appDelegate disconnect];
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName]; // OR
    NSString *password = appDelegate.defaultPassword;
    [self setValue:username key:@"LoginCred"];
    [self setValue:password key:@"PassCred"];
    [self setValue:@"1" key:@"CountValue"];
    [appDelegate connect];
}

//Set data in userDefault
- (void)setValue:(id)value key:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//Fetch data in userDefault
- (id)getValue:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

//Remove data in userDefault
- (void)removeValue:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
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
