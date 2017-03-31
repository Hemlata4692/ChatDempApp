//
//  DashboardXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardXMPP.h"
#import "XmppCoreDataHandler.h"

//Group chat
#import "XmppCoreDataHandler.h"
#import "NSData+XMPP.h"
//end
@interface DashboardXMPP ()<XMPPRoomDelegate>{
    
    AppDelegateObjectFile *appDelegate;
    BOOL isrefresh;
    NSMutableArray *joinAllGroups;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInformation) name:@"XMPPProfileUpdation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppNewUserAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppUserPresenceUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
    
    //Group chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPAddedNewGroup) name:@"XMPPUpdatedGroup" object:nil];
    //end
    
    //Reachability handle
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPReloadConnection) name:@"XMPPReloadConnection" object:nil];
    
    appDelegate.xmppLogedInUserId=[XMPPUserDefaultManager getValue:@"LoginCred"];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppUserListNotificationResponse) name:@"XMPPUserListResponse" object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInformation) name:@"XMPPProfileUpdation" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppNewUserAdded" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppNewUserAddedNotify) name:@"XmppUserPresenceUpdate" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
//    
//    //Group chat
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPAddedNewGroup) name:@"XMPPUpdatedGroup" object:nil];
//    //end
    
    appDelegate.selectedFriendUserId=@"";
//    appDelegate.xmppLogedInUserId=[XMPPUserDefaultManager getValue:@"LoginCred"];
    appDelegate.selectedFriendUserId=@"";
//    isrefresh=YES;
//    if ([myDelegate connect])
//    {
//        [self fetchedResultsController];
//    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPReloadConnection) name:@"XMPPReloadConnection" object:nil];
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
    return [appDelegate xmppStream];
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [appDelegate managedObjectContext_roster];
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
    
//    NSArray *sections1 = controller.fetchedObjects;
//    NSSortDescriptor *descriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
//    NSArray *results1 = [sections1
//                        sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor1]];
    
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
        
        [XMPPUserDefaultManager setValue:appDelegate.xmppUserListArray key:@"xmppUserListArray"];
        NSMutableDictionary *tempDict=[NSMutableDictionary new];
//        XMPPUserCoreDataStorageObject *user=[appDelegate.xmppUserDetailedList objectForKey:jid];
//        return [user.sectionNum intValue];
        for (int i=0; i<appDelegate.xmppUserListArray.count; i++) {
            
            [tempDict setObject:[[appDelegate.xmppUserDetailedList objectForKey:[appDelegate.xmppUserListArray objectAtIndex:i]] sectionNum] forKey:[appDelegate.xmppUserListArray objectAtIndex:i]];
        }
        [XMPPUserDefaultManager setValue:tempDict key:@"xmppUserDetailedList"];
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

- (void)UserNotAuthenticated {}

- (void)historUpdated:(NSNotification *)notification {
    
    [self historyUpdateNotify];
}

- (void)historyUpdateNotify{}
#pragma mark - end

- (void)xmppNewUserAddedNotify {}

- (void)xmppUserRefreshResponse {

    isrefresh=true;
    appDelegate.isContactListIsLoaded=NO;
//    appDelegate.myView=@"Other";
    [appDelegate disconnect];
    appDelegate.afterAutentication=1;
    if ([appDelegate connect])
    {
        [self fetchedResultsController];
    }
}

- (void)xmppUserConnect {
    
    isrefresh=true;
    [appDelegate disconnect];
    appDelegate.afterAutentication=1;
    if ([appDelegate connect])
    {
        //        [self fetchedResultsController];
    }
}

- (void)xmppOfflineUserConnect {
    
    //If net is not available
    appDelegate.xmppUserListArray=[[XMPPUserDefaultManager getValue:@"xmppUserListArray"] mutableCopy];
    appDelegate.xmppUserDetailedList=[NSMutableDictionary new];
    isrefresh=false;
    appDelegate.isContactListIsLoaded=YES;
    [self xmppUserListResponse:appDelegate.xmppUserDetailedList xmppUserListIds:appDelegate.xmppUserListArray];
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
    
    return [[XmppCoreDataHandler sharedManager] getProfileDicData:jid];
}

- (NSMutableDictionary *)getProfileUsersData {
    
    return [[XmppCoreDataHandler sharedManager] getProfileUsersData];
}

- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
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
    else {
        completion([UIImage imageWithData:tempImageData]);
    }
}

