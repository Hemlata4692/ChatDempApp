//
//  XMPPChatView.m
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XMPPChatView.h"
#define fetchUserHistoryLimit 3

@interface XMPPChatView () {

    AppDelegateObjectFile *appDelegate;
}

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

- (void)initializeFriendProfile:(NSString*)jid {
    
    appDelegate.updateProfileUserId=jid;
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
    
    NSManagedObjectContext *moc = [myDelegate.xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, jid];
    request.predicate = predicate;
    
    
    [request setEntity:entityDescription];
    NSError* error = nil;
    NSUInteger count = [moc countForFetchRequest:request error:&error];
//    request.fetchLimit = fetchUserHistoryLimit;
    NSLog(@"%d",(int)count-(int)fetchUserHistoryLimit);
//    if ((int)count-(int)fetchUserHistoryLimit<1) {
//        request.fetchOffset=0;
//    }
//    else {
//        request.fetchOffset = (int)count-(int)fetchUserHistoryLimit;
//    }

    NSArray *messages_arc = [moc executeFetchRequest:request error:&error];
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
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            [tempHistoryData addObject:element];
        }
        [self historyData:tempHistoryData];
//        [myDelegate stopIndicator];
        //        [chatTableView reloadData];
        //        if (userData.count > 0) {
        //            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        //            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //        }
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
                               if (tempPhoto!=nil) {
                                   [appDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:appDelegate.appProfilePhotofolderName jid:friendJid];
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
    
    //    if ([lastView isEqualToString:@"ChatViewController"] || [lastView isEqualToString:@"MeTooUserProfile"]) {
    //        [message addAttributeWithName:@"to" stringValue:[userXmlDetail attributeStringValueForName:@"to"]];
    //        [message addAttributeWithName:@"from" stringValue:[userXmlDetail attributeStringValueForName:@"from"]];
    //        [message addAttributeWithName:@"time" stringValue:formattedTime];
    //        //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
    //        [message addAttributeWithName:@"Date" stringValue:formattedDate];
    //        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[userXmlDetail attributeStringValueForName:@"to"],[userXmlDetail attributeStringValueForName:@"from"]]];
    //        [message addAttributeWithName:@"ToName" stringValue:[userXmlDetail attributeStringValueForName:@"ToName"]];
    //        //        [message addAttributeWithName:@"senderUserId" stringValue:[UserDefaultManager getValue:@"userId"]];
    //    }
    //    else{
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
    //    [[WebService sharedManager] chatNotification:[message attributeStringValueForName:@"to"] userNameFrom:[message attributeStringValueForName:@"from"] messageString:[[message elementForName:@"body"] stringValue] success:^(id responseObject) {
    //        [myDelegate stopIndicator];
    //    } failure:^(NSError *error) {
    //    }] ;
    
    [[self xmppStream] sendElement:message];
    [self XmppSendMessageResponse:message];
    
    
    
//    [self messagesData:message];
//    messageTextView.text=@"";
//    
//    messageHeight = messageTextviewInitialHeight;
//    
//    messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
//    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(keyboardHeight+navigationBarHeight+messageHeight+10)  , self.view.bounds.size.width, messageHeight + 10);
//    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
//    
//    
//    
//    //        if (userData.count > 0) {
//    //            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
//    //            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//    //        }
//    if (messageTextView.text.length>=1) {
//        sendButtonOutlet.enabled=YES;
//    }
//    else if (messageTextView.text.length==0) {
//        sendButtonOutlet.enabled=NO;
//    }
//    [chatTableView reloadData];
    
    
    
    /*
     XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@/%@",friendUserJid,[[myDelegate.xmppStream myJID] resource]]];
     
     if (!_fileTransfer) {
     _fileTransfer = [[XMPPOutgoingFileTransfer alloc]
     initWithDispatchQueue:dispatch_get_main_queue()];
     _fileTransfer.disableSOCKS5 = YES;
     [_fileTransfer activate:myDelegate.xmppStream];
     [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
     }
     */
    
    //    NSString *recipient = _inputRecipient.text;
    //    NSString *filename = @"a.jpeg";
    //
    //    // do error checking fun stuff...
    //
    ////    NSString *filePath = [myDelegate applicationCacheDirectory];
    //    NSString *filePath = [[myDelegate applicationCacheDirectory] stringByAppendingPathComponent:myDelegate.appProfilePhotofolderName];
    //    NSString *fileAtPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpeg",myDelegate.folderName,[[friendUserJid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
    ////    [imagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpeg",folderName,[[jid componentsSeparatedByString:@"@"] objectAtIndex:0]]]
    
    
    
    
    //    NSString *fullPath = [[self documentsDirectory] stringByAppendingPathComponent:filename];
    //    NSData *data = [NSData dataWithContentsOfFile:fileAtPath];
    
    
    
    //PDF transfer
    //     [self pdfTransfer:jid];
    
    //Image transfer
    // [self imageTransfer:jid];
    
    
    
    //    NSError *err;
    //    if (![_fileTransfer sendData:UIImagePNGRepresentation(self.sendImage.image)
    //                           named:@"a.png"
    //                     toRecipient:jid
    //                     description:@"Baal's Soulstone."
    //                           error:&err]) {
    //        NSLog(@"You messed something up: %@", err);
    //    }
    
    
    
}

- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage {}
#pragma mark - end

#pragma mark - Notification observer handler
- (void)XmppUserPresenceUpdateNotify {}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
