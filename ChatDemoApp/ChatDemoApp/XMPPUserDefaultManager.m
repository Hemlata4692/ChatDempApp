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
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - end

#pragma mark - Get/Set/Remove data in userDefault for XMPPBadgeIndicator
//Set data in userDefault for XMPPBadgeIndicator
+ (void)setXMPPBadgeIndicatorKey:(NSString *)key {
    
    if (nil==[[self getValue:@"XMPPBadgeIndicator"] objectForKey:key]) {
        int tempCount = 1;
        NSMutableDictionary *tempDict = [[self getValue:@"XMPPBadgeIndicator"] mutableCopy];
        [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:key];
        [self setValue:tempDict key:@"XMPPBadgeIndicator"];
    }
    else{
        NSMutableDictionary *tempDict = [[self getValue:@"XMPPBadgeIndicator"] mutableCopy];
        int tempCount = [[tempDict objectForKey:key] intValue];
        tempCount = tempCount + 1;
        [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:key];
        [self setValue:tempDict key:@"XMPPBadgeIndicator"];
    }
}

//Fetch data in userDefault for XMPPBadgeIndicator
+ (id)getXMPPBadgeIndicatorValue:(NSString *)key {
    
    if (nil==[[self getValue:@"XMPPBadgeIndicator"] objectForKey:key]) {
        return @"0";
    }
    else{
        if ([[[self getValue:@"XMPPBadgeIndicator"] objectForKey:key] intValue] == 0) {
            return @"0";
        }
        else{
            return [[self getValue:@"XMPPBadgeIndicator"] objectForKey:key];
        }
    }
}

//Remove data in userDefault for XMPPBadgeIndicator
+ (void)removeXMPPBadgeIndicatorValue:(NSString *)key {
    
    NSMutableDictionary *tempDict = [[self getValue:@"XMPPBadgeIndicator"] mutableCopy];
    NSArray *tempArray=[tempDict allKeys];
    if ([tempArray containsObject:key]) {
        [tempDict removeObjectForKey:key];
    }
    [self setValue:tempDict key:@"XMPPBadgeIndicator"];
}
#pragma mark - end

@end
