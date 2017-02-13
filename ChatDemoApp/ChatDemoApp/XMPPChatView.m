//
//  XMPPChatView.m
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XMPPChatView.h"

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
