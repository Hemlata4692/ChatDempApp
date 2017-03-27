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
    NSMutableArray *invitedFriendArray;
}
@end

@implementation XMPPGroupChatRoom

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPBookMarkUpdated) name:@"XMPPBookMarkUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroySuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroyFail) name:@"XMPPDeleteGroupFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPGroupMembersList:) name:@"GroupAdminList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
   
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroySuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroyFail) name:@"XMPPDeleteGroupFail" object:nil];
}

- (void)deallocObservers {

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

- (bool)isOwner {

    if ([[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] containsString:@"/"]) {
        
        return ([appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid isEqualToString:[[[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] componentsSeparatedByString:@"/"] objectAtIndex:0]]?true:false);
    }
    else {
        
        return ([appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid isEqualToString:[NSString stringWithFormat:@"%@",[self.xmppStream myJID]]]?true:false);
    }
}

- (void)appDelegateVariableInitializedGroupSubject:(NSString *)groupSubject groupDescription:(NSString *)groupDescription groupJid:(NSString *)groupJid ownerJid:(NSString *)ownerJid {

    [XMPPUserDefaultManager removeXMPPBadgeIndicatorValue:groupJid];
    appDelegate.selectedFriendUserId=groupJid;
    appDelegate.chatRoomAppDelegateName=groupSubject;
    appDelegate.chatRoomAppDelegateDescription=groupDescription;
//    appDelegate.chatRoomAppDelegateImage=groupImage;
    appDelegate.chatRoomAppDelegateRoomJid=groupJid;
    appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid=ownerJid;
}

- (void)appDelegateImageVariableInitialized:(UIImage *)groupPhoto {
    
    appDelegate.chatRoomAppDelegateImage=groupPhoto;
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

- (void)createChatRoom:(UIImage *)groupImage groupDescription:(NSString *)groupDescription groupSubject:(NSString *)groupSubject {
    
    type=XMPP_GroupCreate;    
    appDelegate.chatRoomAppDelegateName=groupSubject;
    appDelegate.chatRoomAppDelegateDescription=groupDescription;
    appDelegate.chatRoomAppDelegateImage=groupImage;
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString *uniqueName=[self getUniqueRoomName];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@" ,uniqueName,appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
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


- (void)joinChatRoomJid:(NSString *)groupRoomJid {
    
    type=XMPP_GroupJoin;
    
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

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [self setXmppRoomVar:sender];
    type=XMPP_GroupCreate;
    appDelegate.xmppRoomAppDelegateObje=sender;
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [self setXmppRoomVar:sender];
    appDelegate.xmppRoomAppDelegateObje=sender;
    
    switch (type) {
        case XMPP_GroupJoin:
            type=XMPP_GroupNull;
//            [sender fetchMembersList];
        {
            NSString *fetchID = @"GroupAdminList";
            
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            [item addAttributeWithName:@"affiliation" stringValue:@"admin"];
            
            NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
            [query addChild:item];
            
            XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:[sender roomJID] elementID:fetchID child:query];
            
            [self.xmppStream sendElement:iq];
    }
//            [self groupJoined];
            break;
        default:
            break;
    }
}

- (void)XMPPGroupMembersList:(NSNotification *)notification {
    
    NSLog(@"%@",notification.object);
    [self groupJoined:[notification.object mutableCopy]];
}

- (void)groupJoined:(NSMutableArray *)memberList{}

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
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:appDelegate.chatRoomAppDelegateName]];
            //                        roomName=[[field elementForName:@"value"] stringValue];
        }
        //By default roomconfig_maxusers is 30
        //                    else if ([var isEqualToString:@"muc#roomconfig_maxusers"]) {
        //                        [field removeChildAtIndex:0];
        //                        [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"5"]];
        //                    }
        else if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:appDelegate.chatRoomAppDelegateDescription]];
            //                roomDecs=[[field elementForName:@"value"] stringValue];
            
            
            //            if (type==XMPP_GroupCreate) {
            //                [field removeChildAtIndex:0];
            //
            //                NSData *tempImageData=[myDelegate reducedImageSize:appDelegate.chatRoomAppDelegateImage];
            //                //            NSXMLElement *binval = [NSXMLElement elementWithName:@"BINVAL"];
            //                //
            //                //            [binval setStringValue:[tempImageData xmpp_base64Encoded]];
            //
            //                NSString *imageType = [tempImageData xmpp_imageType];
            //
            //                if([imageType length])
            //                {
            //                    [field addAttributeWithName:@"TYPE" stringValue:imageType];
            //                }
            //
            //                [field addChild:[NSXMLElement elementWithName:@"value" stringValue:[tempImageData xmpp_base64Encoded]]];
            //
            //                //                roomDecs=[[field elementForName:@"value"] stringValue];
            //            }
            //            else {
            //
            //                UIImage *tem=[UIImage imageWithData:[[[[field elementForName:@"value"] stringValue] dataUsingEncoding:NSASCIIStringEncoding] xmpp_base64Decoded] ];
            //                NSLog(@"a");
            //                //                if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
            //                //
            //                //                    [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
            //                //                    [appDelegate saveDataInCacheDirectory:(UIImage *)[UIImage imageWithData:[self photo:lastConferences]] folderName:appDelegate.appProfilePhotofolderName jid:[lastConferences attributeStringValueForName:@"jid"]];
            //                //                }
            //
            //                //                - (NSData *)photo:(NSXMLElement *)xmlElement {
            //                //                    NSData *decodedData = nil;
            //                //                    NSXMLElement *photo = [xmlElement elementForName:@"PHOTO"];
            //                //
            //                //                    if (photo != nil) {
            //                //                        // There is a PHOTO element. It should have a TYPE and a BINVAL
            //                //                        //NSXMLElement *fileType = [photo elementForName:@"TYPE"];
            //                //                        NSXMLElement *binval = [photo elementForName:@"BINVAL"];
            //                //
            //                //                        if (binval) {
            //                //                            NSData *base64Data = [[binval stringValue] dataUsingEncoding:NSASCIIStringEncoding];
            //                //                            decodedData = [base64Data xmpp_base64Decoded];
            //                //                        }
            //                //                    }
            //                //                    
            //                //                    return decodedData;
            //                //                }
            //                
            //            }

        }
    }
    [sender configureRoomUsingOptions:newConfig];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {
    
    NSLog(@"a");
//    [self fetchJoinedGroupList];
    switch (type) {
        case XMPP_GroupCreate:
            [self addBookMarkConferenceList:[appDelegate.groupChatMyBookMarkConferences mutableCopy]];
            break;
        default:
            break;
    }
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
        
        if (![[list attributeStringValueForName:@"jid"] isEqualToString:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]]]) {
            
            [storage_q addChild:[list copy]];
        }
    }
    NSXMLElement *conference_s = [NSXMLElement elementWithName:@"conference"];
    [conference_s addAttributeWithName:@"name" stringValue:appDelegate.chatRoomAppDelegateName];
    [conference_s addAttributeWithName:@"autojoin" stringValue:@"true"];
    [conference_s addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]]];
    [conference_s addAttributeWithName:@"Desc" stringValue:appDelegate.chatRoomAppDelegateDescription];
    if ([[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] containsString:@"/"]) {
        [conference_s addAttributeWithName:@"OwnerJid" stringValue:[[[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] componentsSeparatedByString:@"/"] objectAtIndex:0]];
         appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid=[[[NSString stringWithFormat:@"%@",[self.xmppStream myJID]] componentsSeparatedByString:@"/"] objectAtIndex:0];
    }
    else {
        [conference_s addAttributeWithName:@"OwnerJid" stringValue:[NSString stringWithFormat:@"%@",[self.xmppStream myJID]]];
         appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid=[NSString stringWithFormat:@"%@",[self.xmppStream myJID]];
    }
    
    if (appDelegate.chatRoomAppDelegateImage) {
        NSData *tempImageData=[myDelegate reducedImageSize:appDelegate.chatRoomAppDelegateImage];
        [self setPhoto:tempImageData xmlElement:conference_s];
        [self setChatRoomImage:[UIImage imageWithData:tempImageData]];
    }
    
    [appDelegate.groupChatMyBookMarkConferences addObject:conference_s];
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
                [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[lastConferences attributeStringValueForName:@"jid"] xmppGroupName:[lastConferences attributeStringValueForName:@"name"] xmppGroupDescription:[lastConferences attributeStringValueForName:@"Desc"] xmppGroupOnwerId:[lastConferences attributeStringValueForName:@"OwnerJid"]];
                
                [tempDict setObject:[lastConferences attributeStringValueForName:@"jid"] forKey:@"roomJid"];
                [tempDict setObject:[lastConferences attributeStringValueForName:@"name"] forKey:@"roomName"];
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
        case XMPP_GroupDelete: {
            
            NSLog(@"%@",notification.object);
            
            [[XmppCoreDataHandler sharedManager] deleteGroupEntry:appDelegate.chatRoomAppDelegateRoomJid];
            appDelegate.groupChatRoomInfoList=[NSMutableArray new];
            NSMutableArray *tempArray=[NSMutableArray new];
            for (int i=0; i<[notification.object count]; i++) {
                
                NSXMLElement *lastConferences=[notification.object objectAtIndex:i];
                if (![[lastConferences attributeStringValueForName:@"jid"] isEqualToString:appDelegate.chatRoomAppDelegateRoomJid]) {
                    
                    NSMutableDictionary *tempDict=[NSMutableDictionary new];
                    
                    NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
                    NSLog(@"%@",[lastConferences attributeStringValueForName:@"name"]);
                    [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[lastConferences attributeStringValueForName:@"jid"] xmppGroupName:[lastConferences attributeStringValueForName:@"name"] xmppGroupDescription:[lastConferences attributeStringValueForName:@"Desc"] xmppGroupOnwerId:[lastConferences attributeStringValueForName:@"OwnerJid"]];
                    
                    [tempDict setObject:[lastConferences attributeStringValueForName:@"jid"] forKey:@"roomJid"];
                    [tempDict setObject:[lastConferences attributeStringValueForName:@"name"] forKey:@"roomName"];
                    [tempDict setObject:[lastConferences attributeStringValueForName:@"Desc"] forKey:@"roomDescription"];
                    [tempDict setObject:[lastConferences attributeStringValueForName:@"OwnerJid"] forKey:@"roomOwnerJid"];
                    [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
                    
                    if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
                        
                        [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
                        [appDelegate saveDataInCacheDirectory:(UIImage *)[UIImage imageWithData:[self photo:lastConferences]] folderName:appDelegate.appProfilePhotofolderName jid:[lastConferences attributeStringValueForName:@"jid"]];
                    }
                    
                    [tempArray addObject:tempDict];
                }
                
            }
            
            appDelegate.groupChatRoomInfoList=[tempArray mutableCopy];
            [self deleteBookmark:appDelegate.chatRoomAppDelegateRoomJid conferenceList:[notification.object mutableCopy]];
//                        [self getListOfGroupsNotify:[appDelegate.groupChatRoomInfoList mutableCopy]];
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
            [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]] xmppGroupName:appDelegate.chatRoomAppDelegateName xmppGroupDescription:appDelegate.chatRoomAppDelegateDescription xmppGroupOnwerId:appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid];
            
            [tempDict setObject:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]] forKey:@"roomJid"];
            [tempDict setObject:appDelegate.chatRoomAppDelegateName forKey:@"roomName"];
            [tempDict setObject:appDelegate.chatRoomAppDelegateDescription forKey:@"roomDescription"];
            [tempDict setObject:appDelegate.chatRoomAppDelegateSelectedRoomOwnerJid forKey:@"roomOwnerJid"];
            [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
            
            if ((nil!=[self chatRoomImage])&&(NULL!=[self chatRoomImage])) {
                
                [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
                [appDelegate saveDataInCacheDirectory:appDelegate.chatRoomAppDelegateImage folderName:appDelegate.appProfilePhotofolderName jid:[NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]]];
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJid == %@", [NSString stringWithFormat:@"%@",[appDelegate.xmppRoomAppDelegateObje roomJID]]];
            NSArray *filteredarray = [appDelegate.groupChatRoomInfoList filteredArrayUsingPredicate:predicate];
            
            if (filteredarray.count>0) {
                
                NSUInteger index = [appDelegate.groupChatRoomInfoList indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                    return [predicate evaluateWithObject:obj];
                }];
                [appDelegate.groupChatRoomInfoList replaceObjectAtIndex:index withObject:[tempDict mutableCopy]];
            }
            else {
                [appDelegate.groupChatRoomInfoList addObject:[tempDict mutableCopy]];
            }
            
//            [appDelegate.groupChatRoomInfoList addObject:[tempDict mutableCopy]];
            [self newChatGroupCreated:[tempDict mutableCopy]];
        }
            break;
        case XMPP_GroupDelete: {
            type=XMPP_GroupNull;
            [self xmppRoomDeleteSuccess];
        }
            break;
        default:
            break;
    }
}

