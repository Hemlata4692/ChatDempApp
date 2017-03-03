//
//  GroupChatXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 28/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupChatXMPP.h"
#import "XmppCoreDataHandler.h"
#import <XMPPRoomMemoryStorage.h>
#import <XMPPIDTracker.h>
#import "NSData+XMPP.h"
#import <XMPPRoomHybridStorage.h>

@interface GroupChatXMPP ()<XMPPRoomDelegate>{
    
    AppDelegateObjectFile *appDelegate;
    NSString *nickName;
    XMPPRoom *sendXmppRoomObj;
    NSString *roomName, *roomDecs;
    BOOL isFirstFetchBookmark, isUpdate;
    UIImage *groupProfileImage, *lastgroupProfileImage;
    NSString *currentjid;
    BOOL isDestroy, isInvite;
    
    __strong id <XMPPRoomStorage> xmppRoomStorage;

}

@end

@implementation GroupChatXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPBookMarkUpdated) name:@"XMPPBookMarkUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroySuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroyFail) name:@"XMPPDeleteGroupFail" object:nil];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [self viewWillDisappear:YES];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (XMPPStream *)xmppStream
{
    return [appDelegate xmppStream];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getUniqueRoomName {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)createChatRoom:(UIImage *)image {

    groupProfileImage=image;
    isInvite=false;
    isDestroy=false;
    isFirstFetchBookmark=true;
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@",[self getUniqueRoomName],appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    nickName=@"myNickname";
    [xmppRoom joinRoomUsingNickname:nickName
                            history:nil
                           password:nil];
}

- (void)updateChatRoom:(UIImage *)image {
    
    groupProfileImage=image;
    isUpdate=true;
    
    [self fetchJoinedGroupList];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
    isDestroy=false;
    sendXmppRoomObj=sender;
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
    sendXmppRoomObj=sender;
    if (isDestroy) {
        [sender removeDelegate:self delegateQueue:dispatch_get_main_queue()];
        [self destroyRoom:currentjid room:sender];
    }
    else
        if (isInvite){
    
        [self sendInvition:sender];
    }
    
//    [sender inviteUser:[XMPPJID jidWithString:@"Test1"] withMessage:@"Greetings!"];
//    [sender inviteUser:[XMPPJID jidWithString:@"Test2"] withMessage:@"Greetings!"];
}



- (BOOL)isRoomOwner:(XMPPRoom *)sender
{
    
    
    return YES;
}

- (BOOL)isRoomOwner {

    return YES;
}

- (void)sendInvition:(XMPPRoom *)sender {

    [sender inviteUser:[XMPPJID jidWithString:@"Test1"] withMessage:@"Greetings!"];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    
    NSXMLElement *newConfig = [configForm copy];
    
    NSArray* fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_roomname"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"rohitmodi"]];
            roomName=[[field elementForName:@"value"] stringValue];
        }
        else if ([var isEqualToString:@"muc#roomconfig_maxusers"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"5"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"room description"]];
            roomDecs=[[field elementForName:@"value"] stringValue];
        }
    }
    [sender configureRoomUsingOptions:newConfig];
    
//    [self addBookMark:[sender roomJID] name:roomName roomDecs:roomDecs];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult {

     NSLog(@"a");
    
//    [self addBookMark:[sender roomJID]];
    [self fetchJoinedGroupList];
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult {

    NSLog(@"a");
}

- (void)addBookMark:(XMPPJID *)roomId conferenceList:(NSMutableArray *)conferenceList{

//    NSString* server = @"test@pc"; //or whatever the server address for muc is
//    XMPPJID *servrJID = [XMPPJID jidWithString:server];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:myDelegate.hostName]];
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
    [conference_s addAttributeWithName:@"name" stringValue:roomName];
    [conference_s addAttributeWithName:@"autojoin" stringValue:@"true"];
    [conference_s addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@",roomId]];
    [conference_s addAttributeWithName:@"nick" stringValue:nickName];
    [conference_s addAttributeWithName:@"Desc" stringValue:roomDecs];
    
    if (groupProfileImage) {
        [self setPhoto:[myDelegate reducedImageSize:groupProfileImage] xmlElement:conference_s];
    }
    [storage_q addChild:conference_s];
    [query addChild:storage_q];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

- (void)updateBookMark:(NSMutableArray *)conferenceList{
    
    //    NSString* server = @"test@pc"; //or whatever the server address for muc is
    //    XMPPJID *servrJID = [XMPPJID jidWithString:server];
//    020317101010@conference.192.168.18.171
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:myDelegate.hostName]];
    [iq addAttributeWithName:@"from" stringValue:[self.xmppStream myJID].full];
    //    [iq addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"BookMarkManager2.%@",[self getUniqueRoomName]]];
    [iq addAttributeWithName:@"id" stringValue:@"BookMarkManager"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"jabber:iq:private"];
    NSXMLElement *storage_q = [NSXMLElement elementWithName:@"storage"];
    [storage_q addAttributeWithName:@"xmlns" stringValue:@"storage:bookmarks"];
    
    for (int i=0; i<conferenceList.count; i++) {
        
        //        attributeStringValueForName
        NSXMLElement *list=[[conferenceList objectAtIndex:i] copy];
        if ([[list attributeStringValueForName:@"jid"] isEqualToString:@"020317101010@conference.192.168.18.171"]) {
        
            NSXMLElement *conference_s = [NSXMLElement elementWithName:@"conference"];
            [conference_s addAttributeWithName:@"name" stringValue:@"New rohit modi"];
            [conference_s addAttributeWithName:@"autojoin" stringValue:@"true"];
            [conference_s addAttributeWithName:@"jid" stringValue:[list attributeStringValueForName:@"jid"]];
            [conference_s addAttributeWithName:@"nick" stringValue:[list attributeStringValueForName:@"nick"]];
            [conference_s addAttributeWithName:@"Desc" stringValue:[list attributeStringValueForName:@"Desc"]];
            
            if (groupProfileImage) {
                [self setPhoto:[myDelegate reducedImageSize:groupProfileImage] xmlElement:conference_s];
            }
            
            [conferenceList replaceObjectAtIndex:i withObject:conference_s];
            [storage_q addChild:conference_s];
        }
        else {
        
            [storage_q addChild:[list copy]];
        }
    }
    [query addChild:storage_q];
    [iq addChild:query];
    [self.xmppStream sendElement:iq];
}

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
            NSXMLElement *type = [NSXMLElement elementWithName:@"TYPE"];
            [photo addChild:type];
            [type setStringValue:imageType];
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

