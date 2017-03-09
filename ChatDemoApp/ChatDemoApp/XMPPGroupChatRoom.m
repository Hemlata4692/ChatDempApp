//
//  XMPPGroupChatRoom.m
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XMPPGroupChatRoom.h"
#import <CoreData/CoreData.h>
#import "XMPPUserDefaultManager.h"
#import "XmppCoreDataHandler.h"
#import <XMPPRoomMemoryStorage.h>
#import <XMPPIDTracker.h>
#import "NSData+XMPP.h"
#import <XMPPRoomHybridStorage.h>

@interface XMPPGroupChatRoom ()<XMPPRoomDelegate>{
    
    AppDelegateObjectFile *appDelegate;
    GroupChatType type;
}
@end

@implementation XMPPGroupChatRoom

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPBookMarkUpdated) name:@"XMPPBookMarkUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
   
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroySuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroyFail) name:@"XMPPDeleteGroupFail" object:nil];
}

- (void)deallocObservers {

//    [self setXmppRoomVar:nil];
    appDelegate.xmppRoomDelegate=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Set/Get methods
//Set methods
- (void)setChatRoomName:(NSString *)chatRoomNameString {
    
    chatRoomName=chatRoomNameString;
}

- (void)setChatRoomNickName:(NSString *)chatRoomNickNameString {
    
    chatRoomNickName=chatRoomNickNameString;
}

- (void)setChatRoomDescription:(NSString *)chatRoomDescriptionString {
    
    chatRoomDescription=chatRoomDescriptionString;
}

- (void)setChatRoomImage:(UIImage *)newChatRoomImage {
    
    chatRoomImage=newChatRoomImage;
}

- (void)setXmppRoomVar:(XMPPRoom *)joinedXMPPRoomVar {
    
    xmppRoomVar=joinedXMPPRoomVar;
}

- (void)setXmppCurrentRoomDetail:(NSMutableDictionary *)xmppCurrentRoomDetailDic {

    xmppCurrentRoomDetail=[xmppCurrentRoomDetail mutableCopy];
}

- (void)setChatRoomOwnerId:(NSString *)chatRoomOwnerJid {
    
    chatRoomOwnerId=chatRoomOwnerJid;
}
//end

//Get methods
- (NSString *)chatRoomName {
    
    return chatRoomName;
}

- (NSString *)chatRoomNickName {
    
    return chatRoomNickName;
}

- (NSString *)chatRoomDescription {
    
    return chatRoomDescription;
}

- (UIImage *)chatRoomImage {
    
    return chatRoomImage;
}

- (XMPPRoom *)xmppRoomVar {
    
    return xmppRoomVar;
}

- (NSMutableDictionary *)xmppCurrentRoomDetail {

    return xmppCurrentRoomDetail;
}

- (NSString *)chatRoomOwnerId {

    return chatRoomOwnerId;
}
//end

- (void)setPhoto:(NSData *)data xmlElement:(NSXMLElement *)xmlElement {
    
    NSXMLElement *photo = [xmlElement elementForName:@"PHOTO"];
    
    if(photo)
    {
        [xmlElement removeChildAtIndex:[[xmlElement children] indexOfObject:photo]];
    }
    
    if([data length])
    {
        NSXMLElement *photo = [NSXMLElement elementWithName:@"PHOTO"];
        [xmlElement addChild:photo];
        
        NSString *imageType = [data xmpp_imageType];
        
        if([imageType length])
        {
            NSXMLElement *photoType = [NSXMLElement elementWithName:@"TYPE"];
            [photo addChild:photoType];
            [photoType setStringValue:imageType];
        }
        
        NSXMLElement *binval = [NSXMLElement elementWithName:@"BINVAL"];
        [photo addChild:binval];
        [binval setStringValue:[data xmpp_base64Encoded]];
    }
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
#pragma mark - end

#pragma mark - XMPP other methods
- (XMPPStream *)xmppStream
{
    return [appDelegate xmppStream];
}

- (NSArray *)fetchFriendJids {

    return [appDelegate.xmppUserListArray copy];
}

- (NSMutableDictionary *)fetchFriendDetials {
    
    return [[XmppCoreDataHandler sharedManager] getProfileUsersData];
}

- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
        dispatch_queue_t queue = dispatch_queue_create("invitationPhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
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
#pragma mark - end

#pragma mark - Create room
- (NSString *)getUniqueRoomName {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)createChatRoom:(UIImage *)groupImage groupNickName:(NSString *)groupNickName groupDescription:(NSString *)groupDescription groupSubject:(NSString *)groupSubject {
    
    type=XMPP_GroupCreate;
    [self setChatRoomName:groupSubject];
    [self setChatRoomDescription:groupDescription];
    [self setChatRoomNickName:groupNickName];
    [self setChatRoomImage:groupImage];
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString *uniqueName=[self getUniqueRoomName];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@" ,uniqueName,appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];

    if ([self chatRoomNickName]||[[self chatRoomNickName] isEqualToString:@""]) {
        
        [self setChatRoomNickName:uniqueName];
    }
    
    //This method is used to create group if not exist and if this group is exist then join it
    [xmppRoom joinRoomUsingNickname:[self chatRoomNickName]
                            history:nil
                           password:nil];
}


- (void)joinChatRoomJid:(NSString *)groupRoomJid groupNickName:(NSString *)groupNickName {
    
    type=XMPP_GroupJoin;
    [self setChatRoomNickName:groupNickName];
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    XMPPJID * roomJID = [XMPPJID jidWithString:groupRoomJid];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];

    //This method is used to create group if not exist and if this group is exist then join it
    [xmppRoom joinRoomUsingNickname:[self chatRoomNickName]
                            history:nil
                           password:nil];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [self setXmppRoomVar:sender];
    appDelegate.xmppRoomDelegate=sender;
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [self setXmppRoomVar:sender];
    appDelegate.xmppRoomDelegate=sender;
    
    switch (type) {
        case XMPP_GroupJoin:
            type=XMPP_GroupNull;
            [self groupJoined];
            break;
        default:
            break;
    }
}

- (void)groupJoined{}

- (void)newChatGroupCreated:(NSMutableDictionary *)groupInfo{}
#pragma mark - end

#pragma mark - Fetch room configurations and update it using configureRoomUsingOptions
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    
    NSXMLElement *newConfig = [configForm copy];
    
    NSArray* fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        //        else if ([var isEqualToString:@"muc#roomconfig_roomowners"]) {
        //            [self setChatRoomOwnerId:[[field elementForName:@"value"] stringValue]];
        //        }
        
        else if ([var isEqualToString:@"muc#roomconfig_roomname"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[self chatRoomName]]];
            //                        roomName=[[field elementForName:@"value"] stringValue];
        }
        //By default roomconfig_maxusers is 30
        //                    else if ([var isEqualToString:@"muc#roomconfig_maxusers"]) {
        //                        [field removeChildAtIndex:0];
        //                        [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"5"]];
        //                    }
        else if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[self chatRoomDescription]]];
            //                roomDecs=[[field elementForName:@"value"] stringValue];
        }
    }
    [sender configureRoomUsingOptions:newConfig];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    
    NSLog(@"a");
    [self fetchJoinedGroupList];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {
    
    NSLog(@"a");
}

