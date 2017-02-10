//
//  ChatScreenViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "ChatScreenViewController.h"
#import "UIPlaceHolderTextView.h"

#import "XMPPMessageArchivingCoreDataStorage.h"
#import "AppDelegateObjectFile.h"
#import "XMPP.h"
#import "NSData+XMPP.h"
#import "DataAwareTurnSocket.h"

@interface ChatScreenViewController (){
    CGFloat messageHeight, messageYValue;
    NSMutableArray *userData;
    NSString *otherUserId;
    int btnTag;
    
    NSString *loginUserId, *friendUserId;
    UIImageView *loginuserPhoto, *friendUserPhoto;
    NSData *tempImageData1;
}

@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendButtonOutlet;

@property (strong, nonatomic) IBOutlet UIImageView *sendImage;


@property (nonatomic, strong) XMPPOutgoingFileTransfer *fileTransfer;//File transfer
@end

@implementation ChatScreenViewController
@synthesize userDetail, userXmlDetail;
@synthesize messageTextView, sendButtonOutlet;
@synthesize messageView;
@synthesize chatTableView;
@synthesize lastView,meeToProfile,userNameProfile;
@synthesize userProfileImageView, friendProfileImageView;

@synthesize friendUserJid;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"Personal Chat";
    userProfileImageView = [[UIImageView alloc] init];
    [self addBackBarButton];
    [self setUserData];
    
//    UIImage *im=[UIImage imageNamed:@"arrow_down@3x.png"];
//    [myDelegate saveDataInCacheDirectory:(UIImage *)im folderName:myDelegate.appProfilePhotofolderName jid:friendUserJid];
    
    //file transfer pdf file
    [self createCopyOfDatabaseIfNeeded];
}

- (void)addBackBarButton {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
}
#pragma mark - end
- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Function to Create a writable copy of the bundled default database in the application Documents directory.
- (void)createCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *appDBPath = [self documentPath];
    
    //    NSString *filePath = [myDelegate applicationCacheDirectory];
        NSString *filePath = [[myDelegate applicationCacheDirectory] stringByAppendingPathComponent:myDelegate.appProfilePhotofolderName];
        NSString *fileAtPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.pdf",myDelegate.folderName,[[friendUserJid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
    //    [imagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpeg",folderName,[[jid componentsSeparatedByString:@"@"] objectAtIndex:0]]]
    
    
    success = [fileManager fileExistsAtPath:fileAtPath];
    if (success) {
        return;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath1 = [mainBundle pathForResource:@"a" ofType:@"pdf"];
    success = [fileManager copyItemAtPath:filePath1 toPath:fileAtPath error:&error];
    NSAssert(success, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}

- (NSString *)documentPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Database filename can have extension db/sqlite.
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"a.pdf"];
}


- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [paths lastObject];
}

//UIImage *tempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jid]]];
//if (tempPhoto!=nil) {
//    [myDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:myDelegate.appProfilePhotofolderName jid:jid];

- (void)setXmppData {

    
}

-(NSData *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return imageData;
    
}

-(void)viewWillAppear:(BOOL)animated
{
//    tempImageData=[myDelegate listionDataFromCacheDirectoryFolderName:myDelegate.appProfilePhotofolderName jid:myDelegate.xmppLogedInUserId];
    tempImageData1=[self resizeImage:[UIImage imageWithData:[myDelegate listionDataFromCacheDirectoryFolderName:myDelegate.appProfilePhotofolderName jid:myDelegate.xmppLogedInUserId]]];
    self.sendImage.image=[UIImage imageWithData:tempImageData1];
//    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)tempImageData.length/1024/1024);
//
//    tempImageData = UIImageJPEGRepresentation([UIImage imageWithData:tempImageData], 0);
     NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)tempImageData1.length/1024/1024);
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden=NO;
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [myDelegate showIndicator];
    [self performSelector:@selector(getHistoryData) withObject:nil afterDelay:.1];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
