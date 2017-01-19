//
//  LoginXMPP.m
//  ChatDemoApp
//
//  Created by Ranosys on 19/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LoginXMPP.h"

@interface LoginXMPP () {

    AppDelegateObjectFile *appDelegate;
}
@end

@implementation LoginXMPP

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserDidAuthenticated) name:@"XMPPDidAuthenticatedResponse" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UserNotAuthenticated) name:@"XMPPDidNotAuthenticatedResponse" object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login User
- (void)loginConnectWithoutPassword:(NSString *)username {
    
    [self setValue:[NSString stringWithFormat:@"%@@%@",username,appDelegate.hostName] key:@"LoginCred"];
    [self setValue:appDelegate.defaultPassword key:@"PassCred"];
    [self setValue:@"1" key:@"CountValue"];
    [appDelegate disconnect];
    [appDelegate connect];
}

- (void)loginConnectPassword:(NSString *)password username:(NSString *)username {
    
    [self setValue:[NSString stringWithFormat:@"%@@%@",username,appDelegate.hostName] key:@"LoginCred"];
    [self setValue:password key:@"PassCred"];
    [self setValue:@"1" key:@"CountValue"];
    [appDelegate disconnect];
    [appDelegate connect];
}
#pragma mark - end

#pragma mark - Post notification called method
- (void)UserDidAuthenticated {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self UserDidAuthenticatedResult];
    });
}

- (void)UserNotAuthenticated {
    
    [self removeValue:@"LoginCred"];
    [self removeValue:@"PassCred"];
    [self UserNotAuthenticatedResult];
}

//These method is called to subViewController of LoginXMPP file
- (void)UserDidAuthenticatedResult {}
- (void)UserNotAuthenticatedResult{}
//end
#pragma mark - end

#pragma mark - User logout
- (void)userLogout {

    [self setValue:nil key:@"LoginCred"];
    [appDelegate disconnect];
    [self setValue:[NSString stringWithFormat:@"zebra@%@",myDelegate.hostName] key:@"LoginCred"];
    [self setValue:@"password" key:@"PassCred"];
    [appDelegate connect];
}
#pragma mark - end

#pragma mark - Get/Set/Remove data from userDefault methods
//Set data in userDefault
- (void)setValue:(id)value key:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//Fetch data in userDefault
- (id)getValue:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

//Remove data in userDefault
- (void)removeValue:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
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

@end