- (void)addBookMarkConferenceList:(NSMutableArray *)conferenceList{
    
    //    NSString* server = @"test@pc"; //or whatever the server address for muc is
    //    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:myDelegate.serverName]];
    [iq addAttributeWithName:@"from" stringValue:[self.xmppStream myJID].full];
    //    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"BookMarkManager2.%@",[self getUniqueRoomName]]];
    [iq addAttributeWithName:@"id" stringValue:@"BookMarkManager"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
    NSXMLElement *storage_q = [NSXMLElement elementWithName:@"storage"];
    [storage_q addAttributeWithName:@"xmlns" stringValue:@"storage:bookmarks"];
    
    for (NSXMLElement *list in conferenceList) {
        
        [storage_q addChild:[list copy]];
    }
    NSXMLElement *conference_s = [NSXMLElement elementWithName:@"conference"];
    [conference_s addAttributeWithName:@"name" stringValue:[self chatRoomName]];
    [conference_s addAttributeWithName:@"autojoin" stringValue:@"true"];
    [conference_s addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomDelegate roomJID]]];
    [conference_s addAttributeWithName:@"nick" stringValue:[self chatRoomNickName]];
    [conference_s addAttributeWithName:@"Desc" stringValue:[self chatRoomDescription]];
    if ([[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] containsString:@"/"]) {
        [conference_s addAttributeWithName:@"OwnerJid" stringValue:[[[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] componentsSeparatedByString:@"/"] objectAtIndex:0]];
        [self setChatRoomOwnerId:[[[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] componentsSeparatedByString:@"/"] objectAtIndex:0]];
    }
    else {
        [conference_s addAttributeWithName:@"OwnerJid" stringValue:[NSString stringWithFormat:@"%@",[self.xmppStream myJID]]];
        [self setChatRoomOwnerId:[NSString stringWithFormat:@"%@",[self.xmppStream myJID]]];
    }
    
    if ([self chatRoomImage]) {
        NSData *tempImageData=[myDelegate reducedImageSize:[self chatRoomImage]];
        [self setPhoto:tempImageData xmlElement:conference_s];
        [self setChatRoomImage:[UIImage imageWithData:tempImageData]];
    }
    [storage_q addChild:conference_s];
    [query addChild:storage_q];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}