- (void)xmppJoindGroupList {

    type=XMPP_GroupDetail;
    
//    [self fetchJoinedGroupList];
}
#pragma mark - end

#pragma mark - Send invitation
- (void)sendGroupInvitation:(NSArray *)inviteFriend {
    
    for (NSString *invitationJid in inviteFriend) {
        [appDelegate.xmppRoomAppDelegateObje editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"admin" jid:[XMPPJID jidWithString:invitationJid]]]];
        [appDelegate.xmppRoomAppDelegateObje inviteUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@",invitationJid]] withMessage:@"Greetings!"];
    }
    [self invitationSended];
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult {

//    [appDelegate.xmppRoomAppDelegateObje inviteUser:[XMPPJID jidWithString:[[iqResult attributeForName:@"to"] stringValue]] withMessage:@"Greetings!"];
//    [self invitationSended];
}

- (void)invitationSended{}
#pragma mark - end

#pragma mark - Fetch group image
- (void)getGroupPhotoJid:(NSString *)jid result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:jid];
    completion([UIImage imageWithData:tempImageData]);
}
#pragma mark - end

#pragma mark - Delete group
- (void)destroyRoom {
    
    //    XMPPRoomMemoryStorage *xmppRoomStorage1 = [[XMPPRoomMemoryStorage alloc] init];
    //
    //    XMPPJID *roomJid = [XMPPJID jidWithString:roomJidString];
    //
    //    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage1 jid:roomJid];
    //    xmppRoom=room;
    ////    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomStorage
    ////                                                           jid:roomJid
    ////                                                 dispatchQueue:dispatch_get_main_queue()];
    ////    [room activate:self.xmppStream];
    ////    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    ////    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //
    ////    [xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    //
    ////    [room deactivate];
    ////
    ////    [xmppRoom leaveRoom];
    //    [room destroyRoom];
    
    type=XMPP_GroupDelete;
    NSXMLElement *destroy = [NSXMLElement elementWithName:@"destroy"];
    if (destroy) {
        NSXMLElement *reason = [destroy elementForName:@"reason"];
        if (!reason) {
            reason = [NSXMLElement elementWithName:@"reason" stringValue:@""];
            [destroy addChild:reason];
        }
    }
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    [query addChild:destroy];
    
    NSString *iqID = [self.xmppStream generateUUID];
    myDelegate.groupDeleteid=iqID;
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:appDelegate.chatRoomAppDelegateRoomJid] elementID:iqID child:query];
    //    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@/%@",appDelegate.xmppLogedInUserId,[[myDelegate.xmppStream myJID] resource]]];
    [self.xmppStream sendElement:iq];
}

