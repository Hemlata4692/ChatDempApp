//
//  XmppProfileView.m
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XmppProfileView.h"
#import "XMPPUserDefaultManager.h"
#import "XmppCoreDataHandler.h"

@interface XmppProfileView (){
    
    AppDelegateObjectFile *appDelegate;
    NSMutableDictionary *xmppProfileUpdationData;
}
@end

@implementation XmppProfileView

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XmppUserPresenceUpdateNotify) name:@"XmppUserPresenceUpdate" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XmppProileUpdateNotify) name:@"XMPPProfileUpdation" object:nil];
    
    //vCard update post notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardSuccess) name:@"XMPPvCardTempModuleDidUpdateMyvCardSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardFail) name:@"XMPPvCardTempModuleDidUpdateMyvCardFail" object:nil];
}

- (void)initializeFriendProfile:(NSString*)jid {
    
    appDelegate.selectedFriendUserId=jid;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    appDelegate.selectedFriendUserId=@"";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Post notification called method
- (void)XmppUserPresenceUpdateNotify {}
- (void)XmppProileUpdateNotify {}

- (void)getProfilePhoto:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
    }
    else {
        profileImageView.image=[UIImage imageWithData:tempImageData];
    }
    
    dispatch_queue_t queue = dispatch_queue_create("profilePhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       UIImage *tempPhoto=[UIImage imageWithData:[[appDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jid]]];
                       if (tempPhoto!=nil) {
                           [appDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:appDelegate.appProfilePhotofolderName jid:jid];
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                            completion(tempPhoto);
                       });
                   });
}

- (int)getPresenceStatus:(NSString *)jid {
    
    if (appDelegate.xmppUserDetailedList==nil || appDelegate.xmppUserDetailedList.count==0) {

        NSMutableDictionary *temp=[XMPPUserDefaultManager getValue:@"xmppUserDetailedList"];
        return [[temp objectForKey:jid] intValue];
    }
    else {
        
        XMPPUserCoreDataStorageObject *user=[appDelegate.xmppUserDetailedList objectForKey:jid];
        return [user.sectionNum intValue];
    }
}

- (void)getProfileData:(NSString *)jid result:(void(^)(NSDictionary *tempProfileData)) completion {
    
    appDelegate.selectedFriendUserId=jid;
    dispatch_queue_t queue = dispatch_queue_create("profileDataQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       NSDictionary *tempDic=[self getProfileDicData:jid];
//                       if (nil==tempDic) {
                           [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];
//                       }
//                       NSDictionary *tempDic=[self getProfileDicData:jid];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(tempDic);
                       });
                   });
}

- (void)getEditProfileData:(NSString *)jid result:(void(^)(NSDictionary *tempProfileData)) completion {
    
     appDelegate.selectedFriendUserId=jid;
    dispatch_queue_t queue = dispatch_queue_create("profileDataQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       NSDictionary *tempDic=[self getProfileDicData:jid];
                       if (nil==tempDic) {
                           [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];
                           tempDic=@{
                                     @"RegisterId" : jid,
                                     @"Name" : @"loding..",
                                     @"PhoneNumber" : @"loding..",
                                     @"UserStatus" : @"loding..",
                                     @"Description" : @"loding..",
                                     @"Address" : @"loding..",
                                     @"EmailAddress" : @"loding..",
                                     @"UserBirthDay" : @"loding..",
                                     @"Gender" : @""
                                     };
                       }

                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(tempDic);
                       });
                   });
}

- (void)saveUpdatedImage:(UIImage *)profileImage placeholderImageName:(NSString *)placeholderImageName jid:(NSString *)jid {

    UIImage* placeholderImage = [UIImage imageNamed:placeholderImageName];
    NSData *placeholderImageData = UIImagePNGRepresentation(placeholderImage);
    NSData *profileImageData = UIImagePNGRepresentation(profileImage);
    
    if (![profileImageData isEqualToData:placeholderImageData])
    {
        [appDelegate saveDataInCacheDirectory:(UIImage *)profileImage folderName:appDelegate.appProfilePhotofolderName jid:jid];
    }
}

