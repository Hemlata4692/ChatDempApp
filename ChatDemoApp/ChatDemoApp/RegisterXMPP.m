//
//  RegisterXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "RegisterXMPP.h"
#import "XMPPUserDefaultManager.h"

@interface RegisterXMPP () {
    
    AppDelegateObjectFile *appDelegate;
    NSMutableDictionary *xmppProfileData;
    NSString *xmppUserNameCredential, *xmppPasswordCredential;
    BOOL isRegisterAuthenticate;
}
@end

@implementation RegisterXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    isRegisterAuthenticate=false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RegisterUserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RegisterUserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidRegister:) name:@"XMPPDidRegisterResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotRegister:) name:@"XMPPDidNotRegisterResponse" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardSuccess) name:@"XMPPvCardTempModuleDidUpdateMyvCardSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardFail) name:@"XMPPvCardTempModuleDidUpdateMyvCardFail" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Upload XMPP profile photo at server
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
#pragma mark - end

#pragma mark - User registration at XMPP server(OpenFire)
- (void)userRegistrationPassword:(NSString *)userPassword userName:(NSString*)userName profileData:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView {
    
    xmppProfileData=[profileData mutableCopy];
    //Set image in delegate object
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
    //end
    
    NSString *name=@"";
    if (nil==[profileData objectForKey:self.xmppName]||NULL==[profileData objectForKey:self.xmppName]||([[profileData objectForKey:self.xmppName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)) {
        
        name=userName;
    }
    else {
    
        name=[[profileData objectForKey:self.xmppName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    NSString *xmppUsername = [NSString stringWithFormat:@"%@@%@",userName,appDelegate.hostName];
    NSString *password = userPassword;

    xmppUserNameCredential=xmppUsername;
    [xmppProfileData setObject:xmppUsername forKey:self.xmppRegisterId];
    xmppPasswordCredential=password;
    appDelegate.xmppStream.myJID = [XMPPJID jidWithString:xmppUsername];
    if (appDelegate.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        
        if (![self registerWithPassword:password name:name error:&error])
        {
            [self tempUserDidNotRegister:XMPP_OtherError];
        }
    }
    else {
        [self tempUserDidNotRegister:XMPP_OtherError];
        NSLog(@"Inband registration failed.");
    }
}

- (void)userRegistrationWithoutPassword:(NSString*)userName profileData:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView {
    
    xmppProfileData=[profileData mutableCopy];
    
    //Set image in delegate object
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
    //end
    
    NSString *name=@"";
    if (nil==[profileData objectForKey:self.xmppName]||NULL==[profileData objectForKey:self.xmppName]||([[profileData objectForKey:self.xmppName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)) {
        
        name=userName;
    }
    else {
        
        name=[[profileData objectForKey:self.xmppName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    NSString *xmppUsername = [NSString stringWithFormat:@"%@@%@",userName,appDelegate.hostName];
    NSString *password = appDelegate.defaultPassword;
    
    xmppUserNameCredential=xmppUsername;
    [xmppProfileData setObject:xmppUsername forKey:self.xmppRegisterId];
    xmppPasswordCredential=password;
    
    appDelegate.xmppStream.myJID = [XMPPJID jidWithString:xmppUsername];
    if (appDelegate.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        
//        [appDelegate.xmppStream registerWithPassword:password error:&error]
        if (![self registerWithPassword:password name:name error:&error])
        {
            
            [self tempUserDidNotRegister:XMPP_OtherError];
        }
    }
    else {
        [self tempUserDidNotRegister:XMPP_OtherError];
        NSLog(@"Inband registration failed.");
    }
}

- (BOOL)registerWithPassword:(NSString *)password name:(NSString *)name error:(NSError **)errPtr
{
    //    XMPPLogTrace();
    
    __block BOOL result = YES;
    __block NSError *err = nil;
    
    //    dispatch_block_t block = ^{ @autoreleasepool {
    
    if ( myDelegate.xmppStream.myJID == nil)
    {
        NSString *errMsg = @"You must set myJID before calling registerWithPassword:error:.";
        NSDictionary *info = @{NSLocalizedDescriptionKey : errMsg};
        
        err = [NSError errorWithDomain:XMPPStreamErrorDomain code:XMPPStreamInvalidProperty userInfo:info];
        
        result = NO;
        //            return_from_block;
    }
    
    NSString *username = [myDelegate.xmppStream.myJID user];
    
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:username]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:password]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:name]];
    
    [myDelegate.xmppStream registerWithElements:elements error:errPtr];
    return result;
}
#pragma mark - end

#pragma mark - XMPP conection after user registration successfull
- (void)xmppConnect {

    if ([XMPPUserDefaultManager getValue:@"CountData"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [XMPPUserDefaultManager setValue:countData key:@"CountData"];
    }
    if ([XMPPUserDefaultManager getValue:@"BadgeCount"] == nil) {
        [XMPPUserDefaultManager setValue:@"0" key:@"BadgeCount"];
    }
    
    [appDelegate disconnect];
//    NSString *username = xmppUserNameCredential; // OR
    NSString *password = xmppPasswordCredential;
    [XMPPUserDefaultManager setValue:xmppUserNameCredential key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:password key:@"PassCred"];
    [XMPPUserDefaultManager setValue:@"1" key:@"CountValue"];
    [appDelegate connect];
}

- (void)xmppConnectWithoutPassword:(NSString *)phone
{
    if ([XMPPUserDefaultManager getValue:@"CountData"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [XMPPUserDefaultManager setValue:countData key:@"CountData"];
    }
    if ([XMPPUserDefaultManager getValue:@"BadgeCount"] == nil) {
        [XMPPUserDefaultManager setValue:@"0" key:@"BadgeCount"];
    }
    
    [appDelegate disconnect];
    NSString *username = [NSString stringWithFormat:@"%@@%@",phone,appDelegate.hostName]; // OR
    NSString *password = appDelegate.defaultPassword;
    [XMPPUserDefaultManager setValue:username key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:password key:@"PassCred"];
    [XMPPUserDefaultManager setValue:@"1" key:@"CountValue"];
    [appDelegate connect];
}
#pragma mark - end

#pragma mark - Login user after registration
- (void)loginRegisteredUser {

    isRegisterAuthenticate=false;
    [self xmppConnect];
}
#pragma mark - end

#pragma mark - Post notification called method
- (void)UserDidRegister:(NSNotification *)notification {
    
    isRegisterAuthenticate=true;
    [self xmppConnect];
}

- (void)UserNotRegister:(NSNotification *)notification {
    
    if([[notification object] intValue]==XMPP_UserExist){
        
        [self tempUserDidNotRegister:XMPP_UserExist];
    }
    else if(([[notification object] intValue]==XMPP_InvalidUserName)){
        //This error is called when your Name is as username
        [self tempUserDidNotRegister:XMPP_InvalidUserName];
    }
    else {
        [self tempUserDidNotRegister:XMPP_OtherError];
    }
}

- (void)tempUserDidNotRegister:(ErrorType)errorType {
    
    xmppUserNameCredential=[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName];
    xmppPasswordCredential=@"password";
    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager setValue:@"password" key:@"PassCred"];
    
    appDelegate.userProfileImageDataValue=nil;
    [self UserDidNotRegister:errorType];
}

//These method is called to subViewController of RegisterXMPP file
- (void)UserDidRegister {}
- (void)UserDidNotRegister:(ErrorType)errorType {}
//end

- (void)RegisterUserDidAuthenticated {

    if (nil!=[XMPPUserDefaultManager getValue:@"LoginCred"] && ![[XMPPUserDefaultManager getValue:@"LoginCred"] isEqualToString:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName]]) {
        
        if (isRegisterAuthenticate) {
            [appDelegate methodCalling:xmppProfileData];
        }
        else {
            [self loginUserDidAuthenticatedResult];
        }
    }
    else {
        [self UserDidRegister];
    }
}

- (void)RegisterUserNotAuthenticated {
    
    if (nil!=[XMPPUserDefaultManager getValue:@"LoginCred"] && ![[XMPPUserDefaultManager getValue:@"LoginCred"] isEqualToString:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName]]) {
        
                [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName] key:@"LoginCred"];
                [XMPPUserDefaultManager setValue:@"password" key:@"PassCred"];
        
        [self UserDidNotRegister:XMPP_OtherError];
    }
    else {
        [self UserDidRegister];
    }
}

//These method is called to subViewController of RegisterXMPP file
- (void)loginUserDidAuthenticatedResult {}
- (void)loginUserNotAuthenticatedResult{}
//end

- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccess {
    
    NSLog(@"success ");
//    [appDelegate disconnect];
    if (nil!=[XMPPUserDefaultManager getValue:@"LoginCred"] && ![[XMPPUserDefaultManager getValue:@"LoginCred"] isEqualToString:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName]]) {
         [appDelegate disconnect];
        [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",appDelegate.hostName] key:@"LoginCred"];
        [XMPPUserDefaultManager setValue:@"password" key:@"PassCred"];
        
        [appDelegate connect];
    }
}

- (void)XMPPvCardTempModuleDidUpdateMyvCardFail {
    NSLog(@"fail ");
    
    //This code is used to delete currently logined user
     NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
     [query addChild:[NSXMLElement elementWithName:@"remove"]];
     
     NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
     [iq addAttributeWithName:@"type" stringValue:@"set"];
     [iq addAttributeWithName:@"id" stringValue:@"unreg1"];
     [iq addChild:query];
     [[appDelegate xmppStream] sendElement:iq];
     //end
    
    [self UserDidNotRegister:XMPP_OtherError];
}
#pragma mark - end

#pragma mark - Set static value
- (NSString *)xmppRegisterId {
    return @"xmppRegisterId";
}

- (NSString *)xmppName {
    return @"xmppName";
}

- (NSString *)xmppPhoneNumber {
    return @"xmppPhoneNumber";
}

- (NSString *)xmppUserStatus {
    return @"xmppUserStatus";
}

- (NSString *)xmppDescription {
    return @"xmppDescription";
}

- (NSString *)xmppAddress {
    return @"xmppAddress";
}

- (NSString *)xmppEmailAddress {
    return @"xmppEmailAddress";
}

- (NSString *)xmppUserBirthDay {
    return @"xmppUserBirthDay";
}

- (NSString *)xmppGender {
    return @"xmppGender";
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end