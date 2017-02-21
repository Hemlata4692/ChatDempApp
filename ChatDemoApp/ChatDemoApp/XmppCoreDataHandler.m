//
//  XmppCoreDataHandler.m
//  ChatDemoApp
//
//  Created by Ranosys on 21/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "XmppCoreDataHandler.h"

@implementation XmppCoreDataHandler
@synthesize xmppAppDelegateObj;

#pragma mark - Shared instance
+ (id)sharedManager {
    
    static XmppCoreDataHandler *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init {
    
    if (self = [super init]) {
        
        xmppAppDelegateObj = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}
#pragma mark - end

//Users delete/insert/update data in local storage
- (void)deleteDataModelEntry:(NSString *)registredUserId {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        [context deleteObject:[results objectAtIndex:0]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self removeLocalMessageStorageDataBase:registredUserId];
        if (xmppAppDelegateObj.isContactListIsLoaded) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppNewUserAdded" object:nil];
        }
    }
}

- (void)insertNewUserEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred;
    
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count == 0) {
        NSManagedObject *xmppDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"UserEntry" inManagedObjectContext:context];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [xmppAppDelegateObj.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:registredUserId] ignoreStorage:YES];
        if (xmppAppDelegateObj.isContactListIsLoaded) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppNewUserAdded" object:nil];
        }
    }
}

- (void)insertEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred;
    
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        NSManagedObject* xmppDataEntry = [results objectAtIndex:0];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        [context save:nil];
    } else {
        NSManagedObject *xmppDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"UserEntry" inManagedObjectContext:context];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}
//end

//Manage local chat storage
- (void)removeLocalMessageStorageDataBase:(NSString *)userId {
    
    //Remove local dataBase user chat
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *predicateFrmt = @"bareJidStr == %@";
    NSPredicate *pred;
    
    pred = [NSPredicate predicateWithFormat:predicateFrmt, userId];
    NSLog(@"predicate: %@",pred);
    
    //    [request setPredicate:predicate];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"MessageHistory"];
    [fetchRequest setPredicate:pred];
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    
    if (results.count > 0) {
        
        for (NSManagedObject *object in results) {
            [context deleteObject:object];
        }
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
    }
    //end
}

- (void)insertLocalMessageStorageDataBase:(NSString *)bareJidStr message:(NSXMLElement *)message {
    
    [self insertMessageData:bareJidStr message:[NSString stringWithFormat:@"%@",message] uniquiId:@""];
}

- (void)insertLocalImageMessageStorageDataBase:(NSString *)bareJidStr message:(NSXMLElement *)message uniquiId:(NSString *)uniquiId {
    
    [self insertMessageData:bareJidStr message:[NSString stringWithFormat:@"%@",message] uniquiId:uniquiId];
}

- (void)insertMessageData:(NSString *)bareJidStr message:(NSString *)message uniquiId:(NSString *)uniquiId {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *xmppDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"MessageHistory" inManagedObjectContext:context];
    [xmppDataEntry setValue:bareJidStr forKey:@"bareJidStr"];
    [xmppDataEntry setValue:message forKey:@"messageString"];
    [xmppDataEntry setValue:uniquiId forKey:@"uniqueId"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (NSArray *)readAllLocalMessageStorageDatabase {
    
    return [self readLocalChat:@""];
}

- (NSArray *)readLocalMessageStorageDatabaseBareJidStr:(NSString *)bareJidStr {
    
    return [self readLocalChat:bareJidStr];
}

- (NSArray *)readLocalChat:(NSString *)bareJidStr {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"MessageHistory"];
    if (![bareJidStr isEqualToString:@""]) {
        NSPredicate *pred;
        pred = [NSPredicate predicateWithFormat:@"bareJidStr == %@", bareJidStr];
        NSLog(@"predicate: %@",pred);
        [fetchRequest setPredicate:pred];
    }
    return [context executeFetchRequest:fetchRequest error:nil];
}

- (void)updateLocalMessageStorageDatabaseBareJidStr:(NSString *)bareJidStr message:(NSXMLElement *)message uniquiId:(NSString *)uniquiId {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"MessageHistory"];
    if (![bareJidStr isEqualToString:@""]) {
        NSPredicate *pred;
        pred = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniquiId];
        NSLog(@"predicate: %@",pred);
        [fetchRequest setPredicate:pred];
    }
    NSArray *tempArray=[context executeFetchRequest:fetchRequest error:nil];
    if ([tempArray count]>0) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSManagedObject* xmppDataEntry = [tempArray objectAtIndex:0];
        [xmppDataEntry setValue:bareJidStr forKey:@"bareJidStr"];
        [xmppDataEntry setValue:[NSString stringWithFormat:@"%@",message] forKey:@"messageString"];
        [xmppDataEntry setValue:uniquiId forKey:@"uniqueId"];
        [context save:nil];
    }
    else {
        [self insertMessageData:bareJidStr message:[NSString stringWithFormat:@"%@",message] uniquiId:uniquiId];
    }
}
//end

//User profile storage methods
- (NSDictionary *)getProfileDicData:(NSString *)jid {
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSPredicate *pred;
    NSMutableArray *results = [[NSMutableArray alloc]init];
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@",jid];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    
    results = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSDictionary *profileResponse;
    if (results.count>0) {
        NSManagedObject *tempDevice = [results objectAtIndex:0];
        profileResponse=@{
                          @"RegisterId" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppRegisterId"]],
                          @"Name" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppName"]],
                          @"PhoneNumber" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppPhoneNumber"]],
                          @"UserStatus" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppUserStatus"]],
                          @"Description" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppDescription"]],
                          @"Address" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppAddress"]],
                          @"EmailAddress" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppEmailAddress"]],
                          @"UserBirthDay" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppUserBirthDay"]],
                          @"Gender" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppGender"]],
                          };
        NSLog(@"\n\n");
    }
    return profileResponse;
}

- (NSMutableDictionary *)getProfileUsersData {
    
    NSMutableDictionary *tempDict=[NSMutableDictionary new];
    NSMutableArray *tempArray=[NSMutableArray new];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
    tempArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    for (NSManagedObject *tempDevice in tempArray) {
        if (![[tempDevice valueForKey:@"xmppRegisterId"] isEqualToString:xmppAppDelegateObj.xmppLogedInUserId]) {
            NSDictionary *profileResponse=@{
                                            @"RegisterId" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppRegisterId"]],
                                            @"Name" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppName"]],
                                            @"PhoneNumber" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppPhoneNumber"]],
                                            @"UserStatus" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppUserStatus"]],
                                            @"Description" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppDescription"]],
                                            @"Address" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppAddress"]],
                                            @"EmailAddress" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppEmailAddress"]],
                                            @"UserBirthDay" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppUserBirthDay"]],
                                            @"Gender" : [xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppGender"]],
                                            };
            [tempDict setObject:profileResponse forKey:[tempDevice valueForKey:@"xmppRegisterId"]];
        }
        else {
            
            xmppAppDelegateObj.xmppLogedInUserName=[xmppAppDelegateObj checkNilValue:[tempDevice valueForKey:@"xmppName"]];
        }
    }
    
    return tempDict;
}
//end

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
@end