#pragma mark - end

#pragma mark - Fetch group listing
- (void)fetchAllGroupList {
    
    XMPPJID *servrJID = [XMPPJID jidWithString:appDelegate.conferenceServerJid];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[[self xmppStream] myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
}

- (void)fetchJoinedGroupList {
    
    XMPPIQ *iq = [[XMPPIQ alloc]init];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    //    NSString *from = [NSString stringWithFormat:@"%@/%@",appDelegate.xmppLogedInUserId,[[myDelegate.xmppStream myJID] resource]];
    NSString *from = appDelegate.conferenceServerJid;
    [iq addAttributeWithName:@"from" stringValue:from];
    NSXMLElement *query =[NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:private"];
    NSXMLElement *storage = [NSXMLElement elementWithName:@"storage" xmlns:@"storage:bookmarks"];
    [query addChild:storage];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

- (void)XMPPFetchBookmarktList:(NSNotification *)notification {
    
    NSLog(@"%@",notification.object);
//    if (isFirstFetchBookmark) {
//        
//        isFirstFetchBookmark=false;
//        [self addBookMark:[sendXmppRoomObj roomJID] conferenceList:[notification.object mutableCopy]];
//    }
//    else {
//        
//        for (int i=0; i<[notification.object count]; i++) {
//            
//            NSXMLElement *lastConferences=[notification.object objectAtIndex:i];
//            NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
//            if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
//                UIImage *i=[UIImage imageWithData:[self photo:lastConferences]];
//                lastgroupProfileImage=[UIImage imageWithData:[self photo:lastConferences]];
//            }
//        }
//        if (isUpdate) {
//            isUpdate=false;
//            [self updateBookMark:[notification.object mutableCopy]];
//        }
//        NSLog(@"a");
//    }
    switch (type) {
        case XMPP_GroupCreate:
            [self addBookMarkConferenceList:[notification.object mutableCopy]];
            break;
            
        case XMPP_GroupDetail: {
            
            NSLog(@"%@",notification.object);
            appDelegate.groupChatRoomInfoList=[NSMutableArray new];
            
            NSMutableArray *tempArray=[NSMutableArray new];
            for (int i=0; i<[notification.object count]; i++) {
                
                NSMutableDictionary *tempDict=[NSMutableDictionary new];
                NSXMLElement *lastConferences=[notification.object objectAtIndex:i];
                
                NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
                NSLog(@"%@",[lastConferences attributeStringValueForName:@"name"]);
                [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[lastConferences attributeStringValueForName:@"jid"] xmppGroupName:[lastConferences attributeStringValueForName:@"name"] xmppGroupNickName:[lastConferences attributeStringValueForName:@"nick"] xmppGroupDescription:[lastConferences attributeStringValueForName:@"Desc"] xmppGroupOnwerId:[lastConferences attributeStringValueForName:@"OwnerJid"]];
                
                [tempDict setObject:[lastConferences attributeStringValueForName:@"jid"] forKey:@"roomJid"];
                [tempDict setObject:[lastConferences attributeStringValueForName:@"name"] forKey:@"roomName"];
                [tempDict setObject:[lastConferences attributeStringValueForName:@"nick"] forKey:@"roomNickName"];
                [tempDict setObject:[lastConferences attributeStringValueForName:@"Desc"] forKey:@"roomDescription"];
                [tempDict setObject:[lastConferences attributeStringValueForName:@"OwnerJid"] forKey:@"roomOwnerJid"];
                [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
                
                if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
                    
                    [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
                    [appDelegate saveDataInCacheDirectory:(UIImage *)[UIImage imageWithData:[self photo:lastConferences]] folderName:appDelegate.appProfilePhotofolderName jid:[lastConferences attributeStringValueForName:@"jid"]];
                }
                
                [tempArray addObject:tempDict];
            }
            appDelegate.groupChatRoomInfoList=[tempArray mutableCopy];
//            [self getListOfGroupsNotify:[appDelegate.groupChatRoomInfoList mutableCopy]];
        }
            default:
            break;
    }
}

- (void)XMPPBookMarkUpdated {
    
    NSLog(@"a");
    
    switch (type) {
        case XMPP_GroupCreate:
        {
            type=XMPP_GroupNull;
            NSMutableDictionary *tempDict=[NSMutableDictionary new];
            [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomDelegate roomJID]] xmppGroupName:[self chatRoomName] xmppGroupNickName:[self chatRoomNickName] xmppGroupDescription:[self chatRoomDescription] xmppGroupOnwerId:[self chatRoomOwnerId]];
            
            [tempDict setObject:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomDelegate roomJID]] forKey:@"roomJid"];
            [tempDict setObject:[self chatRoomName] forKey:@"roomName"];
            [tempDict setObject:[self chatRoomNickName] forKey:@"roomNickName"];
            [tempDict setObject:[self chatRoomDescription] forKey:@"roomDescription"];
            [tempDict setObject:[self chatRoomOwnerId] forKey:@"roomOwnerJid"];
            [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
            
            if ((nil!=[self chatRoomImage])&&(NULL!=[self chatRoomImage])) {
                
                [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
                [appDelegate saveDataInCacheDirectory:[self chatRoomImage] folderName:appDelegate.appProfilePhotofolderName jid:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomDelegate roomJID]]];
            }
            [appDelegate.groupChatRoomInfoList addObject:[tempDict mutableCopy]];
            [self newChatGroupCreated:[tempDict mutableCopy]];
        }
            break;
            
        default:
            break;
    }
}

- (void)xmppJoindGroupList {

    type=XMPP_GroupDetail;
    [self fetchJoinedGroupList];
}
#pragma mark - end

#pragma mark - Send invitation
- (void)sendGroupInvitation:(NSArray *)inviteFriend {

    for (NSString *invitationJid in inviteFriend) {
        [appDelegate.xmppRoomDelegate inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@/%@",invitationJid,[[self.xmppStream myJID] resource]]] withMessage:@"Greetings!"];
    }
    
}
- (void)invitationSended{}
#pragma mark - end

#pragma mark - Fetch group image
- (void)getGroupPhotoJid:(NSString *)jid result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    completion([UIImage imageWithData:tempImageData]);
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
