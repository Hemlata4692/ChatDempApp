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

#define XMPPRoomNickName @"XMPPRoomNickName"

@interface XMPPGroupChatRoom ()<XMPPRoomDelegate>{
    
    AppDelegateObjectFile *appDelegate;
    GroupChatType type;
    NSString *roomName, *roomDescription, *roomNickName;
    UIImage *roomImage;
}

@end

@implementation XMPPGroupChatRoom

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPBookMarkUpdated) name:@"XMPPBookMarkUpdated" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPFetchBookmarktList:) name:@"XMPPFetchBookmarktList" object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroySuccess) name:@"XMPPDeleteGroupSuccess" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmppRoomDidDestroyFail) name:@"XMPPDeleteGroupFail" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    roomName=groupSubject;
    roomDescription=groupDescription;
    roomNickName=groupNickName;
    
    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@",[self getUniqueRoomName],appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];

    if (roomNickName||[roomNickName isEqualToString:@""]) {
        
        roomNickName=XMPPRoomNickName;
    }
    
    //This method is used to create group if not exist and if this group is exist then join it
    [xmppRoom joinRoomUsingNickname:roomNickName
                            history:nil
                           password:nil];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    sendXmppRoomObj=sender;
//    if (isDestroy) {
//        [sender removeDelegate:self delegateQueue:dispatch_get_main_queue()];
//        [self destroyRoom:currentjid room:sender];
//    }
//    else if (isInvite){
//        
//        [self sendInvition:sender];
//    }
//    else if (isOwner){
//        
//        [sender fetchConfigurationForm];
//    }
    
    //    [sender inviteUser:[XMPPJID jidWithString:@"Test1"] withMessage:@"Greetings!"];
    //    [sender inviteUser:[XMPPJID jidWithString:@"Test2"] withMessage:@"Greetings!"];
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
