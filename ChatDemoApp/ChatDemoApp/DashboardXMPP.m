//
//  DashboardXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardXMPP.h"
#import "XMPPUserDefaultManager.h"

@interface DashboardXMPP (){
    
    AppDelegateObjectFile *appDelegate;
    BOOL isrefresh;
}
@end

@implementation DashboardXMPP
//@synthesize xmppUserDetailedList;
//@synthesize xmppUserListArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate.myView=@"DashboardXmppUserList";
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInformation) name:@"XMPPProfileUpdation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppNewUserAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppUserPresenceUpdate" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppUserListNotificationResponse) name:@"XMPPUserListResponse" object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    appDelegate.updateProfileUserId=@"";
    appDelegate.xmppLogedInUserId=[XMPPUserDefaultManager getValue:@"LoginCred"];
//    isrefresh=YES;
//    if ([myDelegate connect])
//    {
//        [self fetchedResultsController];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User logout
- (void)userLogout {
    
    [appDelegate disconnect];
    appDelegate.myView=@"";
    appDelegate.xmppLogedInUserId=@"";
    [XMPPUserDefaultManager removeValue:@"LoginCred"];
    //    [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",myDelegate.hostName] key:@"LoginCred"];
    [XMPPUserDefaultManager removeValue:@"PassCred"];
    //    [appDelegate connect];
}
#pragma mark - end

#pragma mark - XMPP delegates
- (XMPPStream *)xmppStream
{
    return [myDelegate xmppStream];
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [myDelegate managedObjectContext_roster];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            //error
        }
    }
    return fetchedResultsController;
}

//- (nullable NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName API_AVAILABLE(macosx(10.12),ios(4.0)) {
//
//    NSArray *sections1 = controller.fetchedObjects;
//    if ([appDelegate.myView isEqualToString:@"XmppLoginUser"] && [controller.fetchedObjects count]>0) {
//        
//        if (isrefresh) {
//            
//            NSMutableDictionary *xmppUserDetailedListTemp=[NSMutableDictionary new];
//            NSMutableArray *xmppUserListArrayTemp=[NSMutableArray new];
//            NSArray *sections = controller.fetchedObjects;
//            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
//            NSArray *results = [sections
//                                sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
//            for (int i=0; i<results.count; i++) {
//                [xmppUserListArrayTemp addObject:[[sections objectAtIndex:i] jidStr]];
//                [xmppUserDetailedListTemp setObject:[sections objectAtIndex:i] forKey:[[sections objectAtIndex:i] jidStr]];
//            }
//            NSLog(@"%@",sections);
//            xmppUserListArray=[xmppUserListArrayTemp mutableCopy];
//            xmppUserDetailedList=[xmppUserDetailedListTemp mutableCopy];
//            isrefresh=false;
//        }
//    }
//
//    return @"";
//}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if ([controller.fetchedObjects count]>0 && isrefresh) {
        
        NSMutableDictionary *xmppUserDetailedListTemp=[NSMutableDictionary new];
        NSMutableArray *xmppUserListArrayTemp=[NSMutableArray new];
        NSArray *sections = controller.fetchedObjects;
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
        NSArray *results = [sections
                            sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        for (int i=0; i<results.count; i++) {
            [xmppUserListArrayTemp addObject:[[results objectAtIndex:i] jidStr]];
            [xmppUserDetailedListTemp setObject:[results objectAtIndex:i] forKey:[[results objectAtIndex:i] jidStr]];
        }
        appDelegate.xmppUserListArray=[xmppUserListArrayTemp mutableCopy];
        appDelegate.xmppUserDetailedList=[xmppUserDetailedListTemp mutableCopy];
        isrefresh=false;
        appDelegate.myView=@"XmppNewUserAdded";
        [self xmppUserListResponse:appDelegate.xmppUserDetailedList xmppUserListIds:appDelegate.xmppUserListArray];
    }
}
#pragma mark - end

#pragma mark - Post notification action
- (void)updateProfileInformation {}
- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds {}
#pragma mark - end

- (void)xmppNewUserAddedNotify {}

- (void)xmppUserRefreshResponse {

    isrefresh=true;
//    appDelegate.myView=@"Other";
    [myDelegate disconnect];
    if ([myDelegate connect])
    {
        [self fetchedResultsController];
    }
}

- (void)xmppUserConnect {
    
    isrefresh=true;
    [myDelegate disconnect];
    if ([myDelegate connect])
    {
        [self fetchedResultsController];
    }
}

- (NSDictionary *)getProfileData:(NSString *)jid {
    
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