- (void)deleteBookmark:(NSString*)jid conferenceList:(NSMutableArray *)conferenceList {
    
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:myDelegate.hostName]];
    [iq addAttributeWithName:@"from" stringValue:[self.xmppStream myJID].full];
    //    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"BookMarkManager2.%@",[self getUniqueRoomName]]];
    [iq addAttributeWithName:@"id" stringValue:@"BookMarkManager"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
    NSXMLElement *storage_q = [NSXMLElement elementWithName:@"storage"];
    [storage_q addAttributeWithName:@"xmlns" stringValue:@"storage:bookmarks"];
    
    for (NSXMLElement *list in conferenceList) {
        
        if (![[list attributeStringValueForName:@"jid"] isEqualToString:jid]) {
            
            [storage_q addChild:[list copy]];
        }
    }
    [query addChild:storage_q];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

//Delete group notify
- (void)xmppRoomDidDestroySuccess {
    
    myDelegate.groupDeleteid=nil;
    
    //    [self fetchJoinedGroupList];
    
    [[XmppCoreDataHandler sharedManager] deleteGroupEntry:appDelegate.chatRoomAppDelegateRoomJid];
    appDelegate.groupChatRoomInfoList=[NSMutableArray new];
    
    NSMutableArray *tempArray=[NSMutableArray new];
    NSMutableArray *tempDeletedConferenceArray=[NSMutableArray new];
    for (int i=0; i<[appDelegate.groupChatMyBookMarkConferences count]; i++) {
        
        NSXMLElement *lastConferences=[appDelegate.groupChatMyBookMarkConferences objectAtIndex:i];
        if (![[lastConferences attributeStringValueForName:@"jid"] isEqualToString:appDelegate.chatRoomAppDelegateRoomJid]) {
            
            NSMutableDictionary *tempDict=[NSMutableDictionary new];
            
            NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
            NSLog(@"%@",[lastConferences attributeStringValueForName:@"name"]);
            [[XmppCoreDataHandler sharedManager] insertGroupEntryInXmppUserModelXmppGroupJid:[lastConferences attributeStringValueForName:@"jid"] xmppGroupName:[lastConferences attributeStringValueForName:@"name"] xmppGroupDescription:[lastConferences attributeStringValueForName:@"Desc"] xmppGroupOnwerId:[lastConferences attributeStringValueForName:@"OwnerJid"]];
            
            [tempDict setObject:[lastConferences attributeStringValueForName:@"jid"] forKey:@"roomJid"];
            [tempDict setObject:[lastConferences attributeStringValueForName:@"name"] forKey:@"roomName"];
            [tempDict setObject:[lastConferences attributeStringValueForName:@"Desc"] forKey:@"roomDescription"];
            [tempDict setObject:[lastConferences attributeStringValueForName:@"OwnerJid"] forKey:@"roomOwnerJid"];
            [tempDict setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
            
            if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
                
                [tempDict setObject:[NSNumber numberWithBool:true] forKey:@"isPhoto"];
                [appDelegate saveDataInCacheDirectory:(UIImage *)[UIImage imageWithData:[self photo:lastConferences]] folderName:appDelegate.appProfilePhotofolderName jid:[lastConferences attributeStringValueForName:@"jid"]];
            }
            
            [tempDeletedConferenceArray addObject:lastConferences];
            [tempArray addObject:tempDict];
        }
        
    }
    
    appDelegate.groupChatMyBookMarkConferences=[tempDeletedConferenceArray mutableCopy];
    appDelegate.groupChatRoomInfoList=[tempArray mutableCopy];
    [self deleteBookmark:appDelegate.chatRoomAppDelegateRoomJid conferenceList:[appDelegate.groupChatMyBookMarkConferences mutableCopy]];
    //                        [self getListOfGroupsNotify:[appDelegate.groupChatRoomInfoList mutableCopy]];
    
    NSLog(@"successfully destroy");
}

- (void)xmppRoomDidDestroyFail {
    myDelegate.groupDeleteid=nil;
    NSLog(@"fail destroy");
    [self xmppRoomDeleteFail];
}
//end

//Delete group notify
- (void)xmppRoomDeleteSuccess {}
- (void)xmppRoomDeleteFail {}
//end
#pragma mark - end

#pragma mark - Send message
+ (void)getChatProfilePhotoJid:(NSString *)Jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *image)) completion {
    
     AppDelegateObjectFile *appDelegateVar = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    //Fetch profile photos from local database if exist
    NSData *tempImageData=[appDelegateVar listionDataFromCacheDirectoryFolderName:appDelegateVar.appProfilePhotofolderName jid:Jid];
    
    //Set temporary image
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
    }
    else {
        profileImageView.image=[UIImage imageWithData:tempImageData];
    }
    
    //If one image is nil means anyone image is not exist then call background thread
    if ((nil==tempImageData)) {
        dispatch_queue_t queue = dispatch_queue_create("profilePhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async(queue, ^
                       {
                           UIImage *tempPhoto;
                           
                           if (nil==tempImageData) {
                               tempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:Jid]]];
                               if (tempPhoto!=nil) {
                                   [appDelegateVar saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:appDelegateVar.appProfilePhotofolderName jid:Jid];
                               }
                               else {
                                   tempPhoto=[UIImage imageNamed:placeholderImage];
                               }
                           }
                           else {
                               tempPhoto=[UIImage imageWithData:tempImageData];
                           }
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               completion(tempPhoto);
                           });
                       });
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(profileImageView.image);
        });
    }
}
#pragma mark - end
- (void)getHistoryGroupChatData:(NSString *)jid {
    
    NSArray *messages_arc = [[[XmppCoreDataHandler sharedManager] readLocalMessageStorageDatabaseBareJidStr:jid] copy];
    if (messages_arc.count>0) {
        [self print:[[NSMutableArray alloc]initWithArray:messages_arc]];
    }
    else {
        
        [self historyData:[NSMutableArray new]];
    }
}