- (NSDictionary *)getProfileDicData:(NSString *)jid {
    
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSPredicate *pred;
//    NSMutableArray *results = [[NSMutableArray alloc]init];
//    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@",jid];
//    NSLog(@"predicate: %@",pred);
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
//    [fetchRequest setPredicate:pred];
//    
//    results = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    NSDictionary *profileResponse;
//    if (results.count>0) {
//        NSManagedObject *devicea = [results objectAtIndex:0];
//        profileResponse=@{
//                          @"RegisterId" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppRegisterId"]],
//                          @"Name" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppName"]],
//                          @"PhoneNumber" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppPhoneNumber"]],
//                          @"UserStatus" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppUserStatus"]],
//                          @"Description" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppDescription"]],
//                          @"Address" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppAddress"]],
//                          @"EmailAddress" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppEmailAddress"]],
//                          @"UserBirthDay" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppUserBirthDay"]],
//                          @"Gender" : [appDelegate checkNilValue:[devicea valueForKey:@"xmppGender"]],
//                          };
//        NSLog(@"\n\n");
//    }
    return [[XmppCoreDataHandler sharedManager] getProfileDicData:jid];
}
#pragma mark - end

#pragma mark - User registration at XMPP server(OpenFire)
- (void)userUpdateProfileUsingVCard:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView {
    
    appDelegate.selectedFriendUserId=appDelegate.xmppLogedInUserId;
    [profileData setObject:appDelegate.xmppLogedInUserId forKey:self.xmppRegisterId];
    xmppProfileUpdationData=[profileData mutableCopy];
    [self setXMPPProfilePhotoPlaceholder:profilePlaceholder profileImageView:profileImageView];
    //end
    
    [appDelegate editProfileImageUploading:profileData];
}


#pragma mark - Set XMPP profile photo at appdelegate variable
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

- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccess {
    
    //Set presence
//        XMPPPresence *presence = [XMPPPresence presence];
//        NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
//        [status setStringValue:@"online/unavailable/away/busy/invisible"];
//        [presence addChild:status];
//        [[appDelegate xmppStream] sendElement:presence];
//    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
//    NSXMLElement *updateText = [NSXMLElement elementWithName:@"isUpdateText" stringValue:@"1"];
//    [presence addChild:updateText];
//    [presence removeElementForName:@"isUpdateText"];
//    
//    NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
//    [presence addChild:priority];
//    
//    [[appDelegate xmppStream] sendElement:presence];
//    //end
    
    [[XmppCoreDataHandler sharedManager] insertEntryInXmppUserModel:[xmppProfileUpdationData objectForKey:@"xmppRegisterId"] xmppName:[xmppProfileUpdationData objectForKey:@"xmppName"] xmppPhoneNumber:[xmppProfileUpdationData objectForKey:@"xmppPhoneNumber"] xmppUserStatus:[xmppProfileUpdationData objectForKey:@"xmppUserStatus"] xmppDescription:[xmppProfileUpdationData objectForKey:@"xmppDescription"] xmppAddress:[xmppProfileUpdationData objectForKey:@"xmppAddress"] xmppEmailAddress:[xmppProfileUpdationData objectForKey:@"xmppEmailAddress"] xmppUserBirthDay:[xmppProfileUpdationData objectForKey:@"xmppUserBirthDay"] xmppGender:[xmppProfileUpdationData objectForKey:@"xmppGender"]];
    [self XMPPvCardTempModuleDidUpdateMyvCardSuccessResponse];
}

- (void)XMPPvCardTempModuleDidUpdateMyvCardFail {
    
    [self XMPPvCardTempModuleDidUpdateMyvCardFailResponse];
}

- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccessResponse {};
- (void)XMPPvCardTempModuleDidUpdateMyvCardFailResponse {};
#pragma mark - end

//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

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
