//
//  XMPPChatView.m
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XMPPChatView.h"
#import "XMPPOutgoingFileTransfer.h"//File transfer
#import "XmppCoreDataHandler.h"
#import "XMPPUserDefaultManager.h"

#define fetchUserHistoryLimit 3

@interface XMPPChatView ()<XMPPOutgoingFileTransferDelegate/*file transfer*/> {

    AppDelegateObjectFile *appDelegate;
    NSXMLElement *imageAttachmentMessage;
    NSString *uniqueId;
}
@property (nonatomic, strong) XMPPOutgoingFileTransfer *fileTransfer;//File transfer
@end

@implementation XMPPChatView

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XmppUserPresenceUpdateNotify) name:@"XmppUserPresenceUpdate" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileTransferSuccessFully) name:@"XMPPFileTransferSuccessFully" object:nil];
    
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

- (void)initializeFriendProfile:(NSString*)jid {
    
    appDelegate.selectedFriendUserId=jid;
    [XMPPUserDefaultManager removeXMPPBadgeIndicatorValue:jid];
}
#pragma mark - end

#pragma mark - XMPP delegates
- (XMPPStream *)xmppStream {
    
    return [appDelegate xmppStream];
}
#pragma mark - end

#pragma mark - Get user presence
- (int)getPresenceStatus:(NSString *)jid {
    
    XMPPUserCoreDataStorageObject *user=[appDelegate.xmppUserDetailedList objectForKey:jid];
    return [user.sectionNum intValue];
}
#pragma mark - end

#pragma mark - Fetch chat history
- (void)getHistoryChatData:(NSString *)jid {
    
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
            
            NSXMLElement *innerElementData = [element elementForName:@"data"];
            if (![[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId] && [[innerElementData attributeStringValueForName:@"to"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                
                    [tempHistoryData addObject:element];
            }
            else {
                if ([[innerElementData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                    [tempHistoryData addObject:element];
                }
            }
            
        }
        [self historyData:tempHistoryData];
    }
}

- (void)historyData:(NSMutableArray *)result{}
#pragma mark - end

#pragma mark - Set/Get profile images
- (void)getChatProfilePhotoFriendJid:(NSString *)friendJid profileImageView:(UIImage *)profileImageView friendProfileImageView:(UIImage *)friendProfileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(NSArray *imageArray)) completion {
    
    //Fetch profile photos from local database if exist
    NSData *tempImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:appDelegate.xmppLogedInUserId];
    NSData *tempFriendImageData=[appDelegate listionDataFromCacheDirectoryFolderName:appDelegate.appProfilePhotofolderName jid:friendJid];
    
    //Set temporary image
    if (nil==tempImageData) {
        profileImageView=[UIImage imageNamed:placeholderImage];
    }
    else {
        profileImageView=[UIImage imageWithData:tempImageData];
    }
    
    if (nil==tempFriendImageData) {
        friendProfileImageView=[UIImage imageNamed:placeholderImage];
    }
    else {
        friendProfileImageView=[UIImage imageWithData:tempFriendImageData];
    }
    
    //If one image is nil means anyone image is not exist then call background thread
    if ((nil==tempImageData) || (nil==tempFriendImageData)) {
        dispatch_queue_t queue = dispatch_queue_create("profilePhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async(queue, ^
                       {
                           UIImage *tempPhoto,*friendTempPhoto;
                           
                           if (nil==tempImageData) {
                               tempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:appDelegate.xmppLogedInUserId]]];
                               if (tempPhoto!=nil) {
                                   [appDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:appDelegate.appProfilePhotofolderName jid:appDelegate.xmppLogedInUserId];
                               }
                               else {
                                   tempPhoto=[UIImage imageNamed:placeholderImage];
                               }
                           }
                           else {
                               tempPhoto=[UIImage imageWithData:tempImageData];
                           }
                           
                           if (nil==tempFriendImageData) {
                               friendTempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:friendJid]]];
                               if (friendTempPhoto!=nil) {
                                   [appDelegate saveDataInCacheDirectory:(UIImage *)friendTempPhoto folderName:appDelegate.appProfilePhotofolderName jid:friendJid];
                               }
                               else {
                                   friendTempPhoto=[UIImage imageNamed:placeholderImage];
                               }
                           }
                           else {
                               friendTempPhoto=[UIImage imageWithData:tempFriendImageData];
                           }

                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               completion(@[tempPhoto,friendTempPhoto]);
                           });
                       });
    } else {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completion(@[profileImageView,friendProfileImageView]);
        });

    }
}
#pragma mark - end