- (void)print:(NSMutableArray*)messages_arc {
    
    @autoreleasepool {
        
        NSMutableArray *tempHistoryData=[NSMutableArray new];
        for (NSManagedObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:[message valueForKey:@"messageString"] error:nil];
            [tempHistoryData addObject:element];
//            NSXMLElement *innerElementData = [element elementForName:@"data"];
//            if (![[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
//                
//                [tempHistoryData addObject:element];
//            }
//            else {
//                if ([[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
//                    [tempHistoryData addObject:element];
//                }
//            }
            
        }
        [self historyData:tempHistoryData];
    }
}

- (void)historyData:(NSMutableArray *)result{}

- (void)sendXmppMessage:(NSString *)roomJid subjectName:(NSString *)subjectName messageString:(NSString *)messageString {
    
    [myDelegate.xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [myDelegate.xmppMessageArchivingModule activate:[self xmppStream]];    //By this line all your messages are stored in CoreData
    [myDelegate.xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSString *messageStr = [messageString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [NSDate date];
    //    [dateFormatter setDateFormat:@"hh:mm a"];
    //    [dateFormatter setAMSymbol:@"am"];
    //    [dateFormatter setPMSymbol:@"pm"];
    NSString *formattedTime = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    [body setStringValue:messageStr];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    NSXMLElement *dataTag = [NSXMLElement elementWithName:@"data"];
    //    <message to='7777777777@192.168.18.171' id='eYbIo-34' type='chat'><body>yugigighiihhinoi</body><thread>444560f0-5904-4a06-aa87-0ec6e230bb33</thread><data xmlns='main' receiverName='test' senderName='Sender test' date='14/02/17' from='9999999999' to='7777777777' time='12:56:45'/></message>
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addAttributeWithName:@"to" stringValue:roomJid];
    [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    
    [dataTag addAttributeWithName:@"xmlns" stringValue:@"main"];
    [dataTag addAttributeWithName:@"chatType" stringValue:@"Single"];
    [message addAttributeWithName:@"to" stringValue:roomJid];
    [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    
    [dataTag addAttributeWithName:@"to" stringValue:roomJid];
    [dataTag addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    [dataTag addAttributeWithName:@"time" stringValue:formattedTime];
    //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
    [dataTag addAttributeWithName:@"date" stringValue:formattedDate];
    //        [message addAttributeWithName:@"from-To" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
    [dataTag addAttributeWithName:@"senderName" stringValue:appDelegate.xmppLogedInUserName];
    [dataTag addAttributeWithName:@"receiverName" stringValue:subjectName];
    //    }
    [message addChild:dataTag];
    [message addChild:body];
    
    [[self xmppStream] sendElement:message];
    [[XmppCoreDataHandler sharedManager] insertLocalMessageStorageDataBase:roomJid message:message];
    [self XmppSendMessageResponse:[message copy]];
}

- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage {}
#pragma mark - end

- (void)historUpdated:(NSNotification *)notification {
    
    //    NSString *keyName = myDelegate.chatUser;
    //    if ([[UserDefaultManager getValue:@"CountData"] objectForKey:keyName] != nil) {
    //        int tempCount = 0;
    //        NSMutableDictionary *tempDict = [[UserDefaultManager getValue:@"CountData"] mutableCopy];
    //        [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
    //        [UserDefaultManager setValue:tempDict key:@"CountData"];
    //    }
    NSXMLElement* message = [notification object];
    [self historyUpdateNotify:message];
}

- (void)historyUpdateNotify:(NSXMLElement *)message {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