//    if ([lastView isEqualToString:@"ChatViewController"] || [lastView isEqualToString:@"MeTooUserProfile"]) {
//        self.navigationItem.title = [userXmlDetail attributeStringValueForName:@"ToName"];
//        myDelegate.chatUser = [userXmlDetail attributeStringValueForName:@"to"];
//    }
//    else {
//        NSArray* fromUser = [userDetail.jidStr componentsSeparatedByString:@"@52.74.174.129"];
//        self.navigationItem.title = [fromUser objectAtIndex:0];
//        myDelegate.chatUser = [[userDetail.jidStr componentsSeparatedByString:@"/"] objectAtIndex:0];
//    }
//    [userData removeAllObjects];
//    NSString *keyName = myDelegate.chatUser;
//    if ([[UserDefaultManager getValue:@"CountData"] objectForKey:keyName] != nil) {
//        int tempCount = 0;
//        int badgeCount = [[[UserDefaultManager getValue:@"CountData"] objectForKey:keyName] intValue];
//        if (badgeCount > 0) {
//            [myDelegate addBadgeIcon:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] - badgeCount ]];
//            [UserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] - badgeCount ] key:@"BadgeCount"];
//        }
//        NSMutableDictionary *tempDict = [[UserDefaultManager getValue:@"CountData"] mutableCopy];
//        [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
//        [UserDefaultManager setValue:tempDict key:@"CountData"];
//    }
//    [self performSelector:@selector(getHistoryData) withObject:nil afterDelay:.1];
}


-(void)setUserData {
   
    messageTextView.text = @"";
    [messageTextView setPlaceholder:@"Type a message here..."];
    [messageTextView setFont:[UIFont systemFontOfSize:14.0]];
    messageTextView.backgroundColor = [UIColor whiteColor];
    messageTextView.contentInset = UIEdgeInsetsMake(-5, 5, 0, 0);
    messageTextView.alwaysBounceHorizontal = NO;
    messageTextView.bounces = NO;
    userData = [NSMutableArray new];
    messageView.translatesAutoresizingMaskIntoConstraints = YES;
    messageTextView.translatesAutoresizingMaskIntoConstraints = YES;
    messageView.backgroundColor = [UIColor lightGrayColor];
    messageHeight = 40;
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- messageHeight - 10 - 64, self.view.bounds.size.width, messageHeight + 10);
    messageTextView.frame = CGRectMake(8, 5, messageView.frame.size.width - 8 - 64, messageHeight - 8);
    messageYValue = messageView.frame.origin.y;
    if ([messageTextView.text isEqualToString:@""] || messageTextView.text.length == 0) {
        sendButtonOutlet.enabled = NO;
    }
    else{
        sendButtonOutlet.enabled = YES;
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
    chatTableView.translatesAutoresizingMaskIntoConstraints = YES;
    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (messageHeight +10-64));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetch chat history
-(void)getHistoryData{
    
    [self getProfilePhotosJid:friendUserJid profileImageView:friendUserPhoto placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            friendUserPhoto.image=tempImage;
        }
        else {
            friendUserPhoto.image=[UIImage imageNamed:@"images.png"];
        }
    }];
    
    [self getProfilePhotosJid:myDelegate.xmppLogedInUserId profileImageView:loginuserPhoto placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            loginuserPhoto.image=tempImage;
        }
        else {
            loginuserPhoto.image=[UIImage imageNamed:@"images.png"];
        }
    }];

    
    NSManagedObjectContext *moc = [myDelegate.xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, friendUserJid];
    request.predicate = predicate;
    
    
    [request setEntity:entityDescription];
    NSError* error = nil;
//    NSUInteger count = [moc countForFetchRequest:request error:&error];
//    request.fetchLimit = 3;
//    request.fetchOffset = count-3;
    
    NSArray *messages_arc = [moc executeFetchRequest:request error:&error];
    [self print:[[NSMutableArray alloc]initWithArray:messages_arc]];
}
-(void)print:(NSMutableArray*)messages_arc{
    
    @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages_arc) {
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            [userData addObject:element];
        }
        [myDelegate stopIndicator];
//        [chatTableView reloadData];
//        if (userData.count > 0) {
//            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
//            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//        }
    }
}

- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion {
    
    NSData *tempImageData=[myDelegate listionDataFromCacheDirectoryFolderName:myDelegate.appProfilePhotofolderName jid:jid];
    if (nil==tempImageData) {
        profileImageView.image=[UIImage imageNamed:placeholderImage];
        dispatch_queue_t queue = dispatch_queue_create("profilePhotoQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        dispatch_async(queue, ^
                       {
                           UIImage *tempPhoto=[UIImage imageWithData:[[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:jid]]];
                           if (tempPhoto!=nil) {
                               [myDelegate saveDataInCacheDirectory:(UIImage *)tempPhoto folderName:myDelegate.appProfilePhotofolderName jid:jid];
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


#pragma mark - Keyboard delegates
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height -messageHeight -10 , [aValue CGRectValue].size.width, messageHeight+ 10);
    messageYValue = [UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height  -50 -10;
////    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height -messageHeight -14);
    
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
     ////   [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- messageHeight -49 -10, self.view.bounds.size.width, messageHeight+ 10);
    messageYValue = [UIScreen mainScreen].bounds.size.height -49 -10;
    
 ////   chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height- messageHeight -49 -14);
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
   ////     [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
#pragma mark - end

#pragma mark - Textfield delegates
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if ([text isEqualToString:[UIPasteboard generalPasteboard].string]) {
        
        CGSize size = CGSizeMake(messageTextView.frame.size.height,126);
        NSString *string = textView.text;
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        text = [NSString stringWithFormat:@"%@%@",messageTextView.text,text];
        CGRect textRect=[text
                         boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:15]}
                         context:nil];
        
        if ((textRect.size.height < 126) && (textRect.size.height > 50)) {
            
            messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, textRect.size.height);
            
            messageHeight = textRect.size.height + 8;
            messageView.frame = CGRectMake(0, messageYValue-messageHeight - 14 , self.view.bounds.size.width, messageHeight +10 );
          /*  chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  messageYValue-messageHeight - 18);
            if (userData.count > 0) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
                [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }*/
        }
        else if(textRect.size.height <= 50){
            messageHeight = 40;
            messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
            messageView.frame = CGRectMake(0, messageYValue-messageHeight - 14  , self.view.bounds.size.width, messageHeight + 10);
          /*  chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  messageYValue-messageHeight - 18);
            if (userData.count > 0) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
                [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }*/
        }
        if (textView.text.length>=1) {
            
            if (trimmedString.length>=1) {
                sendButtonOutlet.enabled=YES;
            }
            else{
                sendButtonOutlet.enabled=NO;
            }
        }
        else if (textView.text.length==0) {
            sendButtonOutlet.enabled=NO;
        }
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (([messageTextView sizeThatFits:messageTextView.frame.size].height < 126) && ([messageTextView sizeThatFits:messageTextView.frame.size].height > 50)) {
        
        messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, [messageTextView sizeThatFits:messageTextView.frame.size].height);
        messageHeight = [messageTextView sizeThatFits:messageTextView.frame.size].height + 8;
        messageView.frame = CGRectMake(0, messageYValue-messageHeight - 14 , self.view.bounds.size.width, messageHeight +10 );
     /*   chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  messageYValue-messageHeight - 18);
        if (userData.count > 0) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }*/
    }
    else if([messageTextView sizeThatFits:messageTextView.frame.size].height <= 50){
        messageHeight = 40;
        messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
        messageView.frame = CGRectMake(0, messageYValue-messageHeight - 14  , self.view.bounds.size.width, messageHeight + 10);
      /*  chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,  messageYValue-messageHeight - 18 );
        if (userData.count > 0) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }*/
    }
    NSString *string = textView.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textView.text.length>=1) {
        if (trimmedString.length>=1) {
            sendButtonOutlet.enabled=YES;
        }
        else if (trimmedString.length==0) {
            sendButtonOutlet.enabled=NO;
        }
    }
    else if (textView.text.length==0) {
        sendButtonOutlet.enabled=NO;
    }
}
- (IBAction)tapGestureOnView:(UITapGestureRecognizer *)sender {
    [messageTextView resignFirstResponder];
}

#pragma mark - end

#pragma mark - XMPP delegates
//- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
//    [turnSockets removeObject:sender];
//}
//
//- (void)turnSocketDidFail:(TURNSocket *)sender {
//    
//    [turnSockets removeObject:sender];
//}