#pragma mark - Send message
- (void)sendXmppMessage:(NSString *)friendJid friendName:(NSString *)friendName messageString:(NSString *)messageString {
    
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
    
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:friendJid];
    [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    
    [dataTag addAttributeWithName:@"xmlns" stringValue:@"main"];
    [dataTag addAttributeWithName:@"chatType" stringValue:@"Single"];
    [message addAttributeWithName:@"to" stringValue:friendJid];
    [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    
    [dataTag addAttributeWithName:@"to" stringValue:friendJid];
    [dataTag addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
    [dataTag addAttributeWithName:@"time" stringValue:formattedTime];
    //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
    [dataTag addAttributeWithName:@"date" stringValue:formattedDate];
    //        [message addAttributeWithName:@"from-To" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
    [dataTag addAttributeWithName:@"senderName" stringValue:appDelegate.xmppLogedInUserName];
    [dataTag addAttributeWithName:@"receiverName" stringValue:friendName];
    //    }
    [message addChild:dataTag];
    [message addChild:body];
  
    [[self xmppStream] sendElement:message];
    [[XmppCoreDataHandler sharedManager] insertLocalMessageStorageDataBase:friendJid message:message];
    [self XmppSendMessageResponse:[message copy]];
}

- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage {}
#pragma mark - end

#pragma mark - Notification observer handler
- (void)XmppUserPresenceUpdateNotify {}

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
#pragma mark - end


- (void)setReceiveImage {

}

- (void)sendAttachment:(NSString *)fileName imageCaption:(NSString *)imageCaption friendName:(NSString *)friendName {

    imageAttachmentMessage=nil;
    uniqueId=@"";
    NSData *imageData=[appDelegate listionSendAttachedImageCacheDirectoryFileName:fileName];
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@/%@",appDelegate.selectedFriendUserId,[[myDelegate.xmppStream myJID] resource]]];
//    if (!_fileTransfer) {
        _fileTransfer = [[XMPPOutgoingFileTransfer alloc]
                         initWithDispatchQueue:dispatch_get_main_queue()];
    _fileTransfer.disableIBB = NO;
    _fileTransfer.disableSOCKS5 = YES;
        [_fileTransfer activate:myDelegate.xmppStream];
        [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    }
    
    uniqueId=[[fileName componentsSeparatedByString:@"."] objectAtIndex:0];
    imageAttachmentMessage=[self convertedMessage:appDelegate.selectedFriendUserId friendName:friendName imageName:fileName messageString:imageCaption];
    NSError *err;
//    if (![_fileTransfer sendData:imageData
//                           named:fileName
//                     toRecipient:jid
//                     description:imageCaption
//                           error:&err]) {
//        NSLog(@"You messed something up: %@", err);
//    }
    

    NSXMLElement *messageData=[imageAttachmentMessage elementForName:@"data"];
    if ([_fileTransfer sendCustomizedData:imageData named:fileName toRecipient:jid description:imageCaption date:[messageData attributeStringValueForName:@"date"] time:[messageData attributeStringValueForName:@"time"] senderId:[messageData attributeStringValueForName:@"from"] chatType:@"ImageAttachment" senderName:appDelegate.xmppLogedInUserName receiverName:friendName error:&err]) {
        
        [[XmppCoreDataHandler sharedManager] insertLocalImageMessageStorageDataBase:appDelegate.selectedFriendUserId message:imageAttachmentMessage uniquiId:uniqueId];
        [self sendImageFileDelegate:[imageAttachmentMessage copy]];
    }
}

- (NSXMLElement *)convertedMessage:(NSString *)to friendName:(NSString *)friendName imageName:(NSString *)imageName messageString:(NSString *)messageString {

    NSString *messageStr = [messageString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *formattedTime = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    [body setStringValue:messageStr];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    NSXMLElement *dataTag = [NSXMLElement elementWithName:@"data"];
    
    [message addAttributeWithName:@"type" stringValue:@"ImageAttachment"];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addAttributeWithName:@"from" stringValue:appDelegate.xmppLogedInUserId];
    [message addAttributeWithName:@"progress" stringValue:@"2"];
    
    [dataTag addAttributeWithName:@"xmlns" stringValue:@"main"];
    [dataTag addAttributeWithName:@"chatType" stringValue:@"Single"];

    [dataTag addAttributeWithName:@"to" stringValue:to];
    [dataTag addAttributeWithName:@"fileName" stringValue:imageName];

    [dataTag addAttributeWithName:@"from" stringValue:appDelegate.xmppLogedInUserId];
    [dataTag addAttributeWithName:@"time" stringValue:formattedTime];
    //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
    [dataTag addAttributeWithName:@"date" stringValue:formattedDate];
    //        [message addAttributeWithName:@"from-To" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
    [dataTag addAttributeWithName:@"senderName" stringValue:appDelegate.xmppLogedInUserName];
    [dataTag addAttributeWithName:@"receiverName" stringValue:friendName];
    //    }
    [message addChild:dataTag];
    [message addChild:body];
    return message;
}

#pragma mark - XMPPOutgoingFileTransferDelegate Methods
- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    //    DDLogInfo(@"Outgoing file transfer failed with error: %@", error);
    NSLog(@"%ld",(long)error.code);
    if (error.code!=-1) {
        
        NSXMLElement *failMessage=[imageAttachmentMessage copy];
        [failMessage addAttributeWithName:@"progress" stringValue:@"0"];
        [[XmppCoreDataHandler sharedManager] updateLocalMessageStorageDatabaseBareJidStr:appDelegate.selectedFriendUserId message:failMessage uniquiId:uniqueId];
        [self sendImageFailDelegate:failMessage uniquiId:uniqueId];
    }
//    NSLog(@"%@",error.localizedDescription);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                    message:error.localizedDescription
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
        NSLog(@"File transfer successful.");
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
//                                                    message:@"Your file was sent successfully."
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}

- (void)fileTransferSuccessFully {

    NSLog(@"File transfer successful.");
    NSXMLElement *successMessage=[imageAttachmentMessage copy];
    [successMessage addAttributeWithName:@"progress" stringValue:@"1"];
    [[XmppCoreDataHandler sharedManager] updateLocalMessageStorageDatabaseBareJidStr:appDelegate.selectedFriendUserId message:successMessage uniquiId:uniqueId];
    [self sendImageSuccessDelegate:successMessage uniquiId:uniqueId];
}

- (void)sendImageSuccessDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId{}
- (void)sendImageFailDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId{}
- (void)sendImageFileDelegate:(NSXMLElement *)message{}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