- (void)fetchList {

    [self fetchJoinedGroupList];    //Fetch only joined group
//    [self fetchAllGroupList]; //Fetch all group list
}

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
    NSXMLElement *storage =   [NSXMLElement elementWithName:@"storage" xmlns:@"storage:bookmarks"];
    [query addChild:storage];
    [iq addChild:query];
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

- (void)XMPPBookMarkUpdated {

    NSLog(@"a");
}

- (void)XMPPFetchBookmarktList:(NSNotification *)notification {
    
    NSLog(@"%@",notification.object);
    if (isFirstFetchBookmark) {
        
        isFirstFetchBookmark=false;
        [self addBookMark:[sendXmppRoomObj roomJID] conferenceList:[notification.object mutableCopy]];
    }
    else {
    
        for (int i=0; i<[notification.object count]; i++) {
            
            NSXMLElement *lastConferences=[notification.object objectAtIndex:i];
            NSLog(@"%@",[lastConferences elementForName:@"PHOTO"]);
            if (nil!=[lastConferences elementForName:@"PHOTO"]&&NULL!=[lastConferences elementForName:@"PHOTO"]) {
                UIImage *i=[UIImage imageWithData:[self photo:lastConferences]];
                lastgroupProfileImage=[UIImage imageWithData:[self photo:lastConferences]];
            }
        }
        if (isUpdate) {
            isUpdate=false;
            [self updateBookMark:[notification.object mutableCopy]];
        }
        NSLog(@"a");
    }
}

- (void)joinDeleteChatRoom:(NSString *)roomJidString {
    
    isDestroy=YES;
    [self reuseJoinMethod:roomJidString];
}

- (void)inviteChatRoom:(NSString *)roomJidString {
    
    isInvite=YES;
    [self reuseJoinMethod:roomJidString];
}

- (void)reuseJoinMethod:(NSString *)roomJidString {
    
    currentjid=roomJidString;
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    //    NSString* roomID = [NSString stringWithFormat:@"%@@%@",[self getUniqueRoomName],appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomJidString];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    nickName=@"myNickname";
    [xmppRoom joinRoomUsingNickname:nickName
                            history:nil
                           password:nil];
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender {

    isDestroy=false;
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFailToDestroy:(XMPPIQ *)iqError {
    isDestroy=false;
}


- (void)destroyRoom :(NSString *)roomJidString room:(XMPPRoom *)room{

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
    
    
    NSXMLElement *destroy = [NSXMLElement elementWithName:@"destroy"];
    if (destroy) {
        NSXMLElement *reason = [destroy elementForName:@"reason"];
        if (!reason) {
            reason = [NSXMLElement elementWithName:@"reason" stringValue:@"Macbeth doth"];
            [destroy addChild:reason];
        }
    }
    
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCOwnerNamespace];
    [query addChild:destroy];
    
    NSString *iqID = [self.xmppStream generateUUID];
    myDelegate.groupDeleteid=iqID;
    XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:[XMPPJID jidWithString:roomJidString] elementID:iqID child:query];
//    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@/%@",appDelegate.xmppLogedInUserId,[[myDelegate.xmppStream myJID] resource]]];
    [self.xmppStream sendElement:iq];
}

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPDeleteGroupSuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPDeleteGroupFail) name:@"XMPPDeleteGroupFail" object:nil];
#pragma mark - Delete group notify
- (void)xmppRoomDidDestroySuccess {

    myDelegate.groupDeleteid=nil;
    NSLog(@"successfully destroy");
}

- (void)xmppRoomDidDestroyFail {
    myDelegate.groupDeleteid=nil;
    NSLog(@"fail destroy");
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