- (XMPPStream *)xmppStream
{
    return [myDelegate xmppStream];
}
#pragma mark - end
//#pragma mark - IBAction
//-(IBAction)sendMessage:(id)sender
//{
//    [myDelegate.xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
//    [myDelegate.xmppMessageArchivingModule activate:[self xmppStream]];    //By this line all your messages are stored in CoreData
//    [myDelegate.xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    NSString *messageStr = [messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm:ss"];
//    NSDate *date = [NSDate date];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    [dateFormatter setAMSymbol:@"am"];
//    [dateFormatter setPMSymbol:@"pm"];
//    NSString *formattedTime = [dateFormatter stringFromDate:date];
//    [dateFormatter setDateFormat:@"dd/MM/yy"];
//    NSString *formattedDate = [dateFormatter stringFromDate:date];
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:messageStr];
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//    [message addAttributeWithName:@"type" stringValue:@"chat"];
//    
//    if ([lastView isEqualToString:@"ChatViewController"] || [lastView isEqualToString:@"MeTooUserProfile"]) {
//        [message addAttributeWithName:@"to" stringValue:[userXmlDetail attributeStringValueForName:@"to"]];
//        [message addAttributeWithName:@"from" stringValue:[userXmlDetail attributeStringValueForName:@"from"]];
//        [message addAttributeWithName:@"time" stringValue:formattedTime];
////        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
//        [message addAttributeWithName:@"Date" stringValue:formattedDate];
//        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[userXmlDetail attributeStringValueForName:@"to"],[userXmlDetail attributeStringValueForName:@"from"]]];
//        [message addAttributeWithName:@"ToName" stringValue:[userXmlDetail attributeStringValueForName:@"ToName"]];
////        [message addAttributeWithName:@"senderUserId" stringValue:[UserDefaultManager getValue:@"userId"]];
//    }
//    else{
//        [message addAttributeWithName:@"to" stringValue:friendUserJid];
//        [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
//        [message addAttributeWithName:@"time" stringValue:formattedTime];
////        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
//        [message addAttributeWithName:@"Date" stringValue:formattedDate];
//        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
//        [message addAttributeWithName:@"ToName" stringValue:_friendUserName];
////        [message addAttributeWithName:@"senderUserId" stringValue:[UserDefaultManager getValue:@"userId"]];
//    }
//    [message addChild:body];
////    [[WebService sharedManager] chatNotification:[message attributeStringValueForName:@"to"] userNameFrom:[message attributeStringValueForName:@"from"] messageString:[[message elementForName:@"body"] stringValue] success:^(id responseObject) {
////        [myDelegate stopIndicator];
////    } failure:^(NSError *error) {
////    }] ;
//    [[self xmppStream] sendElement:message];
////    [self messagesData:message];
////    messageTextView.text=@"";
////    if (userData.count > 0) {
////        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
////        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
////    }
////    if (messageTextView.text.length>=1) {
////        sendButtonOutlet.enabled=YES;
////    }
////    else if (messageTextView.text.length==0) {
////        sendButtonOutlet.enabled=NO;
////    }
////    [chatTableView reloadData];
//}
-(void)messagesData:(NSXMLElement*)myMessage{
    [userData addObject:myMessage];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
    [chatTableView beginUpdates];
    [chatTableView insertRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [chatTableView endUpdates];
    [chatTableView scrollToRowAtIndexPath:[self indexPathForLastMessage]
                         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [chatTableView reloadData];
}
#pragma mark - end
#pragma mark - Table view delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[chatTableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
//    UIImageView *userImage = (UIImageView*)[cell viewWithTag:1];
//    UILabel *userName = (UILabel*)[cell viewWithTag:2];
//    UILabel *userChat = (UILabel*)[cell viewWithTag:3];
//    UILabel *chatTime = (UILabel*)[cell viewWithTag:4];
//    UILabel *seperatorLabel = (UILabel*)[cell viewWithTag:5];
////    MyButton *userImageBtn = (MyButton*)[cell viewWithTag:10];
////    MyButton *nameButton = (MyButton*)[cell viewWithTag:20];
//    userName.translatesAutoresizingMaskIntoConstraints = YES;
//    userChat.translatesAutoresizingMaskIntoConstraints = YES;
////    userImageBtn.translatesAutoresizingMaskIntoConstraints = YES;
////    nameButton.translatesAutoresizingMaskIntoConstraints = YES;
//    userImage.layer.cornerRadius = 30;
//    userImage.layer.masksToBounds = YES;
//    userImage.layer.borderWidth=1.5f;
//    userImage.layer.borderColor=[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor;
//    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
////    if ( [[UserDefaultManager getValue:@"userName"] caseInsensitiveCompare:[message attributeStringValueForName:@"Name"]] == NSOrderedSame)
////    {
////        userName.text = [UserDefaultManager getValue:@"userName"];
////    }
////    else
////    {
////        userName.text = [message attributeStringValueForName:@"Name"];
////        otherUserId=[message attributeStringValueForName:@"senderUserId"];
////    }
//    userChat.text = [[message elementForName:@"body"] stringValue];
//    NSArray* fromUser = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
////    if ( [[UserDefaultManager getValue:@"LoginCred"] caseInsensitiveCompare:[fromUser objectAtIndex:0]] == NSOrderedSame) {
////        userImage.image = userProfileImageView.image;
////        userName.textColor = [UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
////    }
////    else{
////        userName.textColor = [UIColor blackColor];
////        userImage.image = friendProfileImageView;
////    }
//    NSString *userNameValue = [message attributeStringValueForName:@"Name"];
//    float userNameHeight;
//    CGSize size = CGSizeMake(userTableView.frame.size.width - (10+50+20+10),50);
//    CGRect textRect=[userNameValue
//                     boundingRectWithSize:size
//                     options:NSStringDrawingUsesLineFragmentOrigin
//                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Medium" size:14]}
//                     context:nil];
//    userName.numberOfLines = 0;
//    userNameHeight = textRect.size.height;
//    userName.frame = CGRectMake(82, 25, userTableView.frame.size.width - (10+50+20+10), userNameHeight);
//    nameButton.frame = userName.frame;
//    [nameButton addTarget:self action:@selector(openProfileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [userImageBtn addTarget:self action:@selector(openProfileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    userImageBtn.Tag=(int)indexPath.row;
//    nameButton.Tag=(int)indexPath.row;
//    NSString *body = [[message elementForName:@"body"] stringValue];
//    size = CGSizeMake(userTableView.frame.size.width - (10+50+20+10),2000);
//    textRect=[body
//              boundingRectWithSize:size
//              options:NSStringDrawingUsesLineFragmentOrigin
//              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:14]}
//              context:nil];
//    userChat.numberOfLines = 0;
//    if (userData.count == 1 || indexPath.row == 0) {
//        userChat.frame = CGRectMake(82,  userName.frame.origin.y + userNameHeight + 9, userTableView.frame.size.width - (10+50+20+10), textRect.size.height);
//        userImage.hidden = NO;
//        userName.hidden = NO;
//        nameButton.hidden=NO;
//        userImageBtn.hidden=NO;
//    }
//    else{
//        NSXMLElement* message1;
//        message1 = [userData objectAtIndex:(int)indexPath.row - 1];
//        if ([[message attributeStringValueForName:@"Name"] isEqualToString:[message1 attributeStringValueForName:@"Name"]]) {
//            userChat.frame = CGRectMake(82, 5, userTableView.frame.size.width - (10+50+20+10), textRect.size.height);
//            userImage.hidden = YES;
//            userName.hidden = YES;
//            nameButton.hidden=YES;
//            userImageBtn.hidden=YES;
//        }
//        else{
//            userChat.frame = CGRectMake(82,  userName.frame.origin.y + userNameHeight + 9, userTableView.frame.size.width - (10+50+20+10), textRect.size.height);
//            userImage.hidden = NO;
//            userName.hidden = NO;
//            nameButton.hidden=NO;
//            userImageBtn.hidden=NO;
//        }
//        
//        
//        
//    }
//    NSXMLElement *nextMessage;
//    
//    if (userData.count>indexPath.row+1) {
//        nextMessage = [userData objectAtIndex:(int)indexPath.row + 1];
//        if (![[message attributeStringValueForName:@"Name"] isEqualToString:[nextMessage attributeStringValueForName:@"Name"]]) {
//            seperatorLabel.hidden=NO;
//        }
//        else
//        {
//            seperatorLabel.hidden=YES;
//        }
//        
//    }
//    else
//    {
//        seperatorLabel.hidden=NO;
//    }
//    chatTime.hidden = NO;
//    chatTime.text = [message attributeStringValueForName:@"time"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
    NSString *userName = [message attributeStringValueForName:@"Name"];
    float userNameHeight;
    CGSize size = CGSizeMake(chatTableView.frame.size.width - (10+50+20+10),50);//here (10+50+20+15) = (imageView.x + imageView.width + space b/w imageView and label + label trailing)
    CGRect textRect=[userName
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Medium" size:14]}
                     context:nil];
    userNameHeight = textRect.size.height;
    NSString *body = [[message elementForName:@"body"] stringValue];
    size = CGSizeMake(chatTableView.frame.size.width - (10+50+20+10),2000);
    textRect=[body
              boundingRectWithSize:size
              options:NSStringDrawingUsesLineFragmentOrigin
              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:14]}
              context:nil];
    if (userData.count==1 || indexPath.row == 0) {
        if (textRect.size.height > 20) {
            return textRect.size.height + 25 + userNameHeight  + 16 + 18;
        }
        else{
            return 95;
        }
    }
    else{
        NSXMLElement* message1 = [userData objectAtIndex:(int)indexPath.row - 1];
        if ([[message attributeStringValueForName:@"Name"] isEqualToString:[message1 attributeStringValueForName:@"Name"]]) {
            return textRect.size.height + 20  + 5;
        }
        else{
            if (textRect.size.height > 20) {
                return textRect.size.height + 25 + userNameHeight  + 16 + 20;
            }
            else{
                return 95;
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        UILabel *userChat = (UILabel*)[cell viewWithTag:3];
        [[UIPasteboard generalPasteboard] setString:userChat.text];
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 1;
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated
{
    NSInteger numberOfRows = userData.count;
    if (numberOfRows)
    {
        [chatTableView scrollToRowAtIndexPath:[self indexPathForLastMessage]
                             atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}
-(NSIndexPath *)indexPathForLastMessage
{
    NSInteger lastSection = 0;
    NSInteger numberOfMessages = userData.count;
    return [NSIndexPath indexPathForRow:numberOfMessages-1 inSection:lastSection];
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


#pragma mark - IBAction
-(IBAction)sendMessage:(id)sender
{
//    [myDelegate.xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
//    [myDelegate.xmppMessageArchivingModule activate:[self xmppStream]];    //By this line all your messages are stored in CoreData
//    [myDelegate.xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    NSString *messageStr = [messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:mm:ss"];
//    NSDate *date = [NSDate date];
//    [dateFormatter setDateFormat:@"hh:mm a"];
//    [dateFormatter setAMSymbol:@"am"];
//    [dateFormatter setPMSymbol:@"pm"];
//    NSString *formattedTime = [dateFormatter stringFromDate:date];
//    [dateFormatter setDateFormat:@"dd/MM/yy"];
//    NSString *formattedDate = [dateFormatter stringFromDate:date];
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    
//    NSData *data = UIImageJPEGRepresentation(self.sendImage.image, 0.1);
//    NSXMLElement *ImgAttachement = [NSXMLElement elementWithName:@"attachment"];
//NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)data.length/1024/1024);
//    
//    [ImgAttachement setStringValue:[data xmpp_base64Encoded]];
//    
//    [body setStringValue:messageStr];
//    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
////    [message addAttributeWithName:@"type" stringValue:@"chat"];
////    
////    if ([lastView isEqualToString:@"ChatViewController"] || [lastView isEqualToString:@"MeTooUserProfile"]) {
////        [message addAttributeWithName:@"to" stringValue:[userXmlDetail attributeStringValueForName:@"to"]];
////        [message addAttributeWithName:@"from" stringValue:[userXmlDetail attributeStringValueForName:@"from"]];
////        [message addAttributeWithName:@"time" stringValue:formattedTime];
////        //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
////        [message addAttributeWithName:@"Date" stringValue:formattedDate];
////        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[userXmlDetail attributeStringValueForName:@"to"],[userXmlDetail attributeStringValueForName:@"from"]]];
////        [message addAttributeWithName:@"ToName" stringValue:[userXmlDetail attributeStringValueForName:@"ToName"]];
////        //        [message addAttributeWithName:@"senderUserId" stringValue:[UserDefaultManager getValue:@"userId"]];
////    }
////    else{
//        [message addAttributeWithName:@"to" stringValue:friendUserJid];
//        [message addAttributeWithName:@"from" stringValue:myDelegate.xmppLogedInUserId];
//        [message addAttributeWithName:@"time" stringValue:formattedTime];
//        //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
//        [message addAttributeWithName:@"Date" stringValue:formattedDate];
//        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
//        [message addAttributeWithName:@"ToName" stringValue:_friendUserName];
////        //        [message addAttributeWithName:@"senderUserId" stringValue:[UserDefaultManager getValue:@"userId"]];
////    }
//    [message addChild:ImgAttachement];
//    [message addChild:body];
//    //    [[WebService sharedManager] chatNotification:[message attributeStringValueForName:@"to"] userNameFrom:[message attributeStringValueForName:@"from"] messageString:[[message elementForName:@"body"] stringValue] success:^(id responseObject) {
//    //        [myDelegate stopIndicator];
//    //    } failure:^(NSError *error) {
//    //    }] ;
//    [[self xmppStream] sendElement:message];
//    //    [self messagesData:message];
//    //    messageTextView.text=@"";
//    //    if (userData.count > 0) {
//    //        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
//    //        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//    //    }
//    //    if (messageTextView.text.length>=1) {
//    //        sendButtonOutlet.enabled=YES;
//    //    }
//    //    else if (messageTextView.text.length==0) {
//    //        sendButtonOutlet.enabled=NO;
//    //    }
//    //    [chatTableView reloadData];
    
    
    
 
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@/%@",friendUserJid,[[myDelegate.xmppStream myJID] resource]]];
    
    if (!_fileTransfer) {
        _fileTransfer = [[XMPPOutgoingFileTransfer alloc]
                         initWithDispatchQueue:dispatch_get_main_queue()];
        _fileTransfer.disableSOCKS5 = YES;
        [_fileTransfer activate:myDelegate.xmppStream];
        [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
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
    [self imageTransfer:jid];
    
     
     
//    NSError *err;
//    if (![_fileTransfer sendData:UIImagePNGRepresentation(self.sendImage.image)
//                           named:@"a.png"
//                     toRecipient:jid
//                     description:@"Baal's Soulstone."
//                           error:&err]) {
//        NSLog(@"You messed something up: %@", err);
//    }
    
}

- (void)pdfTransfer:(XMPPJID *)jid {
    
    //    NSString *filePath = [myDelegate applicationCacheDirectory];
        NSString *filePath = [[myDelegate applicationCacheDirectory] stringByAppendingPathComponent:myDelegate.appProfilePhotofolderName];
        NSString *fileAtPath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.pdf",myDelegate.folderName,[[friendUserJid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
        NSData *data = [NSData dataWithContentsOfFile:fileAtPath];
    
    NSError *err;
    if (![_fileTransfer sendData:data
                           named:@"a.pdf"
                     toRecipient:jid
                     description:@"Baal's Soulstone."
                           error:&err]) {
        NSLog(@"You messed something up: %@", err);
    }
}

- (void)imageTransfer:(XMPPJID *)jid {

    NSError *err;
    if (![_fileTransfer sendData:UIImagePNGRepresentation(self.sendImage.image)
                           named:@"a.png"
                     toRecipient:jid
                     description:@"Baal's Soulstone."
                           error:&err]) {
        NSLog(@"You messed something up: %@", err);
    }
}

#pragma mark - XMPPOutgoingFileTransferDelegate Methods
- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
//    DDLogInfo(@"Outgoing file transfer failed with error: %@", error);
    NSLog(@"%@",error);
    NSLog(@"%@",error.localizedDescription);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"There was an error sending your file. See the logs."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
//    DDLogVerbose(@"File transfer successful.");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                    message:@"Your file was sent successfully."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
