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

//#pragma mark - XMPP delegates
//- (XMPPStream *)xmppStream {
//    
//    return [appDelegate xmppStream];
//}
//#pragma mark - end

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
    request.fetchLimit = fetchUserHistoryLimit;
    NSLog(@"%d",(int)count-(int)fetchUserHistoryLimit);
    if ((int)count-(int)fetchUserHistoryLimit<1) {
        request.fetchOffset=0;
    }
    else {
        request.fetchOffset = (int)count-(int)fetchUserHistoryLimit;
    }

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
    }
}
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
