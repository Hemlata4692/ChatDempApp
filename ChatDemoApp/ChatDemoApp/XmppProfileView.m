//
//  XmppProfileView.m
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XmppProfileView.h"
#import "XMPPUserDefaultManager.h"

@interface XmppProfileView (){
    
    AppDelegateObjectFile *appDelegate;
}

@end

@implementation XmppProfileView

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XmppUserPresenceUpdateNotify) name:@"XmppUserPresenceUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XmppFriendProileUpdateNotify) name:@"FriendProfileUpdated" object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)initializeFriendProfile:(NSString*)jid {
    
    appDelegate.updateProfileUserId=jid;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    appDelegate.updateProfileUserId=@"";
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Post notification called method
- (void)XmppUserPresenceUpdateNotify {}
- (void)XmppFriendProileUpdateNotify {}

- (UIImage *)getFriendProfilePhoto:(NSString *)jid {

    NSData *photoData = [[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jid]];
    return [UIImage imageWithData:photoData];
}

- (int)getFriendPresenceStatus:(NSString *)jid {
    
    XMPPUserCoreDataStorageObject *user=[appDelegate.xmppUserDetailedList objectForKey:jid];
    return [user.sectionNum intValue];
}

- (NSDictionary *)getFriendProfileData:(NSString *)jid {
    
    appDelegate.updateProfileUserId=jid;
    [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];

    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *pred;
    NSMutableArray *results = [[NSMutableArray alloc]init];
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@",jid];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    
    results = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSDictionary *profileResponse;
    if (results.count>0) {
        NSManagedObject *devicea = [results objectAtIndex:0];
        profileResponse=@{
                          @"RegisterId" : [devicea valueForKey:@"xmppRegisterId"],
                          @"Name" : [devicea valueForKey:@"xmppName"],
                          @"PhoneNumber" : [devicea valueForKey:@"xmppPhoneNumber"],
                          @"UserStatus" : [devicea valueForKey:@"xmppUserStatus"],
                          @"Description" : [devicea valueForKey:@"xmppDescription"],
                          @"Address" : [devicea valueForKey:@"xmppAddress"],
                          @"EmailAddress" : [devicea valueForKey:@"xmppEmailAddress"],
                          @"UserBirthDay" : [devicea valueForKey:@"xmppUserBirthDay"],
                          @"Gender" : [devicea valueForKey:@"xmppGender"],
                          };
        NSLog(@"\n\n");
    }
    return profileResponse;
}
#pragma mark - end

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
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
