//
//  GroupChatViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPGroupChatRoom.h"

#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
#import "XMPP.h"
#import "TURNSocket.h"

@interface GroupChatViewController : XMPPGroupChatRoom {
    
    NSMutableArray *turnSockets;
    NSMutableArray	*messages;
}

@property(nonatomic, retain)NSMutableDictionary *roomDetail;

@property (nonatomic,retain) NSString *friendUserJid;

@property (nonatomic,retain) XMPPUserCoreDataStorageObject *userDetail;
@property (nonatomic,retain) NSXMLElement *userXmlDetail;
@property (nonatomic,retain) UIImageView *userProfileImageView;
@property (nonatomic,retain) UIImage *friendProfileImageView;
@property (nonatomic,retain) NSString *lastView;
@property (nonatomic,retain) NSString *meeToProfile;
@property (nonatomic,retain) NSString *userNameProfile;


@property (nonatomic,retain) NSString *loginUserName;
@property (nonatomic,retain) NSString *friendUserName;
@end