#pragma mark - Fetch chat history
- (void)fetchAllHistoryChat:(void(^)(NSMutableArray *tempHistoryData)) completion {
    
    NSArray *messages_arc = [[[XmppCoreDataHandler sharedManager] readAllLocalMessageStorageDatabase] copy];
    
    NSMutableArray *historyArray=[NSMutableArray new];
    NSMutableArray *tempArray=[NSMutableArray new];
    NSMutableDictionary *tempDict=[NSMutableDictionary new];
    
    @autoreleasepool {
        
        for (NSManagedObject *message in messages_arc) {
            
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:[message valueForKey:@"messageString"] error:nil];
            NSXMLElement *innerElementData = [element elementForName:@"data"];
            if ([[innerElementData attributeStringValueForName:@"to"] containsString:@"@conference"]) {
                
                if ([tempArray containsObject:[innerElementData attributeStringValueForName:@"to"]]) {
                    
                    [tempArray removeObject:[innerElementData attributeStringValueForName:@"to"]];
                }
                [tempArray addObject:[innerElementData attributeStringValueForName:@"to"]];
                [tempDict setObject:element forKey:[innerElementData attributeStringValueForName:@"to"]];
            }
            else if (![[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]&&[[innerElementData attributeStringValueForName:@"to"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                
                if ([tempArray containsObject:[innerElementData attributeStringValueForName:@"from"]]) {
                    
                    [tempArray removeObject:[innerElementData attributeStringValueForName:@"from"]];
                }
                [tempArray addObject:[innerElementData attributeStringValueForName:@"from"]];
                [tempDict setObject:element forKey:[innerElementData attributeStringValueForName:@"from"]];
            }
            else {
                if ([[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                    if ([tempArray containsObject:[innerElementData attributeStringValueForName:@"to"]]) {
                        
                        [tempArray removeObject:[innerElementData attributeStringValueForName:@"to"]];
                    }
                    [tempArray addObject:[innerElementData attributeStringValueForName:@"to"]];
                    [tempDict setObject:element forKey:[innerElementData attributeStringValueForName:@"to"]];
                }
            }
        }
        
        for (int i=0; i<tempArray.count; i++) {
            [historyArray addObject:[tempDict objectForKey:[tempArray objectAtIndex:i]]];
        }
        historyArray=[[[historyArray reverseObjectEnumerator] allObjects] mutableCopy];
        completion(historyArray);
    }
}
#pragma mark - end

#pragma mark - Group chat
- (void)getListOfGroups {
    
    XMPPIQ *iq = [[XMPPIQ alloc]init];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //    NSString *from = [NSString stringWithFormat:@"%@/%@",appDelegate.xmppLogedInUserId,[[myDelegate.xmppStream myJID] resource]];
    NSString *from = appDelegate.conferenceServerJid;
    [iq addAttributeWithName:@"from" stringValue:from];
    NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:private"];
    NSXMLElement *storage =   [NSXMLElement elementWithName:@"storage" xmlns:@"storage:bookmarks"];
    [query addChild:storage];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

- (void)XMPPFetchBookmarktList:(NSNotification *)notification {
    
    NSLog(@"%@",notification.object);
    appDelegate.groupChatRoomInfoList=[NSMutableArray new];
    appDelegate.groupChatMyBookMarkConferences=[NSMutableArray new];
    NSMutableArray *tempArray=[NSMutableArray new];
    joinAllGroups=[NSMutableArray new];
    for (int i=0; i<[notification.object count]; i++) {
        
        NSMutableDictionary *tempDict=[NSMutableDictionary new];
        NSXMLElement *lastConferences=[notification.object objectAtIndex:i];
        
        NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
        NSLog(@"%@",[lastConferences attributeStringValueForName:@"name"]);
        [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[lastConferences attributeStringValueForName:@"jid"] xmppGroupName:[lastConferences attributeStringValueForName:@"name"] xmppGroupDescription:[lastConferences attributeStringValueForName:@"Desc"] xmppGroupOnwerId:[lastConferences attributeStringValueForName:@"OwnerJid"]];
        
        [tempDict setObject:[lastConferences attributeStringValueForName:@"jid"] forKey:@"roomJid"];
        [tempDict setObject:[lastConferences attributeStringValueForName:@"name"] forKey:@"roomName"];
        [tempDict setObject:@"" forKey:@"roomDescription"];
        if (nil!=[lastConferences attributeStringValueForName:@"Desc"]) {
            [tempDict setObject:[lastConferences attributeStringValueForName:@"Desc"] forKey:@"roomDescription"];
        }
        [tempDict setObject:[lastConferences attributeStringValueForName:@"OwnerJid"] forKey:@"roomOwnerJid"];
        [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
        
        if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
            
            [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
            [appDelegate saveDataInCacheDirectory:(UIImage *)[UIImage imageWithData:[self photo:lastConferences]] folderName:appDelegate.appProfilePhotofolderName jid:[lastConferences attributeStringValueForName:@"jid"]];
        }
        
        [tempArray addObject:tempDict];
        [joinAllGroups addObject:[lastConferences attributeStringValueForName:@"jid"]];
        [appDelegate.groupChatMyBookMarkConferences addObject:lastConferences];
    }
    
//    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"roomJid" ascending:YES];
//    NSArray *results = [tempArray
//                                sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
   // [self deleteBookmark];
    appDelegate.groupChatRoomInfoList=[tempArray mutableCopy];
    
    if (joinAllGroups.count>0) {
        
        [self joinChatRoomJid:[joinAllGroups objectAtIndex:0]];
    }
    [self getListOfGroupsNotify:[appDelegate.groupChatRoomInfoList mutableCopy]];
}

//Join all groups
- (void)joinChatRoomJid:(NSString *)groupRoomJid {
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID * roomJID = [XMPPJID jidWithString:groupRoomJid];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //This method is used to create group if not exist and if this group is exist then join it
    [xmppRoom joinRoomUsingNickname:[[appDelegate.xmppLogedInUserId componentsSeparatedByString:@"@"] objectAtIndex:0]
                            history:nil
                           password:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
    if([joinAllGroups containsObject:[NSString stringWithFormat:@"%@",[sender roomJID]]]) {
        [joinAllGroups removeObject:[NSString stringWithFormat:@"%@",[sender roomJID]]];
    }
    if (joinAllGroups.count>0) {
        
        [self joinChatRoomJid:[joinAllGroups objectAtIndex:0]];
    }
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
    if([joinAllGroups containsObject:[NSString stringWithFormat:@"%@",[sender roomJID]]]) {
        [joinAllGroups removeObject:[NSString stringWithFormat:@"%@",[sender roomJID]]];
    }
    if (joinAllGroups.count>0) {
        
        [self joinChatRoomJid:[joinAllGroups objectAtIndex:0]];
    }
}
//end
- (void)XMPPAddedNewGroup {

    [self getListOfGroupsNotify:[appDelegate.groupChatRoomInfoList mutableCopy]];
}

- (NSMutableArray *)fetchGroupChatRommInfoList {

    return appDelegate.groupChatRoomInfoList;
}

- (NSData *)photo:(NSXMLElement *)xmlElement {
    NSData *decodedData = nil;
    NSXMLElement *photo = [xmlElement elementForName:@"PHOTO"];
    
    if (photo != nil) {
        // There is a PHOTO element. It should have a TYPE and a BINVAL
        //NSXMLElement *fileType = [photo elementForName:@"TYPE"];
        NSXMLElement *binval = [photo elementForName:@"BINVAL"];
        
        if (binval) {
            NSData *base64Data = [[binval stringValue] dataUsingEncoding:NSASCIIStringEncoding];
            decodedData = [base64Data xmpp_base64Decoded];
        }
    }
    
    return decodedData;
}

- (void)deleteBookmark {
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:appDelegate.hostName]];
    [iq addAttributeWithName:@"from" stringValue:[self.xmppStream myJID].full];
    //    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"BookMarkManager2.%@",[self getUniqueRoomName]]];
    [iq addAttributeWithName:@"id" stringValue:@"BookMarkManager"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
    NSXMLElement *storage_q = [NSXMLElement elementWithName:@"storage"];
    [storage_q addAttributeWithName:@"xmlns" stringValue:@"storage:bookmarks"];
    
    [query addChild:storage_q];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

- (void)getGroupPhotoJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    completion([UIImage imageWithData:tempImageData]);
}

- (void)deallocGroupChatVariables {

    appDelegate.selectedFriendUserId=@"";
    appDelegate.selectedMemberUserIds=[NSMutableArray new];
    appDelegate.xmppRoomAppDelegateObje=nil;
    appDelegate.chatRoomAppDelegateImage=nil;
    appDelegate.chatRoomAppDelegateDescription=@"";
    appDelegate.chatRoomAppDelegateName=@"";
    appDelegate.chatRoomAppDelegateRoomJid=@"";
    appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid=@"";
}
#pragma mark - end

- (BOOL)isChatTypeMessageElement:(NSXMLElement *)message {

    return [[[message attributeForName:@"type"] stringValue] isEqualToString:@"chat"];
}

- (BOOL)isGroupChatTypeMessageElement:(NSXMLElement *)message {
    
    return [[[message attributeForName:@"type"] stringValue] isEqualToString:@"groupchat"];
}

- (void)XMPPReloadConnection {}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
