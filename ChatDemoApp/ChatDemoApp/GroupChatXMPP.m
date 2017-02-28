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

@interface GroupChatXMPP (){
    
    AppDelegateObjectFile *appDelegate;
}

@end

@implementation GroupChatXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
}

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

- (void)createChatRoom {

    XMPPRoomMemoryStorage * _roomMemory = [[XMPPRoomMemoryStorage alloc]init];
    NSString* roomID = [NSString stringWithFormat:@"%@@%@",[self getUniqueRoomName],appDelegate.conferenceServerJid];
    XMPPJID * roomJID = [XMPPJID jidWithString:roomID];
    XMPPRoom* xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_roomMemory
                                                           jid:roomJID
                                                 dispatchQueue:dispatch_get_main_queue()];
    [xmppRoom activate:self.xmppStream];
    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoom joinRoomUsingNickname:@"myNickname"
                            history:nil
                           password:nil];
}

- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"a");
    
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"a");
    
//    [sender inviteUser:[XMPPJID jidWithString:@"Test1"] withMessage:@"Greetings!"];
//    [sender inviteUser:[XMPPJID jidWithString:@"Test2"] withMessage:@"Greetings!"];
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
        }
        else if ([var isEqualToString:@"muc#roomconfig_maxusers"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"5"]];
        }
        else if ([var isEqualToString:@"muc#roomconfig_roomdesc"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"room description"]];
        }
    }
    [sender configureRoomUsingOptions:newConfig];
}

- (void)fetchList {
//    NSXMLElement *adminElement = [NSXMLElement elementWithName:@"iq"];
//    XMPPJID *roomJid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@conference.%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"],@"server_address"]];
//    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
//    XMPPRoom * xmppRoom = [[XMPPRoom alloc]
//                           initWithRoomStorage:roomMemoryStorage
//                           jid:roomJid
//                           dispatchQueue:dispatch_get_main_queue()];
//    
//    [adminElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[xmppRoom roomJID]]];
//    [adminElement addAttributeWithName:@"id" stringValue:@"adminlist"];
//    [adminElement addAttributeWithName:@"type" stringValue:@"get"];
//    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query"];
//    [queryElement addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/muc#admin"];
//    NSXMLElement *itemElement = [NSXMLElement elementWithName:@"item"];
//    [itemElement addAttributeWithName:@"affiliation" stringValue:@"admin"];
//    [queryElement addChild:itemElement];
//    [adminElement addChild:queryElement];
//    [self.xmppStream sendElement:adminElement];
    
    
    XMPPJID *servrJID = [XMPPJID jidWithString:appDelegate.conferenceServerJid];
    XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:servrJID];
    [iq addAttributeWithName:@"from" stringValue:[[self xmppStream] myJID].full];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query"];
    [query addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/disco#items"];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
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
