//
//  XMPPUserDefaultManager.m
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XMPPUserDefaultManager.h"

@implementation XMPPUserDefaultManager

#pragma mark - Get/Set/Remove data from userDefault methods
//Set data in userDefault
+ (void)setValue:(id)value key:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//Fetch data in userDefault
+ (id)getValue:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

//Remove data in userDefault
+ (void)removeValue:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}
#pragma mark - end
@end
