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
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    appDelegate.myView=@"DashboardXmppUserList";
    appDelegate.isContactListIsLoaded=NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppUserListNotificationResponse) name:@"XMPPUserListResponse" object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInformation) name:@"XMPPProfileUpdation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppNewUserAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppUserPresenceUpdate" object:nil];
    
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
    appDelegate.isContactListIsLoaded=NO;
    appDelegate.xmppLogedInUserId=@"";
    appDelegate.xmppLogedInUserName=@"";
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
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"sectionNum" cacheName:nil];
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
        appDelegate.isContactListIsLoaded=YES;
        [self xmppUserListResponse:appDelegate.xmppUserDetailedList xmppUserListIds:appDelegate.xmppUserListArray];
    }
}
#pragma mark - end

#pragma mark - Post notification action
- (void)updateProfileInformation {}
- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds {}

- (void)UserDidAuthenticated {
    
//    if ([myDelegate connect])
//    {
        [self fetchedResultsController];
//    }
}

- (void)UserNotAuthenticated {
    
    
}

#pragma mark - end

- (void)xmppNewUserAddedNotify {}

- (void)xmppUserRefreshResponse {

    isrefresh=true;
    appDelegate.isContactListIsLoaded=NO;
//    appDelegate.myView=@"Other";
    [myDelegate disconnect];
    myDelegate.afterAutentication=1;
    if ([myDelegate connect])
    {
        [self fetchedResultsController];
    }
}

- (void)xmppUserConnect {
    
    isrefresh=true;
    [myDelegate disconnect];
    myDelegate.afterAutentication=1;
    if ([myDelegate connect])
    {
//        [self fetchedResultsController];
    }
}

- (void)getProfileData:(NSString *)jid result:(void(^)(NSDictionary *tempProfileData)) completion {
    
//    appDelegate.updateProfileUserId=jid;
    dispatch_queue_t queue = dispatch_queue_create("profileDataQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
//                       [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];
                       NSDictionary *tempDic=[self getProfileDicData:jid];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(tempDic);
                       });
                   });
}

- (void)getProfileData1:(void(^)(NSDictionary *tempProfileData)) completion {
    
    //    appDelegate.updateProfileUserId=jid;
    dispatch_queue_t queue = dispatch_queue_create("profileData1Queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       //                       [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];
                       NSMutableDictionary *tempDic=[self getProfileUsersData];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(tempDic);
                       });
                   });
}

- (NSDictionary *)getProfileDicData:(NSString *)jid {
    
//    appDelegate.updateProfileUserId=jid;
//    [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:jid] ignoreStorage:YES];
    
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
        NSManagedObject *tempDevice = [results objectAtIndex:0];
        profileResponse=@{
                          @"RegisterId" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppRegisterId"]],
                          @"Name" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppName"]],
                          @"PhoneNumber" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppPhoneNumber"]],
                          @"UserStatus" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppUserStatus"]],
                          @"Description" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppDescription"]],
                          @"Address" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppAddress"]],
                          @"EmailAddress" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppEmailAddress"]],
                          @"UserBirthDay" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppUserBirthDay"]],
                          @"Gender" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppGender"]],
                          };
        NSLog(@"\n\n");
    }
//    else {
//        profileResponse=@{
//                          @"RegisterId" : jid,
//                          @"Name" : @"",
//                          @"PhoneNumber" : @"",
//                          @"UserStatus" : @"",
//                          @"Description" : @"",
//                          @"Address" : @"",
//                          @"EmailAddress" : @"",
//                          @"UserBirthDay" : @"",
//                          @"Gender" : @"",
//                          };
//
//    }
    return profileResponse;
}

- (NSMutableDictionary *)getProfileUsersData {
    
    NSMutableDictionary *tempDict=[NSMutableDictionary new];
    NSMutableArray *tempArray=[NSMutableArray new];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
    tempArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject *tempDevice in tempArray) {
        if (![[tempDevice valueForKey:@"xmppRegisterId"] isEqualToString:appDelegate.xmppLogedInUserId]) {
            NSDictionary *profileResponse=@{
                              @"RegisterId" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppRegisterId"]],
                              @"Name" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppName"]],
                              @"PhoneNumber" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppPhoneNumber"]],
                              @"UserStatus" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppUserStatus"]],
                              @"Description" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppDescription"]],
                              @"Address" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppAddress"]],
                              @"EmailAddress" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppEmailAddress"]],
                              @"UserBirthDay" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppUserBirthDay"]],
                              @"Gender" : [appDelegate checkNilValue:[tempDevice valueForKey:@"xmppGender"]],
                              };
            [tempDict setObject:profileResponse forKey:[tempDevice valueForKey:@"xmppRegisterId"]];
        }
        else {
        
            appDelegate.xmppLogedInUserName=[appDelegate checkNilValue:[tempDevice valueForKey:@"xmppName"]];
        }
    }
    
    return tempDict;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
        dispatch_queue_t queue = dispatch_queue_create("profilePhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async(queue, ^
                       {
                           UIImage *tempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jid]]];
                           if (tempPhoto!=nil) {
                               [appDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:appDelegate.appProfilePhotofolderName jid:jid];
                           }
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               completion(tempPhoto);
                           });
                       });
    }
    else {
        completion([UIImage imageWithData:tempImageData]);
    }
}

#pragma mark - Fetch chat history
- (void)fetchAllHistoryChat:(void(^)(NSMutableArray *tempHistoryData)) completion {

    NSManagedObjectContext *moc = [myDelegate.xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *messages_arc = [moc executeFetchRequest:request error:&error];
    
    NSMutableArray *historyArray=[NSMutableArray new];
    NSMutableArray *tempArray=[NSMutableArray new];
    NSMutableDictionary *tempDict=[NSMutableDictionary new];

    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            if (![[element attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                
                if ([tempArray containsObject:[element attributeStringValueForName:@"from"]]) {
                    
                    [tempArray removeObject:[element attributeStringValueForName:@"from"]];
                }
                [tempArray addObject:[element attributeStringValueForName:@"from"]];
                [tempDict setObject:element forKey:[element attributeStringValueForName:@"from"]];
            }
            else {
                
                if ([tempArray containsObject:[element attributeStringValueForName:@"to"]]) {
                    
                    [tempArray removeObject:[element attributeStringValueForName:@"to"]];
                }
                [tempArray addObject:[element attributeStringValueForName:@"to"]];
                [tempDict setObject:element forKey:[element attributeStringValueForName:@"to"]];
            }
        }
        
        for (int i=0; i<tempArray.count; i++) {
            [historyArray addObject:[tempDict objectForKey:[tempArray objectAtIndex:i]]];
        }
        historyArray=[[[historyArray reverseObjectEnumerator] allObjects] mutableCopy];
        completion(historyArray);
    }
//    [self print:[[NSMutableArray alloc]initWithArray:messages_arc]];
    
}

-(void)getHistoryData{
    
}

/*
-(void)print:(NSMutableArray*)messages_arc{
    NSMutableArray *tempArray = [NSMutableArray new];
    int i = 0;
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            if ( [[element attributeStringValueForName:@"ToName"] caseInsensitiveCompare:[UserDefaultManager getValue:@"userName"]] == NSOrderedSame) {
                if ([tempArray containsObject:[[element attributeStringValueForName:@"Name"] lowercaseString]]) {
                    i = (int)[tempArray indexOfObject:[[element attributeStringValueForName:@"Name"] lowercaseString]];
                    [tempArray removeObjectAtIndex:i];
                    [historyArray removeObjectAtIndex:i];
                    [tempArray addObject:[[element attributeStringValueForName:@"Name"] lowercaseString]];
                    [historyArray addObject:element];
                }
                else{
                    [tempArray addObject:[[element attributeStringValueForName:@"Name"] lowercaseString]];
                    [historyArray addObject:element];
                }
            }
            else{
                if ([tempArray containsObject:[[element attributeStringValueForName:@"ToName"] lowercaseString]]) {
                    i = (int)[tempArray indexOfObject:[[element attributeStringValueForName:@"ToName"] lowercaseString]];
                    [tempArray removeObjectAtIndex:i];
                    [historyArray removeObjectAtIndex:i];
                    [tempArray addObject:[[element attributeStringValueForName:@"ToName"] lowercaseString]];
                    [historyArray addObject:element];
                }
                else{
                    [tempArray addObject:[[element attributeStringValueForName:@"ToName"] lowercaseString]];
                    [historyArray addObject:element];
                }
            }
        }
        historyArray=[[[historyArray reverseObjectEnumerator] allObjects] mutableCopy];
        [myDelegate stopIndicator];
        [historyTableView reloadData];
    }
}
 */
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
